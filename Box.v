import gx

struct Box {
	pos		Vector
	width	f64
	height	f64
}

fn (box Box) is_collide_circle(position Vector, radius f64) bool{
	x := position.x + radius/2
	y := position.y + radius/2
	// trop à droite || trop à gauche || trop en bas || trop en haut
	if (x >= box.pos.x + box.width) || (x + radius <= box.pos.x) || (y >= box.pos.y + box.height) || (y + radius <= box.pos.y){		
		return false
	}
	else{
		return true
	}
}

fn (box Box) render(app App){
	app.ctx.draw_rect_filled(f32(box.pos.x), f32(box.pos.y), f32(box.width), f32(box.height), gx.red)
}