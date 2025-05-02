# slime.gd
# Copyright 2025 Kemi-Amu
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
#
# SPDX-License-Identifier: MPL-2.0

extends "res://entity/interface.gd"

@export var plan_state := EntityState.JUMP
@export var can_move := true

func _physics_process(delta: float) -> void:
	if Game.get_player_node():
		# 之前的朝向
		var prev_direction = facing_direction
		# 获取玩家坐标（相对向量）
		var target_position = Game.get_player_node().position - position

		# 调整朝向
		if target_position.x:
			facing_direction = Vector2(sign(target_position.x), 0)
			if facing_direction != prev_direction:
				redirect_animation()

		# [TODO] 靠近玩家时冲撞并进入 BattleScene
		if target_position.length_squared() < 810:
			plan_state = EntityState.DASH
		
		if target_position.length_squared() < 81:
			pass # Battle

		# 向 path_track 移动
		if can_move:
			apply_movement(target_position.normalized(), move_damping, delta)
		else:
			# [TODO] 调试用值
			apply_movement(Vector2.ZERO, -3, delta)

# 动画重定向方法
# [TODO] WONT-FIX: 冲刺时意外地改变朝向，现阶段不用修复
func redirect_animation() -> void:
	var current_anim : String = animation_player.current_animation
	var progress : float = animation_player.current_animation_position

	# 根据状态选择动画字典
	var anim_dict := JUMP_ANIMATION if plan_state == EntityState.JUMP else DASH_ANIMATION
	var target_anim : String = anim_dict[facing_direction]

	if current_anim != target_anim:
		animation_player.play(target_anim)
		animation_player.seek(progress)  # 继承播放进度

# 动画结束的回调
func _on_jump_animation_finished() -> void:
	if plan_state == EntityState.DASH:
		animation_player.play(DASH_ANIMATION[facing_direction])
	else:
		animation_player.play(JUMP_ANIMATION[facing_direction])

func _on_dash_animation_finished() -> void:
	animation_player.play(JUMP_ANIMATION[facing_direction])

# 动画轨道的回调，史莱姆会在跳起和冲刺的时候移动
func _can_move() -> void:
	can_move = true

func _can_not_move() -> void:
	can_move = false
