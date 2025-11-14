module proc_anim

import math
import math.vec

const origin = vec.vec2(f32(0.0), f32(0.0))

// pos_constraints.len = points.len - 1
// min/max_constraints.len = points.len - 2
pub fn front_to_back_min_max(mut points []vec.Vec2[f32], pos_constraints []f32, min_constraints []f32, max_constraints []f32) {
	for ip in 0 .. points.len - 2 {
		points[ip] = apply_pos_constraint(points[ip], points[ip + 1], pos_constraints[ip])
		points[ip] = apply_min_max_angle_constraints(points[ip], points[ip + 1], points[ip + 2],
			min_constraints[ip], max_constraints[ip])
	}
	points[ip] = apply_pos_constraint(points[points.len - 2], points[points.len - 1],
		pos_constraints[points.len - 2])
}

// pos_constraints.len = points.len - 1
// angle_constraints.len = points.len - 2
pub fn front_to_back_min_max(mut points []vec.Vec2[f32], pos_constraints []f32, angle_constraints []f32) {
	for ip in 0 .. points.len - 2 {
		points[ip] = apply_pos_constraint(points[ip], points[ip + 1], pos_constraints[ip])
		points[ip] = apply_angle_constraints(points[ip], points[ip + 1], points[ip + 2],
			angle_constraints[ip])
	}
	points[ip] = apply_pos_constraint(points[points.len - 2], points[points.len - 1],
		pos_constraints[points.len - 2])
}

// returns the position of b constrained to (b - a).magnitude = constraint
pub fn apply_pos_constraint(a vec.Vec2[f32], b vec.Vec2[f32], constraint f32) vec.Vec2[f32] {
	return a + b.unit().mul_scalar(constraint)
}

// returns the furthest position for the new `c` point (but blocks the angle <`a` `b` `c`> at `constraint` (radians)
// returns the new position for that does not break the angle constraint
pub fn apply_angle_constraint(a vec.Vec2[f32], b vec.Vec2[f32], c vec.Vec2[f32], constraint f32) vec.Vec2[f32] {
	ab := b - a
	bc := c - b
	wanted_angle := valid_angle(ab.angle_between(bc))
	abs_constraint := math.abs(valid_angle(constraint))
	if math.abs(wanted_angle) > abs_constraint {
		current_angle_sign := math.sign(wanted_angle)
		return ab.unit().mul_scalar(bc.magnitude).rotate_around_ccw(origin, abs_constraint * current_angle_sign)
	} else {
		return c
	}
}

// returns the furthest position for the new `c` point but blocks the angle `min_constraint` < <`a` `b` `c`> < `max_constraint`  (radians)
// returns the new position for c that does not break the angle constraint
// used for asymetric angle constraint
pub fn apply_min_max_angle_constraint(a vec.Vec2[f32], b vec.Vec2[f32], c vec.Vec2[f32], _min_constraint f32, _max_constraint f32) vec.Vec2[f32] {
	min_constraint := valid_angle(_min_constraint)
	max_constraint := valid_angle(_max_constraint)
	ab := b - a
	bc := c - b
	wanted_angle := valid_angle(ab.angle_between(bc))
	abs_constraint := math.abs(valid_angle(constraint))
	if wanted_angle > max_constraint {
		return ab.unit().mul_scalar(bc.magnitude).rotate_around_ccw(origin, max_constraint)
	} else if wanted_angle < min_constraint {
		return ab.unit().mul_scalar(bc.magnitude).rotate_around_ccw(origin, min_constraint)
	} else {
		return c
	}
}

// returns the rad angle between -pi and pi
pub fn valid_angle(angle f32) f32 {
	return math.mod(angle, 2 * math.pi) - math.pi
}
