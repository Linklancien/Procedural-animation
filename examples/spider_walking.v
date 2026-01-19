import gg
import sokol.sgl
import graphic_debug
import linklancien.procanim
import math
import math.vec

const bg_color = gg.Color{}
const render_debug = true

struct App {
mut:
	ctx      &gg.Context = unsafe { nil }
	text_cfg gg.TextCfg

	x_mouse    int
	y_mouse    int
	win_width  int
	win_height int

	target vec.Vec2[f64]

	spider Spider
}

fn main() {
	mut app := &App{}
	app.ctx = gg.new_context(
		width:         app.win_width
		height:        app.win_height
		create_window: true
		window_title:  '- Procedural Animation walking spider -'
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

	app.spider = Spider.create()
}

fn on_frame(mut app App) {
	app.spider.update(app.target)
	// Draw
	app.ctx.begin()
	app.spider.render(app.ctx)
	line_render(app.ctx)
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
				else {}
			}
		}
		else {}
	}
}

// Chain
struct Chain {
	color             gg.Color
	pos_constraints   []f64
	angle_constraints []f64
mut:
	points []vec.Vec2[f64]
}

fn Chain.create_fixed(color gg.Color, len int, pos_constraint f64, angle_constraint f64) Chain {
	return Chain{
		color:             color
		pos_constraints:   []f64{len: len, init: pos_constraint}
		angle_constraints: []f64{len: len, init: angle_constraint}
		points:            []vec.Vec2[f64]{len: len, init: vec.Vec2[f64]{
			x: 1
		}.mul_scalar(len - index)}
	}
}

enum Updates_type {
	goto
	fabrik
}

fn (mut chain Chain) update(target vec.Vec2[f64], update Updates_type) {
	match update {
		.goto {
			procanim.front_go_to(mut chain.points, chain.pos_constraints, chain.angle_constraints,
				target, 1)
		}
		.fabrik {
			procanim.fabrik(mut chain.points, chain.pos_constraints, chain.angle_constraints,
				target, 1)
		}
	}
}

fn (chain Chain) render(ctx gg.Context, pos vec.Vec2[f64]) {
	x := f32(pos.x)
	y := f32(pos.y)
	graphic_debug.filled_render_at(ctx, x, y, chain.points, chain.pos_constraints, chain.color)
	if render_debug {
		graphic_debug.basic_render_at(ctx, x, y, chain.points, chain.pos_constraints,
			gg.red)
	}
}

// Spider
struct Spider {
mut:
	legs  []Leg
	chain Chain
}

fn Spider.create() Spider {
	len := 5
	pos_constraint := 20.0
	angle_constraint := math.pi * 2 / 6
	ids := [1, 1, 4, 4]
	return Spider{
		legs:  []Leg{len: 4, init: Leg.create(ids[index])}
		chain: Chain.create_fixed(gg.gray, len, pos_constraint, angle_constraint)
	}
}

fn (mut spider Spider) update(head_target vec.Vec2[f64]) {
	spider.chain.update(head_target, .goto)
	ofset := [10, -10, 10, -10]
	for i, mut leg in mut spider.legs {
		if target := get_target(spider.chain.points[leg.id_body_part].x + leg.chain.points[0].x +
			ofset[i], 50)
		{
			leg.chain.update(target - spider.chain.points[leg.id_body_part], .fabrik)
		}
	}
}

fn get_target(x f64, radius f64) !vec.Vec2[f64] {
	rsquared := radius * radius
	for r in -100 .. 101 {
		value := f(x + r)
		if value * value + (x + r) * (x + r) - rsquared == 0 {
			return vec.Vec2[f64]{
				x: x + r
				y: value
			}
		}
	}
}

fn calc_surface(x f64) f64 {
	return 15 * math.sin(x / 30) + 200
}

fn line_render(ctx gg.Context) {
	c := gg.white
	if c.a != 255 {
		sgl.load_pipeline(ctx.pipeline.alpha)
	}
	sgl.c4b(c.r, c.g, c.b, c.a)
	sgl.begin_line_strip()

	for x in 0 .. 1092 {
		sgl.v2f(x, f32(calc_surface(x)))
	}
	sgl.end()
}

fn (spider Spider) render(ctx gg.Context) {
	spider.chain.render(ctx, vec.Vec2[f64]{})
	for leg in spider.legs {
		leg.render(ctx, spider.chain.points[leg.id_body_part])
	}
}

// Leg
struct Leg {
mut:
	id_body_part int
	chain        Chain
}

fn Leg.create(id int) Leg {
	len := 5
	pos_constraint := 10.0
	angle_constraint := math.pi * 2 / 6
	return Leg{
		chain:        Chain.create_fixed(gg.gray, len, pos_constraint, angle_constraint)
		id_body_part: id
	}
}

fn (leg Leg) render(ctx gg.Context, pos vec.Vec2[f64]) {
	leg.chain.render(ctx, pos)
}
