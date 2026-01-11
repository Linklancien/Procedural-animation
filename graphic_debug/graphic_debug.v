module graphic_debug

import gg
import sokol.sgl
import math { cos, sin }
import math.vec

// Render the basic shape of the array of point
pub fn basic_render(ctx gg.Context, points []vec.Vec2[f64], radius []f64, color gg.Color) {
	for i, point in points {
		ctx.draw_circle_empty(f32(point.x), f32(point.y), f32(radius[i]), color)
	}
}

// Render all points as triangles pointing in the direction of the next point in the list
pub fn angular_render(ctx gg.Context, points []vec.Vec2[f64], radius []f64, color gg.Color) {
	edges := 3
	for i, point in points {
		rotation := if i != points.len - 1 {
			(point - points[i + 1]).angle()
		} else {
			(points[i - 1] - point).angle()
		}
		x := f32(point.x)
		y := f32(point.y)
		norm := 40
		x2 := x + f32(norm * cos(rotation))
		y2 := y + f32(norm * sin(rotation))
		ctx.draw_polygon_filled(x, y, f32(radius[i]), edges, f32(rotation * 180 / math.pi),
			color)
		ctx.draw_line(x, y, x2, y2, gg.red)
	}
}

pub fn filled_render(ctx gg.Context, points []vec.Vec2[f64], radius []f64, c gg.Color){
  if c.a != 255 {
		sgl.load_pipeline(ctx.pipeline.alpha)
	}
	sgl.c4b(c.r, c.g, c.b, c.a)
	sgl.begin_triangle_strip ()
	
	x0 := f32(points[0].x)
	y0 := f32(points[0].y)
 
	rot := (points[0] - points[1]).angle()
	angles := [-math.pi/6, math.pi/6, -math.pi/4, math.pi/4, -math.pi/2, math.pi/2]
	for angle in angles{
	  xc := x0 + f32(radius[0] * cos(rot + angle))
		yc := y0 + f32(radius[0] * sin(rot + angle))
		sgl.v2f(xc, yc)
	}
  
	for i, point in pointsv {
		rotation := if i != points.len - 1 {
			(point - points[i + 1]).angle()
		} else {
			(points[i - 1] - point).angle()
		}
		x := f32(point.x)
		y := f32(point.y)
		
		x1 := x + f32(radius[i] * cos(rotation + math.pi/2))
		y1:= y + f32(radius[i] * sin(rotation + math.pi/2))
		x2 := x + f32(radius[i] * cos(rotation - math.pi/2))
		y2 := y + f32(radius[i] * sin(rotation - math.pi/2))
		
    sgl.v2f(x1, y1)
    sgl.v2f(x2, y2)
  	
    if i ==  points.len - 1{
     	xf := x + f32(radius[i] * cos(rotation + math.pi))
      yf := y + f32(radius[i] * sin(rotation + math.pi))
      sgl.v2f(xf, yf)
    }
	}
	sgl.end()
}
