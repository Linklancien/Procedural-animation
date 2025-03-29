module proc_anim

import gx
import gg
import math
import math.vec

pub struct Anchor {
	mut:
		pos		vec.Vec2[f32]
		radius	f32	= 10
}

pub struct Chain {
	body_anchor_index	[]int
	vert_radius			int	= 10
	angle_minimum		f32	= math.pi*2/3
}

pub interface User{
	mut:
	ctx			&gg.Context

    x_mouse     int
    y_mouse     int
    win_width   int
	win_height  int

    list_crea   []proc_anim.Creature
    list_anchor []proc_anim.Anchor

    target      vec.Vec2[f32]
}

// Contraintes multiples
pub fn (chain Chain) front_go_to(mut user User, cible vec.Vec2[f32]){
	chain.front_to_back_update_pos(mut user, cible, false)

	chain.front_to_back_update_angle(mut user, cible)
}

pub fn (chain Chain) fabrik(mut user User, cible vec.Vec2[f32]){
	center := user.list_anchor[chain.body_anchor_index[chain.body_anchor_index.len - 1]].pos

	chain.front_to_back_update_pos(mut user, cible, true)
	
	chain.back_to_front_update_pos(mut user, center, true)
}


// Contraintes de positions selon la position des autres maillons
pub fn (chain Chain) front_to_back_update_pos(mut user User, cible vec.Vec2[f32], instant bool){
	// Pos
	for index in 0..chain.body_anchor_index.len{
		anchor_id := chain.body_anchor_index[index]
		
		if index == 0{
			// Déplacement du bout, ici le premier
			if instant{
				user.list_anchor[anchor_id].pos = cible
			}
			else{
				ref := (cible - user.list_anchor[anchor_id].pos)
				if ref.magnitude() > 10{
					user.list_anchor[anchor_id].pos += ref.normalize().mul_scalar[f32](5)
				}
			}
		}
		else{
			// Contraintes des maillons de la chaine au maillon précédent
			rel		:= user.list_anchor[chain.body_anchor_index[index - 1]].pos
			mut new	:= (user.list_anchor[anchor_id].pos - rel).normalize().mul_scalar[f32](chain.vert_radius) + rel
			user.list_anchor[anchor_id].pos = new
		}
	}
}
 
pub fn (chain Chain) back_to_front_update_pos(mut user User, cible vec.Vec2[f32], instant bool){
	// Pos
	for index_revers in 1..chain.body_anchor_index.len + 1{
		index := chain.body_anchor_index.len - index_revers

		anchor_id := chain.body_anchor_index[index]

		if index == chain.body_anchor_index.len - 1{
			// Déplacement du bout ici le dernier
			if instant{
				user.list_anchor[anchor_id].pos = cible
			}
			else{
				ref := (cible - user.list_anchor[anchor_id].pos)
				if ref.magnitude() > 10{
					user.list_anchor[anchor_id].pos += ref.normalize().mul_scalar[f32](5)
				}
			}
		}
		else{
			// Contraintes des maillons de la chaine au maillon précédent
			rel		:= user.list_anchor[chain.body_anchor_index[index + 1]].pos
			mut new	:= (user.list_anchor[anchor_id].pos - rel).normalize().mul_scalar[f32](chain.vert_radius) + rel
			user.list_anchor[anchor_id].pos = new
		}
	}
}


// Contraintes de positions selon l'angles avec les autres maillons
pub fn (chain Chain) front_to_back_update_angle(mut user User, cible vec.Vec2[f32]){
	constraint_angle(user.list_anchor[chain.body_anchor_index[0]].pos, cible, mut user.list_anchor[chain.body_anchor_index[1]].pos, chain.vert_radius, chain.angle_minimum)

	for index in 1..chain.body_anchor_index.len - 1{
		constraint_angle(user.list_anchor[chain.body_anchor_index[index]].pos, user.list_anchor[chain.body_anchor_index[index - 1]].pos, mut user.list_anchor[chain.body_anchor_index[index + 1]].pos, chain.vert_radius, chain.angle_minimum)
	}
}

pub fn (chain Chain) back_to_front_update_angle(mut user User , cible vec.Vec2[f32]){
	constraint_angle(user.list_anchor[chain.body_anchor_index[chain.body_anchor_index.len - 1]].pos, cible, mut user.list_anchor[chain.body_anchor_index[chain.body_anchor_index.len - 2]].pos, chain.vert_radius, chain.angle_minimum)
	
	for index_revers in 2..chain.body_anchor_index.len - 1{
		index := chain.body_anchor_index.len - index_revers
		constraint_angle(user.list_anchor[chain.body_anchor_index[index]].pos, user.list_anchor[chain.body_anchor_index[index + 1]].pos, mut user.list_anchor[chain.body_anchor_index[index - 1]].pos, chain.vert_radius, chain.angle_minimum)
	}
}

pub fn constraint_angle(pos vec.Vec2[f32], prev vec.Vec2[f32], mut next vec.Vec2[f32], radius f32, minimum f32){
	prev_angle := pos.angle_towards(prev)
	angle := pos.angle_towards(next)
	dif := angle - prev_angle
	if math.abs(dif) < minimum  {
		if dif > 0{
			next = pos + vec.vec2(radius, f32(0.0)).rotate_around_ccw(vec.vec2(f32(0.0), f32(0.0)), prev_angle + minimum)
		}
		else if dif < 0{
			next = pos + vec.vec2(radius, f32(0.0)).rotate_around_ccw(vec.vec2(f32(0.0), f32(0.0)), prev_angle - minimum)
		}
	}
}

// Rendering
pub fn (chain Chain) render(user User){
	// Pos
	for anchor_id in chain.body_anchor_index{
		x :=	f32(user.list_anchor[anchor_id].pos.x)
		y :=	f32(user.list_anchor[anchor_id].pos.y)
		radius :=	f32(user.list_anchor[anchor_id].radius)

		c :=	gx.white

		user.ctx.draw_circle_empty(x, y, radius, c)
	}
}

