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

# Maps entity states to their corresponding animation names
const ENTITY_STATE_MAP := {
	EntityState.IDLE: "idle",
	EntityState.MOVE: "move",
	EntityState.DASH: "dash",
	EntityState.JUMP: "jump"
}

# Maps Vector2 directions to their corresponding string names
const ENTITY_FACING_MAP := {
	Vector2.RIGHT: "right",
	Vector2.LEFT: "left",
	Vector2.DOWN: "down",
	Vector2.UP: "up"
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

# Function to play an animation
func play_animation(animation_name: String) -> void:
	animation_player.play(animation_name)

# Handle state behavior
func handle_state():
	play_animation(ENTITY_STATE_MAP[current_state] + "_" + ENTITY_FACING_MAP[facing_direction])

# Determine facing direction based on input
func calculate_facing_direction(target_direction: Vector2) -> Vector2:
	if facing_updater == FacingMode.TRACK:
		if abs(target_direction.x) * 1.2 < abs(target_direction.y):
			return Vector2(0, signf(target_direction.y))
	return Vector2(signf(target_direction.x), 0)

# Updates facing direction based on target direction and current facing updater method
func update_facing_direction(target_direction: Vector2) -> void:
	var facing = calculate_facing_direction(target_direction)
	facing_direction = facing if facing != Vector2.ZERO else facing_direction

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
	handle_state()
	apply_movement(target_direction, damping, delta)

# Move to target position (automatically updates facing direction)
# Note: Should be called from _physics_process(delta) for proper physics frame timing
func traveling_to(target_position: Vector2, damping: float, delta) -> void:
	var target_direction := (target_position - position)
	traveling_towards(target_direction, damping, delta)
