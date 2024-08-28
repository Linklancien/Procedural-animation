interface Creature {
	render(app App)
	mut:
		update(mut app App, cible Vector)
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
		start_pos	Vector
		end_pos		Vector
		body	[]int
		spine	Chain
}

fn (mut arm Arm) initialisation(mut app App){
	mid := arm.start_pos
	
	start := app.list_anchor.len
	mut bigest := 0
    for taille in arm.body{
		if taille > bigest{bigest = taille}
        app.list_anchor << Anchor{pos: mid, radius: taille}
	}
	len := arm.body.len

	arm.spine = Chain{body_anchor_index: []int{len: len, init: start + index}, vert_radius: bigest*2}
}

fn (mut arm Arm) update(mut app App, cible Vector){
	arm.start_pos = app.list_anchor[arm.spine.body_anchor_index.last()].pos
	arm.spine.fabrik(mut app, arm.start_pos, cible)
	arm.end_pos = app.list_anchor[arm.spine.body_anchor_index[0]].pos
}

fn  (arm Arm) render(app App){
	arm.spine.render(app)
}
