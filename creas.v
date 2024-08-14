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
		body	[]int
		spine	Chain
}

fn (mut arm Arm) initialisation(mut app App){
	mid := Vector{x: app.win_width/2, y: app.win_height/2}

    for index, taille in arm.body{
        app.list_anchor << Anchor{pos: mid + Vector{x: 5*index}, radius: taille}
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
