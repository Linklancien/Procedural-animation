import gg
import linklancien.proc_anim
import graphic_debug
import math
import math.vec

const bg_color = gg.Color{}
const gravity = vec.Vec2[f64]{
	y: 10
}
const corner = vec.Vec2[f32]{
	x: 600
	y: 600
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
	win_width  int = int(corner.x) + 200
	win_height int = int(corner.y) + 200

	target vec.Vec2[f64]

	snake Snake

	run_method      Run_method = .pause
	render_velocity bool       = true
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
	snake_part_len := 20
	app.snake = Snake{
		pos_constraints:   []f64{len: snake_len, init: snake_part_len}
		angle_constraints: []f64{len: snake_len, init: math.pi * 2 / 6}
		points:            []vec.Vec2[f64]{len: snake_len, init: vec.Vec2[f64]{
			x: index * snake_part_len + app.win_width / 4
			y: app.win_height / 3
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
	app.ctx.draw_rect_filled(0.0, 0.0, corner.x, corner.y, gg.gray)
	app.snake.render(app.render_velocity, app.ctx)
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
				.v {
					app.render_velocity = !app.render_velocity
				}
				else {}
			}
		}
		.mouse_down {
			// start by getting the head at the mouse
			proc_anim.front_go_to(mut app.snake.points, app.snake.pos_constraints, app.snake.angle_constraints,
				app.target, 1)
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
	dt := 0.1
	// stock the previous position to calcul the velocity later
	prec_pos := snake.points.clone()
	// apply external forces
	snake.apply_force(dt, gravity.mul_scalar(snake.node_weight))
	// apply constrains
	// proc_anim.front_to_back(mut snake.points, snake.pos_constraints, snake.angle_constraints)
	proc_anim.front_go_to(mut snake.points, snake.pos_constraints, snake.angle_constraints,
		snake.points[0], 1)
	// apply the constrains + the change of position of the head
	for i in 0 .. snake.velocity.len {
		snake.velocity[i] = (snake.points[i] - prec_pos[i]).div_scalar(dt)
	}
}

fn (mut snake Snake) apply_force(dt f64, externals_forces ...vec.Vec2[f64]) {
	// sum externals_forces
	mut total := vec.Vec2[f64]{}
	for force in externals_forces {
		total += force
	}
	for i in 0 .. snake.points.len {
		mut point_total := total
		if exterior_y(snake.points[i], snake.pos_constraints[i] + 1) {
			normal := vec.Vec2[f64]{
				y: 1
			}
			point_total, snake.velocity[i] = touch(point_total, snake.velocity[i], normal, 0.7)
		}
		if exterior_x(snake.points[i], snake.pos_constraints[i] + 1) {
			normal := vec.Vec2[f64]{
				x: -1
			}
			point_total, snake.velocity[i] = touch(point_total, snake.velocity[i], normal, 0.7)
		}
		// m*a = sum forces
		acceleration := point_total.div_scalar(snake.node_weight)
		// dpos = a*dt²/2 + v*dt
		snake.points[i] += acceleration.mul_scalar(dt * dt / 2) + snake.velocity[i].mul_scalar(dt)
	}
}

fn touch(point_total vec.Vec2[f64], velocity vec.Vec2[f64], normal vec.Vec2[f64], compensation f64) (vec.Vec2[f64], vec.Vec2[f64]) {
	return point_total.perpendicular(normal), velocity.perpendicular(normal) - velocity.project(normal).mul_scalar(compensation)
}

fn exterior_y(point vec.Vec2[f64], radius f64) bool {
	return 0 + radius > point.y || point.y > corner.y - radius
}

fn exterior_x(point vec.Vec2[f64], radius f64) bool {
	return 0 + radius > point.x || point.x > corner.x - radius
}

fn (snake Snake) render(render_velocity bool, ctx gg.Context) {
	if render_velocity {
		graphic_debug.basic_render(ctx, snake.points, snake.pos_constraints, gg.white)
		for i, v in snake.velocity {
			x := snake.points[i].x
			y := snake.points[i].y
			ctx.draw_line(f32(x), f32(y), f32(x + v.x), f32(y + v.y), gg.blue)
		}
	} else {
		graphic_debug.angular_render(ctx, snake.points, snake.pos_constraints, gg.white)
	}
}
