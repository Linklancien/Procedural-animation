module proc_anim

import gg
import math.vec

pub interface Creature {
	update(mut user User, cible vec.Vec2[f32])
	render(user User)
	mut:
		initialisation(mut user User)
}

// Snake
pub struct Snake{
	pub mut:
		body	[]int
		spine	Chain
}

fn (mut snake Snake) initialisation(mut user User){
	mid := vec.Vec2[f32]{x: user.win_width/2, y: user.win_height/2}

	for index, taille in snake.body{
        user.list_anchor << Anchor{pos: mid + vec.Vec2[f32]{x: 5*index}, radius: taille}
	}
	len := snake.body.len
	
	snake.spine = Chain{body_anchor_index: []int{len: len, init: user.list_anchor.len - len + index}}
}

fn (snake Snake) update(mut user User, cible vec.Vec2[f32]){
	snake.spine.front_go_to(mut user, cible)
}

fn  (snake Snake) render(user User){
	snake.spine.render(user)
}

// Arm
pub struct Arm{
	pub mut:
		pos		vec.Vec2[f32]
		body	[]int
		spine	Chain
}

fn (mut arm Arm) initialisation(mut user User){
	mid := arm.pos

    for taille in arm.body{
        user.list_anchor << Anchor{pos: mid, radius: taille}
	}
	len := arm.body.len

	arm.spine = Chain{body_anchor_index: []int{len: len, init: user.list_anchor.len - len + index}}
}

fn (arm Arm) update(mut user User, cible vec.Vec2[f32]){
	arm.spine.fabrik(mut user, cible)
}

fn  (arm Arm) render(user User){
	arm.spine.render(user)
}

// Corp
pub struct Corp{
	pub mut:
		pos			vec.Vec2[f32]
		left_arm	Arm
		right_arm	Arm

		left_leg	Arm
		right_leg	Arm
}

fn (mut corp Corp) initialisation(mut user User){
	// left_arm
	mut left_arm    := []int{len: 6, init: 5}
    left_arm[0]     = 10
    left_arm[left_arm.len - 1]    = 10
    corp.left_arm = Arm{pos: corp.pos + vec.Vec2[f32]{x: 10, y: -20}, body: left_arm}

	// right_arm
	mut right_arm    := []int{len: 6, init: 5}
    right_arm[0]     = 10
    right_arm[right_arm.len - 1]    = 10
    corp.right_arm = Arm{pos: corp.pos + vec.Vec2[f32]{x: -10, y: -20}, body: right_arm}

	// left_leg
	mut left_leg    := []int{len: 4, init: 5}
    left_leg[0]     = 10
    left_leg[left_leg.len - 1]    = 10
    corp.left_leg = Arm{pos: corp.pos + vec.Vec2[f32]{x: 10, y: 30}, body: left_leg}

	// right_leg
	mut right_leg    := []int{len: 4, init: 5}
    right_leg[0]     = 10
    right_leg[right_leg.len - 1]    = 10
    corp.right_leg = Arm{pos: corp.pos + vec.Vec2[f32]{x: -10, y: 30}, body: right_leg}

	// initialisation difs part
	corp.left_arm.initialisation(mut user)
	corp.right_arm.initialisation(mut user)
	corp.left_leg.initialisation(mut user)
	corp.right_leg.initialisation(mut user)
}

fn (corp Corp) update(mut user User, cible vec.Vec2[f32]){
	corp.left_arm.update(mut user, cible)
	corp.right_arm.update(mut user, cible)

	corp.left_leg.update(mut user, cible)
	corp.right_leg.update(mut user, cible)
}

fn  (corp Corp) render(user User){
	corp.left_arm.render(user)
	corp.right_arm.render(user)

	corp.left_leg.render(user)
	corp.right_leg.render(user)

	x :=	f32(corp.pos.x)
	y :=	f32(corp.pos.y)
	radius :=	10

	c :=	gg.white

	user.ctx.draw_circle_empty(x, y, radius, c)
	user.ctx.draw_circle_empty(x, y + 20, radius, c)
}
