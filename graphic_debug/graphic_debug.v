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

pub fn basic_render_at(ctx gg.Context, x f32, y f32, points []vec.Vec2[f64], radius []f64, color gg.Color) {
	for i, point in points {
		ctx.draw_circle_empty(f32(point.x) + x, f32(point.y) + y, f32(radius[i]), color)
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

// Complex_render
pub fn filled_render(ctx gg.Context, points []vec.Vec2[f64], radius []f64, c gg.Color) {
  filled_render_abs(ctx, 0.0, 0.0, points, radius, c)
}
  
pub fn filled_render_abs(ctx gg.Context, x_abs f32, y_abs f32, points []vec.Vec2[f64], radius []f64, c gg.Color) {
	if c.a != 255 {
		sgl.load_pipeline(ctx.pipeline.alpha)
	}
	sgl.c4b(c.r, c.g, c.b, c.a)
	sgl.begin_triangle_strip()

	max := points.len - 1
	for i in 0 .. points.len {
		rotation := if i == 0 {
			(points[i] - points[i + 1]).angle()
		} else if i == max {
			(points[i - 1] - points[i]).angle()
		} else {
			(points[i - 1] - points[i + 1]).angle()
		}
		x := f32(points[i].x) + x_abs
		y := f32(points[i].y) + y_abs
		match i {
			0 {
				add_points_in_arc(x, y, f32(radius[i]), math.pi / 2, f32(rotation),
					true, 2)
				add_opposing_points(x, y, f32(radius[i]), rotation)
			}
			max {
				add_opposing_points(x, y, f32(radius[i]), rotation)
				add_points_in_arc(x, y, f32(radius[i]), math.pi / 2, f32(rotation + math.pi),
					false, 2)
			}
			else {
				add_opposing_points(x, y, f32(radius[i]), rotation)
			}
		}
	}
	sgl.end()
}

fn add_opposing_points(x f32, y f32, radius f32, rotation f64) {
	x1, y1, x2, y2 := get_opposing_pos(x, y, radius, rotation)

	sgl.v2f(x1, y1)
	sgl.v2f(x2, y2)
}

fn add_points_in_arc(x f32, y f32, radius f32, extreme_angle f32, rota f32, from_the_rota bool, step int) {
	f := if from_the_rota {
		fn [step, extreme_angle, rota] (nth_step int) f32 {
			return extreme_angle * f32(nth_step) / f32(step)
		}
	} else {
		fn [step, extreme_angle, rota] (nth_step int) f32 {
			return extreme_angle - extreme_angle * f32(nth_step) / f32(step)
		}
	}
	for i in 0 .. (step + 1) {
		angle := f(i)
		xa := x + f32(radius * cos(rota + angle))
		ya := y + f32(radius * sin(rota + angle))

		sgl.v2f(xa, ya)
		xo := x + f32(radius * cos(rota - angle))
		yo := y + f32(radius * sin(rota - angle))

		sgl.v2f(xo, yo)
	}
}

fn get_opposing_pos(x f32, y f32, radius f32, rotation f64) (f32, f32, f32, f32) {
	x1 := x + f32(radius * cos(rotation + math.pi / 2))
	y1 := y + f32(radius * sin(rotation + math.pi / 2))
	x2 := x + f32(radius * cos(rotation - math.pi / 2))
	y2 := y + f32(radius * sin(rotation - math.pi / 2))
	return x1, y1, x2, y2
}
