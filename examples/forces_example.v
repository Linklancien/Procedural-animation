import gg
import linklancien.proc_anim
import graphic_debug
import math
import math.vec

const bg_color = gg.Color{}
const gravity = vec.Vec2[f64]{
	// x: 10
	y: 10
}
const corner = vec.Vec2[f32]{
	x: 600
	y: 600
}
const surfaces = [
	Surfaces{
		point:  vec.Vec2[f64]{
			y: corner.y
		}
		normal: vec.Vec2[f64]{
			y: 1
		}
	},
	Surfaces{
		point:  vec.Vec2[f64]{
			x: corner.x
		}
		normal: vec.Vec2[f64]{
			x: -1
		}
	},
]

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
	move   bool

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
			app.snake.update(mut app)
		}
		.step {
			app.snake.update(mut app)
			app.run_method = .pause
		}
		else {
			if app.move {
				proc_anim.front_go_to(mut app.snake.points, app.snake.pos_constraints,
					app.snake.angle_constraints, app.target, 1)
				app.move = false
			}
		}
	}
	// Draw
	app.ctx.begin()
	app.ctx.draw_rect_filled(0.0, 0.0, corner.x, corner.y, gg.gray)
	app.snake.render(app.render_velocity, app.ctx)
	app.ctx.draw_circle_filled(corner.x, corner.y, 10, gg.red)
	app.ctx.end()
}

fn on_event(e &gg.Event, mut app App) {
	size := app.ctx.window_size()
	app.win_width = size.width
	app.win_height = size.height

	app.x_mouse, app.y_mouse = int(e.mouse_x), int(e.mouse_y)
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
			// prepare the mouvement
			app.move = true
			app.target = vec.Vec2[f64]{
				x: app.x_mouse
				y: app.y_mouse
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

fn (mut snake Snake) update(mut app App) {
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

	// move the head if clicked
	if app.move {
		proc_anim.front_go_to(mut app.snake.points, app.snake.pos_constraints, app.snake.angle_constraints,
			app.target, 1)
		app.move = false
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
		point_total, snake.velocity[i] = boundaries(snake.points[i], point_total, snake.velocity[i],
			snake.pos_constraints[i])

		// m*a = sum forces
		acceleration := point_total.div_scalar(snake.node_weight)
		// dpos = a*dt²/2 + v*dt
		snake.points[i] += acceleration.mul_scalar(dt * dt / 2) + snake.velocity[i].mul_scalar(dt)
	}
}

// collisions:
struct Surfaces {
	point  vec.Vec2[f64]
	normal vec.Vec2[f64]
}

fn boundaries(pos vec.Vec2[f64], point_total vec.Vec2[f64], velocity vec.Vec2[f64], radius f64) (vec.Vec2[f64], vec.Vec2[f64]) {
	mut new_total := point_total
	mut new_velocity := velocity
	for surface in surfaces {
		dist := distance(surface.point, surface.normal, pos)
		if dist < radius {
			new_total, new_velocity = touch(new_total, new_velocity, surface.normal, 0.7)
		}
	}
	return new_total, new_velocity
}

fn touch(point_total vec.Vec2[f64], velocity vec.Vec2[f64], normal vec.Vec2[f64], compensation f64) (vec.Vec2[f64], vec.Vec2[f64]) {
	return point_total.perpendicular(normal), velocity.perpendicular(normal) - velocity.project(normal).mul_scalar(compensation)
}

fn distance(point_plan vec.Vec2[f64], normal vec.Vec2[f64], point vec.Vec2[f64]) f64 {
	diff := point - point_plan
	distance := diff.project(normal).magnitude()
	return distance
}
