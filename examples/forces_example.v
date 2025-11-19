import gg
import linklancien.proc_anim
import graphic_debug
import math
import math.vec

const bg_color = gg.Color{}
const gravity = vec.Vec2[f64]{
	y: 10
}

enum Run_method {
	pause
	step
	run
}

struct App {
mut:
	ctx      &gg.Context = unsafe { nil }
	text_cfg gg.TextCfg

	x_mouse    int
	y_mouse    int
	win_width  int = 800
	win_height int = 600

	target vec.Vec2[f64]

	snake Snake

	run_method Run_method = .pause
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

	snake_len := 20
	app.snake = Snake{
		pos_constraints:   []f64{len: snake_len, init: 20}
		angle_constraints: []f64{len: snake_len, init: math.pi * 2 / 6}
		points:            []vec.Vec2[f64]{len: snake_len, init: vec.Vec2[f64]{
			x: index + app.win_width / 2
			y: index + app.win_height / 2
		}}
		velocity:          []vec.Vec2[f64]{len: snake_len}
	}
}

fn on_frame(mut app App) {
	match app.run_method {
		.run {
			app.snake.update(app.target)
		}
		.step {
			app.snake.update(app.target)
			app.run_method = .pause
		}
		else {}
	}
	// Draw
	app.ctx.begin()
	app.snake.render(app.ctx)
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
	match e.typ {
		.key_down {
			match e.key_code {
				.f4 {
					app.ctx.quit()
				}
				.space {
					match app.run_method {
						.pause {
							app.run_method = .step
						}
						else {
							app.run_method = .pause
						}
					}
				}
				.enter {
					app.run_method = .run
				}
				else {}
			}
		}
		else {}
	}
}

// Snake
struct Snake {
	node_weight       f64 = 10
	pos_constraints   []f64
	angle_constraints []f64
mut:
	// those fields have the same len
	points   []vec.Vec2[f64]
	velocity []vec.Vec2[f64]
}

fn (mut snake Snake) update(target vec.Vec2[f64]) {
	instant := true
	if instant{
		// start by getting the head at the mouse
		proc_anim.front_go_to(mut snake.points, snake.pos_constraints, snake.angle_constraints,
			target, 1)
		dt := 1.0
		// stock the previous position to calcul the velocity later
		prec_pos := snake.points.clone()
		// apply external forces
		snake.apply_force(dt, gravity.mul_scalar(snake.node_weight))
		// apply constrains
		// proc_anim.front_to_back(mut snake.points, snake.pos_constraints, snake.angle_constraints)
		println('PT')
		println(snake.points[0])
		proc_anim.front_go_to(mut snake.points, snake.pos_constraints, snake.angle_constraints,
			snake.points[0], 1)
		println(snake.points[0])
		// apply the constrains + the change of position of the head
		for i in 0 .. snake.velocity.len {
			snake.velocity[i] = (snake.points[i] - prec_pos[i]).div_scalar(dt)
		}
	}
	else{
		dt := 1.0
		// stock the previous position to calcul the velocity later
		prec_pos := snake.points.clone()
		// apply external forces
		snake.apply_force(dt, gravity.mul_scalar(snake.node_weight))
		//
		dif := (target - snake.points[0])
		fact := 5.0
		real_target := if dif.magnitude() >= fact {
			dif.normalize().mul_scalar(fact) + snake.points[0]
		} else {
			snake.points[0]
		}
		// apply the constrains + the change of position of the head
		proc_anim.front_go_to(mut snake.points, snake.pos_constraints, snake.angle_constraints,
			real_target, 1)
		for i in 0 .. snake.velocity.len {
			snake.velocity[i] = (snake.points[i] - prec_pos[i]).div_scalar(dt)
		}
	}
}

fn (mut snake Snake) apply_force(dt f64, forces ...vec.Vec2[f64]) {
	// sum forces
	mut total := vec.Vec2[f64]{}
	for force in forces {
		total += force
	}
	// m*a = sum forces
	acceleration := total.div_scalar(snake.node_weight)

	// dpos = a*dt²/2
	for i in 0 .. snake.points.len {
		if 0 < snake.points[i].x && snake.points[i].x < 800 && 0 < snake.points[i].y
			&& snake.points[i].y < 400 {
			snake.points[i] += acceleration.mul_scalar(dt * dt / 2) +
				snake.velocity[i].mul_scalar(dt)
		}
	}
}

fn (snake Snake) render(ctx gg.Context) {
	graphic_debug.angular_render(ctx, snake.points, snake.pos_constraints, gg.white)
}
