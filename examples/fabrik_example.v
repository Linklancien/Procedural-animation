import gg
import linklancien.proc_anim
import graphic_debug
import math
import math.vec

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
	proc_anim.fabrik(mut arm.points, arm.pos_constraints, arm.angle_constraints,
		target, 1)
}

fn (arm Arm) render(ctx gg.Context) {
	graphic_debug.basic_render(ctx, arm.points, arm.pos_constraints, gg.white)
}
