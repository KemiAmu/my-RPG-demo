# slime.gd
# Copyright 2025 Kemi-Amu
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
#
# SPDX-License-Identifier: MPL-2.0

# 史莱姆的生物逻辑
# Slime AI
extends EntityInterface

# 允许移动的标记
@export var can_move := true
# 计划状态
@export var state_plan := EntityState.JUMP

# 物理帧处理
func _physics_process(delta: float) -> void:
	if can_move:
		# TODO Vector2(0, 0) 代表玩家位置
		traveling_to(Vector2(0, 0), 1, delta)
	else:
		traveling_towards(Vector2(0, 0), 0.5, delta)

# 动画回调
func _on_jump_animation_finished() -> void:
	set_current_state(state_plan)

func _on_dash_animation_finished() -> void:
	set_current_state(EntityState.JUMP)

func _can_move() -> void:
	can_move = true

func _can_not_move() -> void:
	can_move = false
