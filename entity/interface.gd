# interface.gd
# Copyright 2025 Kemi-Amu
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
#
# SPDX-License-Identifier: MPL-2.0

extends CharacterBody2D

@export var move_speed: float = 100.0
@export var move_damping: float = -20.0

func _ready() -> void:
	print("CharacterBody2D ready")

func _physics_process(delta: float) -> void:
	var input_direction = Vector2 (
		Input.get_axis("ui_left", "ui_right"),
		Input.get_axis("ui_up", "ui_down")
	)

	if input_direction != Vector2.ZERO:
		apply_movement(input_direction, delta)
	else:
		apply_movement(Vector2.ZERO, delta)
	
	# velocity
	print("Velocity: ", self.velocity)
	
	# todo something...
	

# Handle character movement
func apply_movement(direction: Vector2, delta) -> void:
	self.velocity = self.velocity.lerp (
		direction.normalized() * move_speed,
		1 - exp(move_damping * delta)
	)
	move_and_slide()
