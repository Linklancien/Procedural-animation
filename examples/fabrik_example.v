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
		pos_constraints:   []f64{len: arm_len, init: 20}
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
}

fn (mut arm Arm) update(target vec.Vec2[f64]) {
	proc_anim.fabrik(mut arm.points, arm.pos_constraints, arm.angle_constraints, target,
		1)
}

fn (arm Arm) render(ctx gg.Context) {
	graphic_debug.basic_render(ctx, arm.points, arm.pos_constraints, gg.white)
	arm_render(ctx, arm.points, arm.pos_constraints, gg.white)
}

pub fn arm_render(ctx gg.Context, points []vec.Vec2[f64], radius []f64, c gg.Color) {
	if c.a != 255 {
		sgl.load_pipeline(ctx.pipeline.alpha)
	}
	sgl.c4b(c.r, c.g, c.b, c.a)
	sgl.begin_triangle_strip()

	max := points.len - 1
	for i, point in points {
		match i {
			0 {
				x0 := f32(point.x)
				y0 := f32(point.y)

				rot := (point - points[1]).angle()
				angles := [math.pi / 6, -math.pi / 6, math.pi / 4, -math.pi / 4, math.pi / 2,
					-math.pi / 2]
				for angle in angles {
					xc := x0 + f32(radius[0] * cos(rot + angle))
					yc := y0 + f32(radius[0] * sin(rot + angle))
					sgl.v2f(xc, yc)
				}
			}
			max {
				rotation := if i != points.len - 1 {
					(point - points[i + 1]).angle()
				} else {
					(points[i - 1] - point).angle()
				}
				x := f32(point.x)
				y := f32(point.y)

				x1 := x + f32(radius[i] * cos(rotation + math.pi / 2))
				y1 := y + f32(radius[i] * sin(rotation + math.pi / 2))
				x2 := x + f32(radius[i] * cos(rotation - math.pi / 2))
				y2 := y + f32(radius[i] * sin(rotation - math.pi / 2))

				sgl.v2f(x1, y1)
				sgl.v2f(x2, y2)

				xf := x + f32(radius[i] * cos(rotation + math.pi))
				yf := y + f32(radius[i] * sin(rotation + math.pi))
				sgl.v2f(xf, yf)
			}
			else {
				rotation := if i != points.len - 1 {
					(point - points[i + 1]).angle()
				} else {
					(points[i - 1] - point).angle()
				}
				x := f32(point.x)
				y := f32(point.y)

				x1 := x + f32(radius[i] * cos(rotation + math.pi / 2))
				y1 := y + f32(radius[i] * sin(rotation + math.pi / 2))
				x2 := x + f32(radius[i] * cos(rotation - math.pi / 2))
				y2 := y + f32(radius[i] * sin(rotation - math.pi / 2))

				sgl.v2f(x1, y1)
				sgl.v2f(x2, y2)

				if i == points.len - 1 {
					xf := x + f32(radius[i] * cos(rotation + math.pi))
					yf := y + f32(radius[i] * sin(rotation + math.pi))
					sgl.v2f(xf, yf)
				}
			}
		}
	}
	sgl.end()
}
