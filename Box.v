import gx

struct Box {
	pos		Vector
	width	f64
	height	f64
}

fn (box Box) is_collide_circle(position Vector, radius f64) bool{
	x := position.x + radius/2
	y := position.y + radius/2

	if(x >= box.pos.x + box.width)		// trop à droite
    || (x + radius <= box.pos.x)			// trop à gauche
    || (y >= box.pos.y + box.height)	// trop en bas
    || (y + radius <= box.pos.y){		// trop en haut
		return false
	}
	else{
		return true
	}
}

fn (box Box) render(app App){
	app.ctx.draw_rect_filled(f32(box.pos.x), f32(box.pos.y), f32(box.width), f32(box.height), gx.red)
}