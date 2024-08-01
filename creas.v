import gx

struct Snake{
	mut:
		body		[]int
		vert_radius	int	= 10
		vert_angle	f64	= 1
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
			app.list_anchor[anchor_id].pos = pos
		}
	}

	// Angle
	for anchor_id in crea.body{
		if anchor_id != 0{
			if anchor_id != crea.body.last(){
				rel			:= app.list_anchor[anchor_id].pos
				pos_rel1	:= app.list_anchor[anchor_id - 1].pos - rel
				pos_rel2	:= app.list_anchor[anchor_id + 1].pos - rel
				mut angle_calc	:= angle(pos_rel1, pos_rel2)
				if angle_calc < crea.vert_angle{
					app.list_anchor[anchor_id + 1].pos.turn(angle_calc - crea.vert_angle)
					app.list_anchor[anchor_id].angle = crea.vert_angle
				}
				else{
					app.list_anchor[anchor_id].angle = angle_calc
				}
			}
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
