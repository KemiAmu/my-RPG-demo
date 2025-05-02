# interface.gd
# Copyright 2025 Kemi-Amu
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
#
# SPDX-License-Identifier: MPL-2.0

extends CharacterBody2D

# Entity states
enum EntityState { IDLE, MOVE, DASH, JUMP }

# Animation naming conventions
const IDLE_ANIMATION := {
	Vector2.LEFT: "idle_left",
	Vector2.RIGHT: "idle_right",
	Vector2.DOWN: "idle_down",
	Vector2.UP: "idle_up"
}

const MOVE_ANIMATION := {
	Vector2.LEFT: "move_left",
	Vector2.RIGHT: "move_right",
	Vector2.DOWN: "move_down",
	Vector2.UP: "move_up"
}

const DASH_ANIMATION := {
	Vector2.LEFT: "dash_left",
	Vector2.RIGHT: "dash_right",
	Vector2.DOWN: "dash_down",
	Vector2.UP: "dash_up"
}

const JUMP_ANIMATION := {
	Vector2.LEFT: "jump_left",
	Vector2.RIGHT: "jump_right",
	Vector2.DOWN: "jump_down",
	Vector2.UP: "jump_up"
}

# Movement speed in pixels per second
@export var move_speed := 100.0
# Damping factor for movement smoothing (negative value)
@export var move_damping := -20.0
# Current state of the character from State enum
@export var current_state := EntityState.IDLE
# Current facing direction of the entity
@export var facing_direction := Vector2.LEFT

# Reference to the AnimationPlayer node for character animations
@onready var animation_player := $Sprite2D/AnimationPlayer

# Integrate the direction vector into the direction trajectory
# Note: This function may return Vector2.ZERO as-is.
func enter_track(target_direction: Vector2) -> Vector2:
	if abs(target_direction.x) * 1.2 > abs(target_direction.y):
		return Vector2(sign(target_direction.x), 0)
	return Vector2(0, sign(target_direction.y))

# Handle character movement
func apply_movement(target_direction: Vector2, damping: float, delta) -> void:
	self.velocity = self.velocity.lerp (
		target_direction * move_speed,
		1 - exp(damping * delta)
	)
	move_and_slide()
