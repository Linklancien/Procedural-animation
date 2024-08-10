interface Creature {
	update(mut app App, cible Vector)
	render(app App)
}


struct Snake{
	mut:
		spine	Chain
}

fn (snake Snake) update(mut app App, cible Vector){
	snake.spine.front_go_to(mut app, cible)
}

fn  (snake Snake) render(app App){
	snake.spine.render(app)
}
