module graphic_debug

import gg
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
