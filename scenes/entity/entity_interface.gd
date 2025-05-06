# entity_interface.gd
# Copyright 2025 Kemi-Amu
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
#
# SPDX-License-Identifier: MPL-2.0

# 实体接口
# Entity interface
extends CharacterBody2D
class_name EntityInterface

# Facing direction update modes
# TRACK: 4-way directional movement (up/down/left/right)
# HORIZONTAL: Horizontal-only movement (left/right)
enum FacingMode { TRACK, HORIZONTAL }

# Entity State Machine
enum EntityState { IDLE, MOVE, DASH, JUMP }

# Animation naming conventions
const IDLE_ANIMATION := {
	Vector2.RIGHT: "idle_right",
	Vector2.LEFT: "idle_left",
	Vector2.DOWN: "idle_down",
	Vector2.UP: "idle_up"
}
const MOVE_ANIMATION := {
	Vector2.RIGHT: "move_right",
	Vector2.LEFT: "move_left",
	Vector2.DOWN: "move_down",
	Vector2.UP: "move_up"
}
const DASH_ANIMATION := {
	Vector2.RIGHT: "dash_right",
	Vector2.LEFT: "dash_left",
	Vector2.DOWN: "dash_down",
	Vector2.UP: "dash_up"
}
const JUMP_ANIMATION := {
	Vector2.RIGHT: "jump_right",
	Vector2.LEFT: "jump_left",
	Vector2.DOWN: "jump_down",
	Vector2.UP: "jump_up"
}

# Current facing direction of the entity
var facing_direction := Vector2.RIGHT

# Method to update facing direction
@export var facing_updater := FacingMode.TRACK

# Movement speed in pixels per second
@export var move_speed := 100.0

# Damping factor for movement smoothing (negative value)
@export var move_damping := -20.0

# Current state of the character from State enum
@export var current_state := EntityState.IDLE

# Reference to the AnimationPlayer node for character animations
@export var animation_player: AnimationPlayer

# Determine facing direction based on input
func calculate_facing_direction(target_direction: Vector2) -> Vector2:
	if facing_updater == FacingMode.TRACK:
		if abs(target_direction.x) * 1.2 < abs(target_direction.y):
			return Vector2(0, signf(target_direction.y))
	return Vector2(signf(target_direction.x), 0)

# Updates facing direction based on target direction and current facing updater method
func update_facing_direction(target_direction: Vector2) -> void:
	var facing = calculate_facing_direction(target_direction)
	facing_direction = facing_direction if facing == Vector2.ZERO else facing

# Handle character movement
# Note: Should be called from _physics_process(delta) for proper physics frame timing
func apply_movement(target_direction: Vector2, damping: float, delta) -> void:
	velocity = velocity.lerp (
		target_direction.normalized() * move_speed,
		1 - exp(damping * move_damping * delta)
	)
	move_and_slide()

# Move towards target direction (automatically updates facing direction)
# Note: Should be called from _physics_process(delta) for proper physics frame timing
func traveling_towards(target_direction: Vector2, damping: float, delta) -> void:
	update_facing_direction(target_direction)
	apply_movement(target_direction, damping, delta)

# Move to target position (automatically updates facing direction)
# Note: Should be called from _physics_process(delta) for proper physics frame timing
func traveling_to(target_position: Vector2, damping: float, delta) -> void:
	var target_direction := (target_position - position)
	traveling_towards(target_direction, damping, delta)
