import gx

interface Creature {
	update(mut app App, cible Vector)
	render(app App)
	mut:
		initialisation(mut app App)
}

// Snake
struct Snake{
	mut:
		body	[]int
		spine	Chain
}

fn (mut snake Snake) initialisation(mut app App){
	mid := Vector{x: app.win_width/2, y: app.win_height/2}

	for index, taille in snake.body{
        app.list_anchor << Anchor{pos: mid + Vector{x: 5*index}, radius: taille}
	}
	len := snake.body.len
	
	snake.spine = Chain{body_anchor_index: []int{len: len, init: app.list_anchor.len - len + index}}
}

fn (snake Snake) update(mut app App, cible Vector){
	snake.spine.front_go_to(mut app, cible)
}

fn  (snake Snake) render(app App){
	snake.spine.render(app)
}

// Arm
struct Arm{
	mut:
		pos		Vector
		body	[]int
		spine	Chain
}

fn (mut arm Arm) initialisation(mut app App){
	mid := arm.pos

    for taille in arm.body{
        app.list_anchor << Anchor{pos: mid, radius: taille}
	}
	len := arm.body.len

	arm.spine = Chain{body_anchor_index: []int{len: len, init: app.list_anchor.len - len + index}}
}

fn (arm Arm) update(mut app App, cible Vector){
	arm.spine.fabrik(mut app, cible)
}

fn  (arm Arm) render(app App){
	arm.spine.render(app)
}

// Corp
struct Corp{
	mut:
		pos			Vector
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
    corp.left_arm = Arm{pos: corp.pos + Vector{x: 10, y: -20}, body: left_arm}

	// right_arm
	mut right_arm    := []int{len: 6, init: 5}
    right_arm[0]     = 10
    right_arm[right_arm.len - 1]    = 10
    corp.right_arm = Arm{pos: corp.pos + Vector{x: -10, y: -20}, body: right_arm}

	// left_leg
	mut left_leg    := []int{len: 4, init: 5}
    left_leg[0]     = 10
    left_leg[left_leg.len - 1]    = 10
    corp.left_leg = Arm{pos: corp.pos + Vector{x: 10, y: 30}, body: left_leg}

	// right_leg
	mut right_leg    := []int{len: 4, init: 5}
    right_leg[0]     = 10
    right_leg[right_leg.len - 1]    = 10
    corp.right_leg = Arm{pos: corp.pos + Vector{x: -10, y: 30}, body: right_leg}

	// initialisation difs part
	corp.left_arm.initialisation(mut app)
	corp.right_arm.initialisation(mut app)
	corp.left_leg.initialisation(mut app)
	corp.right_leg.initialisation(mut app)
}

fn (corp Corp) update(mut app App, cible Vector){
	corp.left_arm.update(mut app, cible)
	corp.right_arm.update(mut app, cible)

	corp.left_leg.update(mut app, cible)
	corp.right_leg.update(mut app, cible)
}

fn  (corp Corp) render(app App){
	corp.left_arm.render(app)
	corp.right_arm.render(app)

	corp.left_leg.render(app)
	corp.right_leg.render(app)

	x :=	f32(corp.pos.x)
	y :=	f32(corp.pos.y)
	radius :=	10

	c :=	gx.white

	app.ctx.draw_circle_empty(x, y, radius, c)
	app.ctx.draw_circle_empty(x, y + 20, radius, c)
}
