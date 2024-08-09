import gx
import math

struct Snake{
	mut:
		body		[]int
		vert_radius	int	= 10
		angle_contraint	f64	= math.pi/3
}

fn (crea Snake) fup(mut app App, pos Vector){
	// Pos
	for anchor_id in crea.body{
		if anchor_id != 0{
			rel		:= app.list_anchor[anchor_id - 1].pos
			mut new	:= mult(crea.vert_radius, (app.list_anchor[anchor_id].pos - rel).normalize()) + rel
			app.list_anchor[anchor_id].pos = new
		}
		else{
			ref := (pos - app.list_anchor[anchor_id].pos)
			if ref.len() > 10{
				app.list_anchor[anchor_id].pos += mult(5, ref.normalize())
			}
		}
	}

	// Angle
	for anchor_id in crea.body{
		if anchor_id != 0{
			if anchor_id != crea.body.last(){
				// Calcul de l'origine
				rel			:= app.list_anchor[anchor_id].pos

				// Expression des puis précédant et suivant par rapport a l'origine
				pos_rel1	:= app.list_anchor[anchor_id - 1].pos - rel
				pos_rel2	:= app.list_anchor[anchor_id + 1].pos - rel

				// Calcul de l'angle entre les deux point
				cur_angle	:= angle(pos_rel1, pos_rel2)

				app.list_anchor[anchor_id].angle = angle_contraint(cur_angle, app.list_anchor[anchor_id - 1].angle, crea.angle_contraint)
				
				app.list_anchor[anchor_id + 1].pos = rel + Vector{x : pos_rel2.len()}.turn(app.list_anchor[anchor_id].angle)
			}
		}
		else {
			rel := app.list_anchor[0].pos
			app.list_anchor[0].angle = angle(pos - rel, app.list_anchor[1].pos - rel)
		}
	}
}

fn (crea Snake) bup(mut app App, pos Vector){}

fn (crea Snake) render(app App){
	// Pos
	for anchor_id in crea.body{
		x :=	f32(app.list_anchor[anchor_id].pos.x)
		y :=	f32(app.list_anchor[anchor_id].pos.y)
		radius :=	f32(app.list_anchor[anchor_id].radius)

		c :=	gx.white

		app.ctx.draw_circle_empty(x, y, radius, c)
	}
}
