module main

import math

struct Vector {
	mut:
		x f64
		y f64
		z f64
}
const vector_null = Vector{0,0,0}

// FONCTIONS POUR LES VECTEURS
fn (vec Vector) normalize() Vector {
	len := vec.len()
	if len == 0 {
		return Vector{0, 0, 0}
	}
	return Vector{
		x: vec.x / len
		y: vec.y / len
		z: vec.z / len
	}
}

fn (vec Vector) square_len() f64 {
	return vec.x * vec.x + vec.y * vec.y + vec.z * vec.z
}

fn (vec Vector) len() f64 {
	return math.sqrt(vec.square_len())
}

fn (vec Vector) abs() Vector {
	return Vector{math.abs(vec.x), math.abs(vec.y), math.abs(vec.z)}
}

fn mult(val f64, vec Vector) Vector {
	return Vector{val * vec.x, val * vec.y, val * vec.z}
}

// produit scalaire (dot product)
fn dot(vec1 Vector, vec2 Vector) f64 { 
	return vec1.x * vec2.x + vec1.y * vec2.y + vec1.z * vec2.z
}

// Produit Vectoriel
fn prod_vec(vec1 Vector, vec2 Vector) Vector { 
	new_x := vec1.y * vec2.z - vec1.z * vec2.y
	new_y := vec1.z * vec2.x - vec1.x * vec2.z
	new_z := vec1.x * vec2.y - vec1.y * vec2.x
	return Vector{new_x, new_y, new_z}
}

fn rdot_f(vec1 Vector, vec2 Vector) f64 {
	return f64(vec1.x) / f64(vec2.x) + f64(vec1.y) / f64(vec2.y) + f64(vec1.z) / f64(vec2.z)
}

fn divi_v(vec1 Vector, vec2 Vector) Vector {
	return Vector{vec1.x / vec2.x, vec1.y / vec2.y, vec1.z / vec2.z}
}

fn (vec Vector) turn(angle f64) Vector {
	cos := math.cos(angle)
	sin := math.sin(angle)
	return mult(vec.x, Vector{cos, sin, 0}) + mult(vec.y, Vector{-sin, cos, 0}) + Vector{0, 0, vec.z}
}

fn angle(vec1 Vector, vec2 Vector) f64 {
	calcul	:= vec1.x * vec2.x + vec1.y * vec2.y + vec1.z * vec2.z/vec1.len() + vec2.len()
	angle	:= math.acos(calcul)
	return angle
}

fn (vec1 Vector) + (vec2 Vector) Vector {
	return Vector{vec1.x + vec2.x, vec1.y + vec2.y, vec1.z + vec2.z}
}

@[inline]
fn (vec1 Vector) - (vec2 Vector) Vector {
	return Vector{vec1.x - vec2.x, vec1.y - vec2.y, vec1.z - vec2.z}
}

