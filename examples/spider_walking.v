import gg
import linklancien.procanim
import graphic_debug
import math { cos, sin }
import math.vec
import sokol.sgl

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
	app.spider.render(app.ctx, render_debug)
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
struct Chain{
  pos_constraints   []f64
	angle_constraints []f64
mut:
	points []vec.Vec2[f64]
}

fn Chain.create_fixed(len int, pos_constraint f64, angle_constraint f64) Chain{
  return Chain{
    pos_constraints:   []f64{len: len, init: pos_constraint}
  	angle_constraints: []f64{len: len, init: angle_constraint}
  	points: []vec.Vec2[f64]{len: len, init: vec.Vec2[f64]{x: 1}.mul_scalar(len - index)}
  }
}

enum Updates_type{
  goto
  fabrik
}

fn (mut chain Chain) update(target vec.Vec2[f64], update Updates_type){
  match update{
    .goto{
      procanim.front_go_to(mut chain.points, chain.pos_constraints, chain.angle_constraints,
		target, 1)
    }
    .fabrik{
      procanim.fabrik(mut chain.points, chain.pos_constraints, chain.angle_constraints, target, 1)
    }
  }
}

fn (chain Chain) render(ctx gg.Context, render_debug bool){
  filled_render(ctx, chain.points, chain.pos_constraints, gg.white)
  if render_debug{
	  graphic_debug.basic_render(ctx, chain.points, chain.pos_constraints, gg.red)
	}
}

pub fn filled_render(ctx gg.Context, points []vec.Vec2[f64], radius []f64, c gg.Color) {
	if c.a != 255 {
		sgl.load_pipeline(ctx.pipeline.alpha)
	}
	sgl.c4b(c.r, c.g, c.b, c.a)
	sgl.begin_triangle_strip()

	// max := points.len - 1
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
			// max {
			//   println('max')
			// }
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

// Spider
struct Spider {
	legs []Leg
mut:
	chain Chain
}

fn Spider.create() Spider{
  len := 5
  pos_constraint := 20.0
  angle_constraint := math.pi * 2 / 6
  ids := [1, 1, 4, 4]
  return Spider{
    legs: []Leg{len: 4, init: Leg.create(ids[index]) }
    chain: Chain.create_fixed(len, pos_constraint, angle_constraint)
  }
}

fn (mut spider Spider) update(target vec.Vec2[f64]) {
	spider.chain.update(target, .goto)
}

fn (spider Spider) render(ctx gg.Context, render_debug bool) {
	spider.chain.render(ctx, render_debug)
	for leg in spider.legs{
	  leg.render(ctx, render_debug, spider.chain.points[leg.id_body_part])
	}
}

// Leg
struct Leg{
  chain Chain
  id_body_part int
}

fn Leg.create(id int) Leg{
  len := 5
  pos_constraint := 10.0
  angle_constraint := math.pi * 2 / 6
  return Leg{
    chain: Chain.create_fixed(len, pos_constraint, angle_constraint)
    id_body_part: id
  }
}

fn (leg Leg) render(ctx gg.Context, render_debug bool, pos vec.Vec2[f64]){
  leg.chain.render(ctx, render_debug)
}
