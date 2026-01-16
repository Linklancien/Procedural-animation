import gg
import linklancien.proc_anim
import graphic_debug
import math { cos, sin }
import math.vec
import sokol.sgl

const bg_color = gg.Color{}

struct App {
mut:
	ctx      &gg.Context = unsafe { nil }
	text_cfg gg.TextCfg

	x_mouse    int
	y_mouse    int
	win_width  int
	win_height int

	target vec.Vec2[f64]

	arm Arm
}

fn main() {
	mut app := &App{}
	app.ctx = gg.new_context(
		width:         app.win_width
		height:        app.win_height
		create_window: true
		window_title:  '- Procedural Animation -'
		user_data:     app
		bg_color:      bg_color
		frame_fn:      on_frame
		init_fn:       on_init
		event_fn:      on_event
		sample_count:  2
	)

	app.ctx.run()
}

fn on_init(mut app App) {
	size := app.ctx.window_size()
	app.win_width = size.width
	app.win_height = size.height

	arm_len := 10
	app.arm = Arm{
		pos_constraints:   []f64{len: arm_len, init: 25}
		angle_constraints: []f64{len: arm_len, init: math.pi * 2 / 6}
		points:            []vec.Vec2[f64]{len: arm_len, init: vec.Vec2[f64]{
			x: index + app.win_width / 2
			y: index + app.win_height / 2
		}}
	}
}

fn on_frame(mut app App) {
	app.arm.update(app.target)
	// Draw
	app.ctx.begin()
	app.arm.render(app.ctx)
	app.ctx.end()
}

fn on_event(e &gg.Event, mut app App) {
	size := app.ctx.window_size()
	app.win_width = size.width
	app.win_height = size.height

	app.x_mouse, app.y_mouse = int(e.mouse_x), int(e.mouse_y)
	app.target = vec.Vec2[f64]{
		x: app.x_mouse
		y: app.y_mouse
	}
	if e.char_code != 0 && e.char_code < 128 {
		// app.change += u8(e.char_code).ascii_str()
	}
	match e.typ {
		.key_down {
			match e.key_code {
				.f4 {
					app.ctx.quit()
				}
				.escape {}
				.backspace {}
				.right {}
				.left {}
				.space {}
				else {}
			}
		}
		.mouse_down {
			match e.mouse_button {
				.left {}
				else {}
			}
		}
		else {}
	}
}

// Arm
struct Arm {
	pos_constraints   []f64
	angle_constraints []f64
mut:
	points []vec.Vec2[f64]
	// fingers are attached at the first node with a certain angle
	fingers        []Finger = []Finger{len: 4}
	fingers_angles []f64    = [-math.pi / 8, -math.pi / 3, math.pi / 3, math.pi / 8]
}

const finger_len = 4
const finger_thickness = 5
const finger_angle = math.pi * 2 / 6
const array_pos_init = []vec.Vec2[f64]{len: finger_len, init: vec.Vec2[f64]{
	x: f64(finger_len - index - 1)
	y: f64(finger_len - index - 1)
}}

struct Finger {
	pos_constraints   []f64 = []f64{len: finger_len, init: finger_thickness}
	angle_constraints []f64 = []f64{len: finger_len, init: finger_angle}
mut:
	points []vec.Vec2[f64] = array_pos_init
}

fn (mut arm Arm) update(target vec.Vec2[f64]) {
	proc_anim.fabrik(mut arm.points, arm.pos_constraints, arm.angle_constraints, target,
		1)
	for mut finger in arm.fingers {
		proc_anim.fabrik(mut finger.points, finger.pos_constraints, finger.angle_constraints,
			target - arm.points[0], 1)
	}
}

fn (arm Arm) render(ctx gg.Context) {
	arm.draw(ctx, gg.white)
	// graphic_debug.basic_render(ctx, arm.points, arm.pos_constraints, gg.red)
	for id, angle in arm.fingers_angles {
		x0 := f32(arm.points[0].x)
		y0 := f32(arm.points[0].y)
		rot := (arm.points[0] - arm.points[1]).angle()
		
		x := x0 + f32(arm.pos_constraints[0] * cos(rot + angle))
		y := y0 + f32(arm.pos_constraints[0] * sin(rot + angle))
		
		arm.fingers[id].draw(ctx, x, y, gg.light_blue)
		// graphic_debug.basic_render_at(ctx, x, y, arm.fingers[id].points, arm.fingers[id].pos_constraints,
		// 	gg.blue)
	}
}

fn (arm Arm) draw(ctx gg.Context, c gg.Color) {
	if c.a != 255 {
		sgl.load_pipeline(ctx.pipeline.alpha)
	}
	sgl.c4b(c.r, c.g, c.b, c.a)

	sgl.begin_triangle_strip()
	max := arm.points.len - 1
	for i, point in arm.points {
		rotation := if i != max {
			(point - arm.points[i + 1]).angle()
		} else {
			(arm.points[i - 1] - point).angle()
		}
		x := f32(point.x)
		y := f32(point.y)
		match i {
			0 {
				x1, y1, x2, y2 := get_opposing_pos(x, y, f32(arm.pos_constraints[i]),
					rotation)

				sgl.v2f(x1, y1)
				sgl.v2f(x2, y2)
			}
			max {
				add_opposing_points(x, y, f32(arm.pos_constraints[i]), rotation)

				xf := x + f32(arm.pos_constraints[i] * cos(rotation + math.pi))
				yf := y + f32(arm.pos_constraints[i] * sin(rotation + math.pi))
				sgl.v2f(xf, yf)
			}
			else {
				add_opposing_points(x, y, f32(arm.pos_constraints[i]), rotation)
			}
		}
	}
	sgl.end()
}


fn (finger Finger) draw(ctx gg.Context, x_abs f32, y_abs f32, c gg.Color) {
	// graphic_debug.basic_render_at(ctx, x, y, finger.points, finger.pos_constraints, gg.red)
	if c.a != 255 {
		sgl.load_pipeline(ctx.pipeline.alpha)
	}
	sgl.c4b(c.r, c.g, c.b, c.a)

	sgl.begin_triangle_strip()
	max := finger.points.len - 1
	for i := max; i >= 0; i -= 1 {
		rotation := if i != max {
			(finger.points[i] - finger.points[i + 1]).angle()
		} else {
			(finger.points[i - 1] - finger.points[i]).angle()
		}
		x := f32(finger.points[i].x) + x_abs
		y := f32(finger.points[i].y) + y_abs
		match i {
			0 {
			  add_opposing_points(x, y, f32(finger.pos_constraints[i]), rotation)

				xf := x + f32(finger.pos_constraints[i] * cos(rotation))
				yf := y + f32(finger.pos_constraints[i] * sin(rotation))

				sgl.v2f(xf, yf)
			}
			else {
			  add_opposing_points(x, y, f32(finger.pos_constraints[i]), rotation)
			}
		}
	}
	sgl.end()
}

fn add_opposing_points(x f32, y f32, radius f32, rotation f64) {
	x1, y1, x2, y2 := get_opposing_pos(x, y, radius, rotation)

	sgl.v2f(x1, y1)
	sgl.v2f(x2, y2)
}

fn get_opposing_pos(x f32, y f32, radius f32, rotation f64) (f32, f32, f32, f32) {
	x1 := x + f32(radius * cos(rotation + math.pi / 2))
	y1 := y + f32(radius * sin(rotation + math.pi / 2))
	x2 := x + f32(radius * cos(rotation - math.pi / 2))
	y2 := y + f32(radius * sin(rotation - math.pi / 2))
	return x1, y1, x2, y2
}
