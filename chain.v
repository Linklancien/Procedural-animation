import gx
import math

struct Chain {
	body_anchor_index			[]int
	vert_radius		int	= 10
	angle_minimum	f64	= math.pi/8
}

// Contraintes multiples
fn (chain Chain) front_go_to(mut app App, cible Vector){
	chain.front_to_back_update_pos(mut app, cible)

	chain.front_to_back_update_angle(mut app)
}

fn (chain Chain) fabrik(mut app App, cible Vector){
	center := app.list_anchor[chain.body_anchor_index[0]].pos
	chain.front_to_back_update_pos(mut app, cible)
	
	chain.back_to_front_update_pos(mut app, center)
}


// Contraintes de positions selon la position des autres maillons
fn (chain Chain) front_to_back_update_pos(mut app App, cible Vector){
	// Pos
	for index in 0..chain.body_anchor_index.len{
		anchor_id := chain.body_anchor_index[index]
		
		if index == 0{
			// Déplacement du bout, ici le premier
			ref := (cible - app.list_anchor[anchor_id].pos)
			if ref.len() > 10{
				app.list_anchor[anchor_id].pos += mult(5, ref.normalize())
			}
		}
		else{
			// Contraintes des maillons de la chaine au maillon précédent
			rel		:= app.list_anchor[chain.body_anchor_index[index - 1]].pos
			mut new	:= mult(chain.vert_radius, (app.list_anchor[anchor_id].pos - rel).normalize()) + rel
			app.list_anchor[anchor_id].pos = new
		}
	}
}

fn (chain Chain) back_to_front_update_pos(mut app App, cible Vector){
	// Pos
	for index_revers in 1..chain.body_anchor_index.len - 1{
		index := chain.body_anchor_index.len - index_revers

		anchor_id := chain.body_anchor_index[index]

		if index == 1{
			// Déplacement du bout ici le dernier
			ref := (cible - app.list_anchor[anchor_id].pos)
			if ref.len() > 10{
				app.list_anchor[anchor_id].pos += mult(5, ref.normalize())
			}
		}
		else{
			// Contraintes des maillons de la chaine au maillon précédent
			rel		:= app.list_anchor[chain.body_anchor_index[index + 1]].pos
			mut new	:= mult(chain.vert_radius, (app.list_anchor[anchor_id].pos - rel).normalize()) + rel
			app.list_anchor[anchor_id].pos = new
		}
	}
}

// Contraintes de positions selon l'angles avec les autres maillons
fn (chain Chain) front_to_back_update_angle(mut app App){
	// Angle
	mut preced_angle := simplify_angle((app.list_anchor[chain.body_anchor_index[1]].pos - app.list_anchor[chain.body_anchor_index[0]].pos).angle_trigo())
	
	for index in 1..chain.body_anchor_index.len - 1{
		// Expression de la pos du suivant par rapport a l'actuel
		position_relative	:= app.list_anchor[chain.body_anchor_index[index + 1]].pos - app.list_anchor[chain.body_anchor_index[index]].pos	// OA - OR = RO + OA = RO

		// Calcul de l'angle entre les deux point
		angle_calcul := position_relative.angle_trigo()

		preced_angle = angle_contraint(angle_calcul, preced_angle, chain.angle_minimum)
		
		app.list_anchor[chain.body_anchor_index[index + 1]].pos = app.list_anchor[chain.body_anchor_index[index]].pos + position_relative.turn(preced_angle - angle_calcul)
	}
}

fn (chain Chain) back_to_front_update_angle(mut app App){
	// Angle
	mut preced_angle := simplify_angle((app.list_anchor[chain.body_anchor_index[chain.body_anchor_index.len - 2]].pos - app.list_anchor[chain.body_anchor_index[chain.body_anchor_index.len - 1]].pos).angle_trigo())
	
	for index_revers in 2..chain.body_anchor_index.len - 1{
		index := chain.body_anchor_index.len - index_revers

		// Expression de la pos du suivant par rapport a l'actuel
		position_relative	:= app.list_anchor[chain.body_anchor_index[index - 1]].pos - app.list_anchor[chain.body_anchor_index[index]].pos	// OA - OR = RO + OA = RO

		// Calcul de l'angle entre les deux point
		angle_calcul := position_relative.angle_trigo()

		preced_angle = angle_contraint(angle_calcul, preced_angle, chain.angle_minimum)
		
		app.list_anchor[chain.body_anchor_index[index - 1]].pos = app.list_anchor[chain.body_anchor_index[index]].pos + position_relative.turn(preced_angle - angle_calcul)
	}
}


// Rendering
fn (chain Chain) render(app App){
	// Pos
	for anchor_id in chain.body_anchor_index{
		x :=	f32(app.list_anchor[anchor_id].pos.x)
		y :=	f32(app.list_anchor[anchor_id].pos.y)
		radius :=	f32(app.list_anchor[anchor_id].radius)

		c :=	gx.white

		app.ctx.draw_circle_empty(x, y, radius, c)
	}
}

