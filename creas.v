import gx
import math

struct Snake{
	mut:
		body		[]int
		vert_radius	int	= 10
		vert_angle	f64	= math.pi
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
				rel			:= app.list_anchor[anchor_id].pos
				pos_rel1	:= app.list_anchor[anchor_id - 1].pos - rel
				pos_rel2	:= app.list_anchor[anchor_id + 1].pos - rel
				angle_calc	:= angle(pos_rel1, pos_rel2)

				if angle_calc < crea.vert_angle{
					x := Vector{x:1}

					angle1 := angle(x, pos_rel1)
					angle2 := angle(x, pos_rel2)

					rota := crea.vert_angle - angle_calc

					if pos_rel1.y > 0{
						if pos_rel2.y > 0{
							if angle1 < angle2{
								app.list_anchor[anchor_id + 1].pos.turn(rota)
							}
							else{
								app.list_anchor[anchor_id + 1].pos.turn(-rota)
							}
						}
						else{
							app.list_anchor[anchor_id + 1].pos.turn(-rota)
						}
					}
					else if pos_rel1.y < 0{
						if pos_rel2.y < 0{
							if angle1 < angle2{
								app.list_anchor[anchor_id + 1].pos.turn(-rota)
							}
							else{
								app.list_anchor[anchor_id + 1].pos.turn(rota)
							}
						}
						else{
							app.list_anchor[anchor_id + 1].pos.turn(rota)
						}
					}
					

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
