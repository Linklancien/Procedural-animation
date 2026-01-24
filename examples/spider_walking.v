import gg
import sokol.sgl
import graphic_debug
import linklancien.procanim
import math
import math.vec

const bg_color = gg.Color{}
const render_debug = false

struct App {
mut:
	ctx &gg.Context = unsafe { nil }

	win_width  int = 1000
	win_height int = 700

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
	// update
	app.spider.update(app.target)
	// draw
	app.ctx.begin()
	app.spider.render(app.ctx)
	line_render(app.ctx, app.win_width)
	app.ctx.end()
}

fn on_event(e &gg.Event, mut app App) {
	size := app.ctx.window_size()
	app.win_width = size.width
	app.win_height = size.height

	app.target = vec.Vec2[f64]{
		x: int(e.mouse_x)
		y: int(e.mouse_y)
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

// ##############################################################################################################
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
		// points must be initialised with a little offset
		points: []vec.Vec2[f64]{len: len, init: vec.Vec2[f64]{
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
	linked_legs [][]int
mut:
	legs  []Leg
	chain Chain
}

fn Spider.create() Spider {
	spider_len := 6
	pos_constraint := 20.0
	angle_constraint := math.pi * 2 / 6
	// legs
	leg_colors := [gg.red, gg.blue, gg.dark_blue, gg.dark_red] //, gg.light_red, gg.light_blue]
	nb_leg := leg_colors.len
	mut linked_legs := [][]int{len: spider_len}
	for i in 0 .. nb_leg {
		linked_legs[create_ids(i)] << i
	}
	return Spider{
		linked_legs: linked_legs
		legs:        []Leg{len: nb_leg, init: Leg.create(create_ids(index), leg_colors[index])}
		chain:       Chain.create_fixed(gg.gray, spider_len, pos_constraint, angle_constraint)
	}
}

fn create_ids(index int) int {
	match index {
		0, 1 {
			return 1
		}
		2, 3 {
			return 5
		}
		4, 5 {
			return 3
		}
		else {
			panic('case not handle')
		}
	}
}

fn (mut spider Spider) update(head_target vec.Vec2[f64]) {
	// start moving things
	spider.chain.update(head_target, .goto)

	// the code inside the loop may be placed elsewhere
	for mut leg in mut spider.legs {
		leg.new_target(spider.chain.points[leg.id_body_part], false)
	}

	for leg_linked_to_bodypart in spider.linked_legs {
		if leg_linked_to_bodypart.len > 1 {
			id0 := leg_linked_to_bodypart[0]
			id1 := leg_linked_to_bodypart[1]
			if spider.legs[id0].chain.points[0].distance(spider.legs[id1].chain.points[0]) <= 20 {
				spider.legs[id0].new_target(spider.chain.points[spider.legs[id0].id_body_part],
					true)
			}
		}
	}
}

fn (spider Spider) render(ctx gg.Context) {
	spider.chain.render(ctx, vec.Vec2[f64]{})
	for leg in spider.legs {
		leg.render(ctx, spider.chain.points[leg.id_body_part])
	}
}

// Leg
struct Leg {
	radius f64
mut:
	id_body_part    int
	chain           Chain
	absolute_target vec.Vec2[f64]
}

fn Leg.create(id int, color gg.Color) Leg {
	len := 6
	pos_constraint := 10.0
	angle_constraint := math.pi * 2 / 6
	return Leg{
		chain:        Chain.create_fixed(color, len, pos_constraint, angle_constraint)
		id_body_part: id
		radius:       len * pos_constraint
	}
}

fn (mut leg Leg) new_target(abs_pos vec.Vec2[f64], forced bool) {
	mut current_target := leg.absolute_target - abs_pos
	if current_target.magnitude() > leg.radius || forced {
		leg.absolute_target = get_target(abs_pos.x, abs_pos.y, leg.absolute_target.x,
			leg.absolute_target.y, leg.radius, [calc_surface_line, calc_surface_sin,
			calc_surface_two_sins])
		// get the new target relatively to the leg base
		current_target = leg.absolute_target - abs_pos
	}
	leg.chain.update(current_target, .fabrik)
}

fn (leg Leg) render(ctx gg.Context, pos vec.Vec2[f64]) {
	leg.chain.render(ctx, pos)
}

// Surfaces
// get_target get the further target inside a radius around a point
fn get_target(x f64, y f64, target_x f64, target_y f64, radius f64, fs []fn (f64) f64) vec.Vec2[f64] {
	rsquared := radius * radius
	mut sav_x := target_x
	mut sav_y := target_y
	mut dist_square := 0.0

	for r in -int(radius) .. int(radius) + 1 {
		for f in fs {
			value := f(x + r) - y
			// need to be cautious of which base it is
			if value * value + r * r <= rsquared {
				new_dist := calc_dist_square(target_x, target_y, x + r, f(x + r))

				if dist_square < new_dist {
					dist_square = new_dist
					sav_x = x + r
					sav_y = f(x + r)
				}
			}
		}
	}
	return vec.Vec2[f64]{
		x: sav_x // x + r
		y: sav_y // f(x + r)
	}
}

fn calc_dist_square(x1 f64, y1 f64, x2 f64, y2 f64) f64 {
	return (x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2)
}

fn calc_surface_line(x f64) f64 {
	return 200
}

fn calc_surface_sin(x f64) f64 {
	return 5 * math.sin(x / 30) + 400
}

fn calc_surface_two_sins(x f64) f64 {
	return 10 * math.sin(x / 30) + 5 * math.sin(x / 20) + 600
}

fn line_render(ctx gg.Context, len int) {
	c := gg.white
	if c.a != 255 {
		sgl.load_pipeline(ctx.pipeline.alpha)
	}
	sgl.c4b(c.r, c.g, c.b, c.a)

	sgl.begin_line_strip()
	for x in 0 .. len {
		sgl.v2f(x, f32(calc_surface_line(x)))
	}
	sgl.end()

	sgl.begin_line_strip()
	for x in 0 .. len {
		sgl.v2f(x, f32(calc_surface_sin(x)))
	}
	sgl.end()

	sgl.begin_line_strip()
	for x in 0 .. len {
		sgl.v2f(x, f32(calc_surface_two_sins(x)))
	}
	sgl.end()
}
