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
	)
	
	# interpret
	if input_direction != Vector2.ZERO:
		current_state = EntityState.MOVE
	else:
		current_state = EntityState.IDLE

	# state
	match current_state:
		EntityState.IDLE:
			animation_player.play("idle")
			apply_movement(Vector2.ZERO, delta)
			
		EntityState.MOVE:
			animation_player.play("walk")
			apply_movement(input_direction, delta)

# Handle character movement
func apply_movement(target_direction: Vector2, delta) -> void:
	self.velocity = self.velocity.lerp (
		target_direction.normalized() * move_speed,
		1 - exp(move_damping * delta)
	)
	move_and_slide()
