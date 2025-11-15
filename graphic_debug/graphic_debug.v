module graphic_debug

import gg
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
		rotation := if i != points.len {
			(points[i + 1] - point).angle()
		} else {
			0
		}
		ctx.draw_polygon_filled(f32(point.x), f32(point.y), f32(radius[i]), edges, f32(rotation), color)
	}
}
