import gg
import os
import linklancien.proc_anim
import math
import math.vec

const bg_color = gg.Color{}
const font_path = os.resource_abs_path('0xProtoNerdFontMono-Regular.ttf')

struct App {
mut:
	ctx      &gg.Context = unsafe { nil }
	text_cfg gg.TextCfg

	x_mouse    int
	y_mouse    int
	win_width  int
	win_height int

	list_crea   []proc_anim.Creature
	list_anchor []proc_anim.Anchor

	target vec.Vec2[f32]
}

fn main() {
	mut app := &App{}
	app.ctx = gg.new_context(
		width:         app.win_width
		height:        app.win_height
		fullscreen:    false
		create_window: true
		window_title:  '- Animation Procedural -'
		user_data:     app
		bg_color:      bg_color
		frame_fn:      on_frame
		init_fn:       on_init
		event_fn:      on_event
		sample_count:  2
		font_path:     font_path
	)

	// lancement du programme/de la fenêtre
	app.ctx.run()
}

fn on_init(mut app App) {
	size := app.ctx.window_size()
	app.win_width = size.width
	app.win_height = size.height

	body_snake := []int{len: 20, init: (5)}
	app.list_crea << Snake{
		body: body_snake
	}

	// mut body_arm := []int{len: 12, init: 5}
	// body_arm[0] = 10
	// body_arm[body_arm.len - 1] = 10
	// app.list_crea << pre_build.Arm{
	// 	pos:  vec.Vec2[f32]{
	// 		x: app.win_width * 2 / 3
	// 		y: app.win_height / 2
	// 	}
	// 	body: body_arm
	// }

	// app.list_crea << pre_build.Corp{pos: vec.Vec2[f32]{x: app.win_width/3 ,y: app.win_height/2}}

	for mut crea in app.list_crea {
		crea.initialisation(mut app)
	}
}

fn on_frame(mut app App) {
	// Draw
	app.ctx.begin()

	for crea in app.list_crea {
		crea.update(mut app, app.target)
		crea.render(app)
	}
	app.ctx.end()
}

fn on_event(e &gg.Event, mut app App) {
	size := app.ctx.window_size()
	app.win_width = size.width
	app.win_height = size.height

	app.x_mouse, app.y_mouse = int(e.mouse_x), int(e.mouse_y)
	app.target = vec.Vec2[f32]{
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

fn (app App) text_rect_render(x int, y int, corner bool, text_brut string, transparence u8) {
	text_split := text_brut.split('\n')

	mut text_len := []int{cap: text_split.len}
	mut max_len := 0

	// Precalcul
	for text in text_split {
		lenght := text.len * 8 + 10
		text_len << lenght

		if lenght > max_len {
			max_len = lenght
		}
	}

	// affichage
	mut new_x := x
	if corner == false {
		new_x -= max_len / 2
	}

	app.ctx.draw_rounded_rect_filled(new_x, y, max_len, app.text_cfg.size * text_split.len + 10,
		5, attenuation(gg.gray, transparence))
	for id, text in text_split {
		new_y := y + app.text_cfg.size * id
		app.ctx.draw_text(new_x + 5, new_y + 5, text, app.text_cfg)
	}
}

fn attenuation(color gg.Color, new_a u8) gg.Color {
	return gg.Color{color.r, color.g, color.b, new_a}
}


// Creas

// Snake
pub struct Snake {
pub mut:
	body  []int
	spine proc_anim.Chain
}

fn (mut snake Snake) initialisation(mut user proc_anim.User) {
	mid := vec.Vec2[f32]{
		x: user.win_width / 2
		y: user.win_height / 2
	}

	for index, taille in snake.body {
		user.list_anchor << proc_anim.Anchor{
			pos:    mid + vec.Vec2[f32]{
				x: 5 * index
			}
			radius: taille
		}
	}
	len := snake.body.len

	snake.spine = proc_anim.Chain{
		body_anchor_index: []int{len: len, init: user.list_anchor.len - len + index}
		angle_minimum:     math.pi * 5 / 6
	}
}

fn (snake Snake) update(mut user proc_anim.User, cible vec.Vec2[f32]) {
	snake.spine.front_go_to(mut user, cible)
}

fn (snake Snake) render(user proc_anim.User) {
	snake.spine.render(user)
}