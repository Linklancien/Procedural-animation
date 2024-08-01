interface Chain {
	fup(mut app App, pos Vector)
	bup(mut app App, pos Vector)
	render(app App)
}
