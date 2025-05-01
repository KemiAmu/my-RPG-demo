# player.gd
# Copyright 2025 Kemi-Amu
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
#
# SPDX-License-Identifier: MPL-2.0

extends "res://entity/interface.gd"

func _physics_process(delta: float) -> void:
	# get input
	var input_direction := Vector2 (
		Input.get_axis("ui_left", "ui_right"),
		Input.get_axis("ui_up", "ui_down")
	)
	
	# interpret input
	if input_direction != Vector2.ZERO:
		current_state = EntityState.MOVE
		if input_direction.x:
			facing_direction = Vector2(sign(input_direction.x), 0)
	else:
		current_state = EntityState.IDLE

	# state
	if current_state == EntityState.IDLE:
		animation_player.play(IDLE_ANIMATION[facing_direction])
		apply_movement(Vector2.ZERO, move_damping, delta)
	
	elif current_state == EntityState.MOVE:
		animation_player.play(MOVE_ANIMATION[facing_direction])
		apply_movement(input_direction.normalized(), move_damping, delta)
