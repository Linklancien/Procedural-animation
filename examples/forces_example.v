import gg
import linklancien.proc_anim
import graphic_debug
import math
import math.vec

const bg_color = gg.Color{}
const gravity = vec.Vec2[f64]{
	y: 10
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
	app.snake.update(app.target)
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
				else {}
			}
		}
		else {}
	}
}

// Snake
struct Snake {
	node_weight       f64 = 100
	pos_constraints   []f64
	angle_constraints []f64
mut:
	// those fields have the same len
	points   []vec.Vec2[f64]
	velocity []vec.Vec2[f64]
}

fn (mut snake Snake) update(target vec.Vec2[f64]) {
	dt := 1.0

	prec_pos := snake.points.clone()
	snake.apply_force(dt, gravity.mul_scalar(snake.node_weight))
	proc_anim.front_go_to(mut snake.points, snake.pos_constraints, snake.angle_constraints,
		target, 1)
	for i in 0..snake.velocity.len{
		snake.velocity[i] = (snake.points[i] - prec_pos[i]).div_scalar(dt)
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
			&& snake.points[i].y < 600 {
			snake.points[i] += acceleration.mul_scalar(dt * dt / 2) + snake.velocity[i].mul_scalar(dt)
			// if i != 0{
			// 	droite := (snake.points[i - 1] - snake.points[i]).normalize()
			// 	a := acceleration.perpendicular(droite)
			// 	println('E')
			// 	println(acceleration)
			// 	println(droite)
			// 	println(acceleration.project(droite))
			// 	println(a)
			// 	pos = dpos + V0*dt			
			// 	snake.velocity[i] += a.mul_scalar(dt)
			// 	println(snake.velocity[i])
			// }
		}
	}
}

fn (snake Snake) render(ctx gg.Context) {
	graphic_debug.angular_render(ctx, snake.points, snake.pos_constraints, gg.white)
}
