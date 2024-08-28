import gx
// Corp
struct Corp{
	mut:
		pos			Vector
		body_anchor_index	[]int

		left_arm	Arm
		right_arm	Arm

		left_leg	Arm
		right_leg	Arm
}

fn (mut corp Corp) initialisation(mut app App){
	// left_arm
	mut left_arm    := []int{len: 6, init: 5}
    left_arm[0]     = 10
    left_arm[left_arm.len - 1]    = 10
    corp.left_arm = Arm{start_pos: corp.pos + Vector{x: 10, y: -20}, body: left_arm}

	// right_arm
	mut right_arm    := []int{len: 6, init: 5}
    right_arm[0]     = 10
    right_arm[right_arm.len - 1]    = 10
    corp.right_arm = Arm{start_pos: corp.pos + Vector{x: -10, y: -20}, body: right_arm}

	// left_leg
	mut left_leg    := []int{len: 4, init: 5}
    left_leg[0]     = 10
    left_leg[left_leg.len - 1]    = 10
    corp.left_leg = Arm{start_pos: corp.pos + Vector{x: 10, y: 30}, body: left_leg}

	// right_leg
	mut right_leg    := []int{len: 4, init: 5}
    right_leg[0]     = 10
    right_leg[right_leg.len - 1]    = 10
    corp.right_leg = Arm{start_pos: corp.pos + Vector{x: -10, y: 30}, body: right_leg}

	// initialisation difs part
	fist_anchor_id := app.list_anchor.len
	app.list_anchor << Anchor{pos: corp.pos}
	app.list_anchor << Anchor{pos: corp.pos + Vector{y: 20}}
	corp.left_arm.initialisation(mut app)
	corp.right_arm.initialisation(mut app)
	corp.left_leg.initialisation(mut app)
	corp.right_leg.initialisation(mut app)
	last_anchor_id := app.list_anchor.len

	corp.body_anchor_index = []int{len: last_anchor_id - fist_anchor_id, init: fist_anchor_id + index}
}

fn (mut corp Corp) update(mut app App, cible Vector){
	corp.left_arm.update(mut app, cible)
	corp.right_arm.update(mut app, cible)

	corp.left_leg.update(mut app, Vector{y: app.win_height})
	corp.right_leg.update(mut app, Vector{x: app.win_width ,y: app.win_height})

	corp.gravity(mut app)
}

fn (mut corp Corp) gravity(mut app App){
	
	for id in corp.body_anchor_index{
		app.list_anchor[id].pos += app.gravity
	}

	for id in corp.body_anchor_index{
		mut change := Vector{}
		mut pos		:= app.list_anchor[id].pos
		mut radius	:= app.list_anchor[id].radius
		for box in app.list_box{
			if box.is_collide_circle(pos, radius){
				change += Vector{y: -10}
			}
		}
		app.list_anchor[id].pos += change

		// change = Vector{}
		// pos		= app.list_anchor[id].pos
		// radius	= app.list_anchor[id].radius

		// for anchor_id in corp.body_anchor_index{
		// 	if anchor_id != id{
		// 		pos_other		:= app.list_anchor[anchor_id].pos
		// 		radius_other	:= app.list_anchor[anchor_id].radius
		// 		if circle_is_in_cirle(pos, radius, pos_other, radius_other){
		// 			app.list_anchor[id].pos = pos_other + mult((radius + radius_other), (pos_other - pos).normalize())
		// 		}
		// 	}
		// }
	}
}

// Visuels
fn  (corp Corp) render(app App){
	for anchor_id in corp.body_anchor_index{
		x :=	f32(app.list_anchor[anchor_id].pos.x)
		y :=	f32(app.list_anchor[anchor_id].pos.y)
		radius :=	f32(app.list_anchor[anchor_id].radius)

		c :=	gx.white

		app.ctx.draw_circle_empty(x, y, radius, c)
	}
}