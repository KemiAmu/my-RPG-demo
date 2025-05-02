# slime.gd
# Copyright 2025 Kemi-Amu
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
#
# SPDX-License-Identifier: MPL-2.0

extends "res://entity/interface.gd"

func on_jump_animation_finished() -> void:
	current_state = EntityState.IDLE
	animation_player.play(JUMP_ANIMATION[facing_direction])

func on_dash_animation_finished() -> void:
	current_state = EntityState.IDLE
	animation_player.play(JUMP_ANIMATION[facing_direction])
