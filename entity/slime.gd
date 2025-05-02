# slime.gd
# Copyright 2025 Kemi-Amu
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
#
# SPDX-License-Identifier: MPL-2.0

extends "res://entity/interface.gd"

# 当前计划状态（JUMP/DASH）
@export var plan_state := EntityState.JUMP
# 是否允许移动的标记
@export var can_move := true
# player 的节点，史莱姆的移动目标
@export var target_node: Node2D = null

func _physics_process(delta: float) -> void:
	if not target_node:
		printerr("Target node not set!")
	
	var target_position = target_node.position - position

	_update_facing_direction(target_position)
	_handle_state_transition(target_position)
	_execute_movement(target_position, delta)

# 方向计算
func _update_facing_direction(target_position: Vector2) -> void:
	var new_direction = facing_direction
	if target_position.x != 0:
		new_direction = Vector2(sign(target_position.x), 0)

	if new_direction != facing_direction:
		facing_direction = new_direction
		redirect_animation()

# 状态转换封装
func _handle_state_transition(target_position: Vector2) -> void:
	var distance_sq = target_position.length_squared()
	if distance_sq < 810:
		plan_state = EntityState.DASH
	elif distance_sq >= 810:
		plan_state = EntityState.JUMP

# 移动逻辑
func _execute_movement(target_position: Vector2, delta: float) -> void:
	if can_move:
		var move_direction = target_position.normalized()
		apply_movement(move_direction, move_damping, delta)
	else:
		apply_movement(Vector2.ZERO, -3, delta)

# 动画重定向
func redirect_animation() -> void:
	var current_anim : String = animation_player.current_animation
	var progress : float = animation_player.current_animation_position
	var anim_dict := JUMP_ANIMATION if plan_state == EntityState.JUMP else DASH_ANIMATION
	var target_anim : String = anim_dict[facing_direction]

	if current_anim != target_anim:
		animation_player.play(target_anim)
		animation_player.seek(progress)

# 动画回调
func _on_jump_animation_finished() -> void:
	if plan_state == EntityState.DASH:
		animation_player.play(DASH_ANIMATION[facing_direction])
	else:
		animation_player.play(JUMP_ANIMATION[facing_direction])

func _on_dash_animation_finished() -> void:
	animation_player.play(JUMP_ANIMATION[facing_direction])

func _can_move() -> void:
	can_move = true

func _can_not_move() -> void:
	can_move = false
