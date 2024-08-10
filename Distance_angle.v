import math

const pi_2 = math.pi*2
// Constraint pos to a distance of constraint from the anchor
fn constraint_distance(pos Vector, anchor Vector, constraint f64) Vector{
	return mult(constraint, (pos - anchor).normalize()) + anchor
}



// Constraint pos to an angle minimum of constraint from the anchor
fn angle_contraint(angle f64, anchor f64, constraint f64) f64{
	if math.abs(relative_angle_diff(angle, anchor)) <= constraint {
		return simplify_angle(angle)
	}

	if relative_angle_diff(angle, anchor) > constraint {
		return simplify_angle(anchor - constraint)
	}

	return simplify_angle(anchor + constraint)
}

// i.e. How many radians do you need to turn the angle to match the anchor?
fn relative_angle_diff(angle f64, anchor f64) f64{
	// Since angles are represented by values in [0, 2pi), it's helpful to rotate
	// the coordinate space such that PI is at the anchor. That way we don't have
	// to worry about the "seam" between 0 and 2pi.

	return math.pi - simplify_angle(angle  + math.pi- anchor)
}

// Simplify the angle to be in the range [0, 2pi)
fn simplify_angle(angle f64) f64{
	mut new := angle
	for new >= pi_2 {
		new -= pi_2
	}

	for new < 0 {
		new += pi_2
	}
	return new
}
