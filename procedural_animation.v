module proc_anim

import math
import math.vec

const origin = vec.vec2(f64(0.0), f64(0.0))

// front_to_back updates the points position starting by the first in `points`
// `points` is an array of every points
// `pos_constraints` is an array of the position constraints
// pos_constraints.len = points.len - 1 (0th is for the link between 0th and 1st point)
// `angle_constraints` is an array of the angle constraints
// angle_constraints.len = points.len - 2 (0th is for the 1st point)
pub fn front_to_back(mut points []vec.Vec2[f64], pos_constraints []f64, angle_constraints []f64) {
	for ip in 0 .. points.len - 2 {
		points[ip] = apply_pos_constraint(points[ip + 1], points[ip], pos_constraints[ip])
		points[ip] = apply_angle_constraint(points[ip + 2], points[ip + 1], points[ip],
			angle_constraints[ip])
	}
	points[points.len - 2] = apply_pos_constraint(points[points.len - 1], points[points.len - 2],
		pos_constraints[points.len - 2])
}

// back_to_front updates the points position starting by the last in `points`
// `points` is an array of every points
// `pos_constraints` is an array of the position constraints
// pos_constraints.len = points.len - 1 (0th is for the link between 0th and 1st point)
// `angle_constraints` is an array of the angle constraints
// angle_constraints.len = points.len - 2 (0th is for the 1st point)
pub fn back_to_front(mut points []vec.Vec2[f64], pos_constraints []f64, angle_constraints []f64) {
	p := points.len - 1
	for ip in 0 .. points.len - 2 {
		points[p - ip] = apply_pos_constraint(points[p - (ip + 1)], points[p - ip], pos_constraints[p - ip - 1])
		points[p - ip] = apply_angle_constraint(points[p - (ip + 2)], points[p - (ip + 1)],
			points[p - ip], angle_constraints[p - ip - 2])
	}
	points[1] = apply_pos_constraint(points[0], points[1], pos_constraints[0])
}

// front_to_back_min_max updates the points position starting by the first in `points`
// `points` is an array of every points
// `pos_constraints` is an array of the position constraints
// pos_constraints.len = points.len - 1 (0th is for the link between 0th and 1st point)
// `min_constraints` and `max_constraints` are arrays capping the angle constraints
// min_constraints.len and max_constraints.len = points.len - 2 (0th is for the 1st point)
pub fn front_to_back_min_max(mut points []vec.Vec2[f64], pos_constraints []f64, min_constraints []f64, max_constraints []f64) {
	for ip in 0 .. points.len - 2 {
		points[ip] = apply_pos_constraint(points[ip + 1], points[ip], pos_constraints[ip])
		points[ip] = apply_min_max_angle_constraint(points[ip + 2], points[ip + 1], points[ip],
			min_constraints[ip], max_constraints[ip])
	}
	points[points.len - 2] = apply_pos_constraint(points[points.len - 1], points[points.len - 2],
		pos_constraints[points.len - 2])
}

// back_to_front_min_max updates the points position starting by the last in `points`
// `points` is an array of every points
// `pos_constraints` is an array of the position constraints
// pos_constraints.len = points.len - 1 (0th is for the link between 0th and 1st point)
// `min_constraints` and `max_constraints` are arrays capping the angle constraints
// min_constraints.len and max_constraints.len = points.len - 2 (0th is for the 1st point)
pub fn back_to_front_min_max(mut points []vec.Vec2[f64], pos_constraints []f64, min_constraints []f64, max_constraints []f64) {
	p := points.len - 1
	for ip in 0 .. points.len - 2 {
		points[p - ip] = apply_pos_constraint(points[p - (ip + 1)], points[p - ip], pos_constraints[p - ip - 1])
		points[p - ip] = apply_min_max_angle_constraint(points[p - (ip + 2)], points[p - (ip + 1)],
			points[p - ip], min_constraints[p - ip - 2], max_constraints[p - ip - 2])
	}
	points[1] = apply_pos_constraint(points[0], points[1], pos_constraints[0])
}

// apply_pos_constraint returns the position of b constrained to (b - a).magnitude = constraint
pub fn apply_pos_constraint(a vec.Vec2[f64], b vec.Vec2[f64], constraint f64) vec.Vec2[f64] {
	return a + (b - a).unit().mul_scalar(constraint)
}

// apply_angle_constraint takes 3 points and returns the furthest position for the new `c` point (but blocks the angle <`a` `b` `c`> at `constraint` (radians)
// it also returns the new position for that does not break the angle constraint
pub fn apply_angle_constraint(a vec.Vec2[f64], b vec.Vec2[f64], c vec.Vec2[f64], constraint f64) vec.Vec2[f64] {
	ab := b - a
	bc := c - b
	wanted_angle := valid_angle(ab.angle_between(bc))
	abs_constraint := math.abs(valid_angle(constraint))
	if math.abs(wanted_angle) > abs_constraint + 0.0001 {
		current_angle_sign := math.sign(wanted_angle)
		return b +
			ab.unit().mul_scalar(bc.magnitude()).rotate_around_ccw(origin, abs_constraint * current_angle_sign)
	} else {
		return c
	}
}

// apply_min_max_angle_constraint
// returns the furthest position for the new `c` point but blocks the angle `min_constraint` < <`a` `b` `c`> < `max_constraint`  (radians)
// returns the new position for c that does not break the angle constraint
// used for asymetric angle constraint
pub fn apply_min_max_angle_constraint(a vec.Vec2[f64], b vec.Vec2[f64], c vec.Vec2[f64], _min_constraint f64, _max_constraint f64) vec.Vec2[f64] {
	min_constraint := valid_angle(_min_constraint)
	max_constraint := valid_angle(_max_constraint)
	ab := b - a
	bc := c - b
	wanted_angle := valid_angle(ab.angle_between(bc))
	if wanted_angle > max_constraint + 0.0001 {
		return b + ab.unit().mul_scalar(bc.magnitude()).rotate_around_ccw(origin, max_constraint)
	} else if wanted_angle < min_constraint + 0.0001 {
		return b + ab.unit().mul_scalar(bc.magnitude()).rotate_around_ccw(origin, min_constraint)
	} else {
		return c
	}
}

// returns the rad angle between -pi and pi
pub fn valid_angle(angle f64) f64 {
	res := math.mod(angle, 2 * math.pi)
	if res > math.pi {
		return res - 2 * math.pi
	} else if res < -math.pi {
		return res + 2 * math.pi
	} else {
		return res
	}
}

// front_go_to set the first point at a target point and update all points so it doesn't break the constraints
pub fn front_go_to(mut points []vec.Vec2[f64], pos_constraints []f64, angle_constraints []f64, target vec.Vec2[f64], repetition int) {
	for _ in 0 .. repetition {
		points[0] = target

		anchor_front_to_back(mut points, pos_constraints, angle_constraints)
	}
}

// back_go_to set the last point at a target point and update all points so it doesn't break the constraints
pub fn back_go_to(mut points []vec.Vec2[f64], pos_constraints []f64, angle_constraints []f64, target vec.Vec2[f64], repetition int) {
	for _ in 0 .. repetition {
		points[points.len - 1] = target

		anchor_back_to_front(mut points, pos_constraints, angle_constraints)
	}
}

pub fn anchor_front_to_back(mut points []vec.Vec2[f64], pos_constraints []f64, angle_constraints []f64) {
	for ip in 0 .. points.len - 2 {
		points[ip + 1] = apply_pos_constraint(points[ip], points[ip + 1], pos_constraints[ip])
		points[ip + 2] = apply_angle_constraint(points[ip], points[ip + 1], points[ip + 2],
			angle_constraints[ip])
	}
	points[points.len - 1] = apply_pos_constraint(points[points.len - 2], points[points.len - 1],
		pos_constraints[points.len - 2])
}

pub fn anchor_back_to_front(mut points []vec.Vec2[f64], pos_constraints []f64, angle_constraints []f64) {
	p := points.len - 1
	for ip in 0 .. points.len - 2 {
		points[p - ip] = apply_pos_constraint(points[p - (ip + 1)], points[p - ip], pos_constraints[p - ip])
		points[p - ip] = apply_angle_constraint(points[p - (ip + 2)], points[p - (ip + 1)],
			points[p - ip], angle_constraints[ip])
	}
	points[0] = apply_pos_constraint(points[0], points[1], pos_constraints[1])
}

pub fn anchor_front_to_back_min_max(mut points []vec.Vec2[f64], pos_constraints []f64, min_constraints []f64, max_constraints []f64) {
	for ip in 0 .. points.len - 2 {
		points[ip + 1] = apply_pos_constraint(points[ip], points[ip + 1], pos_constraints[ip])
		points[ip + 2] = apply_min_max_angle_constraint(points[ip], points[ip + 1], points[ip + 2],
			min_constraints[ip], max_constraints[ip])
	}
	points[points.len - 1] = apply_pos_constraint(points[points.len - 2], points[points.len - 1],
		pos_constraints[points.len - 2])
}
