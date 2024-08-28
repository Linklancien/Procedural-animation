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

	// Starts positions
	corp.pos = app.list_anchor[corp.body_anchor_index[0]].pos
	app.list_anchor[corp.body_anchor_index[1]].pos = corp.pos + Vector{y: 20}
	corp.left_arm.start_pos		= corp.pos + Vector{x: -10, y: -20}
	corp.right_arm.start_pos	= corp.pos + Vector{x: 10, y: -20}

	corp.left_leg.start_pos		= corp.pos + Vector{x: 0, y: 30}
	corp.right_leg.start_pos	= corp.pos + Vector{x: 0, y: 30}

	corp.left_leg.end_pos		= corp.left_leg.start_pos	+ Vector{x: -40, y: 80}
	corp.right_leg.end_pos		= corp.right_leg.start_pos	+ Vector{x: 40, y: 80}
}

fn (mut corp Corp) update(mut app App, cible Vector){
	corp.ajustement(mut app)

	corp.left_arm.update(mut app, cible)
	corp.right_arm.update(mut app, cible)

	corp.left_leg.update(mut app, corp.left_leg.end_pos)
	corp.right_leg.update(mut app, corp.right_leg.end_pos)

	corp.gravity(mut app)
	corp.collisions(mut app)
}

fn (mut corp Corp) gravity(mut app App){
	if corp.is_gravity(mut app){
		corp.left_leg.end_pos	+= app.gravity
		corp.right_leg.end_pos	+= app.gravity
		for id in corp.body_anchor_index{
			app.list_anchor[id].pos += app.gravity
		}
	}
}

fn (mut corp Corp) is_gravity(mut app App) bool{
	for id in corp.body_anchor_index{
		mut pos		:= app.list_anchor[id].pos
		mut radius	:= app.list_anchor[id].radius
		for box in app.list_box{
			if box.is_collide_circle(pos, radius){
				return false
			}
		}
	}
	return true
}

fn (mut corp Corp) collisions(mut app App){
	for id in corp.body_anchor_index{
		mut change := Vector{}
		mut pos		:= app.list_anchor[id].pos
		mut radius	:= app.list_anchor[id].radius
		for box in app.list_box{
			if box.is_collide_circle(pos, radius){
				change += Vector{y: -1}
			}
		}
		app.list_anchor[id].pos += change
	}
}

fn (mut corp Corp) ajustement(mut app App){
	corp.pos = app.list_anchor[corp.body_anchor_index[0]].pos
	app.list_anchor[corp.body_anchor_index[1]].pos = corp.pos + Vector{y: 20}
	corp.left_arm.start_pos		= corp.pos + Vector{x: -10, y: -20}
	corp.right_arm.start_pos	= corp.pos + Vector{x: 10, y: -20}

	corp.left_leg.start_pos		= corp.pos + Vector{x: 0, y: 30}
	corp.right_leg.start_pos	= corp.pos + Vector{x: 0, y: 30}

	if corp.left_leg.end_pos.x < corp.pos.x -60{
		corp.left_leg.end_pos	= corp.left_leg.start_pos	+ Vector{x: 40, y: 80}
	}
	else if corp.left_leg.end_pos.x > corp.pos.x +60{
		corp.left_leg.end_pos	= corp.left_leg.start_pos	+ Vector{x: -40, y: 80}
	}
	if corp.right_leg.end_pos.x < corp.pos.x -60{
		corp.right_leg.end_pos	= corp.right_leg.start_pos	+ Vector{x: 40, y: 80}
	}
	else if corp.right_leg.end_pos.x > corp.pos.x +60{
		corp.right_leg.end_pos	= corp.right_leg.start_pos	+ Vector{x: -40, y: 80}
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