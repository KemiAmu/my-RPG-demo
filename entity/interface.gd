# interface.gd
# Copyright 2025 Kemi-Amu
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
#
# SPDX-License-Identifier: MPL-2.0

extends CharacterBody2D

# Entity states, at least IDLE state must be implemented
enum EntityState { IDLE, MOVE, DASH }

@export var idle_animation := {
	Vector2.LEFT: "idle_left",
	Vector2.RIGHT: "idle_right",
	Vector2.DOWN: "idle_down",
	Vector2.UP: "idle_up"
}

@export var move_animation := {
	Vector2.LEFT: "move_left",
	Vector2.RIGHT: "move_right",
	Vector2.DOWN: "move_down",
	Vector2.UP: "move_up"
}

# Movement speed in pixels per second
@export var move_speed := 100.0
# Damping factor for movement smoothing (negative value)
@export var move_damping := -20.0
# Current state of the character from State enum
@export var current_state := EntityState.IDLE
# Current facing direction of the entity
@export var facing_direction := Vector2.DOWN

# Reference to the AnimationPlayer node for character animations
@onready var animation_player := $Sprite2D/AnimationPlayer

func _physics_process(delta: float) -> void:
	# get input direction
	var input_direction := Vector2 (
		Input.get_axis("ui_left", "ui_right"),
		Input.get_axis("ui_up", "ui_down")
	).normalized()
	
	# interpret
	if input_direction != Vector2.ZERO:
		current_state = EntityState.MOVE
		facing_direction = input_direction
	else:
		current_state = EntityState.IDLE

	# state
	match current_state:
		EntityState.IDLE:
			animation_player.play(idle_animation[enter_track(facing_direction)])
			apply_movement(Vector2.ZERO, delta)
			
		EntityState.MOVE:
			animation_player.play(move_animation[enter_track(facing_direction)])
			apply_movement(input_direction, delta)

# Integrate the direction vector into the direction trajectory
func enter_track(target_direction: Vector2) -> Vector2:
	if target_direction.length_squared() != 1:
		printerr("Invalid direction, vector length is not 1")
	if abs(target_direction.x) * 1.2 > abs(target_direction.y):
		return Vector2(sign(target_direction.x), 0)
	return Vector2(0, sign(target_direction.y))

# Handle character movement
func apply_movement(target_direction: Vector2, delta) -> void:
	self.velocity = self.velocity.lerp (
		target_direction * move_speed,
		1 - exp(move_damping * delta)
	)
	move_and_slide()
