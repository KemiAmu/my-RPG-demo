# player.gd
# Copyright 2025 Kemi-Amu
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
#
# SPDX-License-Identifier: MPL-2.0

extends EntityInterface

@onready var aegis := $Aegis

@export var is_battle_active := false

@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	#Camera.set_target_position(position + facing_direction * 10)
	pass

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

# 战斗触发逻辑
func _on_interaction_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		var enemy := body as CharacterBody2D
		enemy.set_physics_process(false) # 立即停止物理计算
		if not enemy:
			printerr("Enemy is null")
			return
		# [TODO] [HACK]
		print("触发战斗的敌人：", enemy.name)
		print("敌人当前场景：", enemy.get_tree().current_scene.name)
		enemy.hide()
		enemy.set_process_mode(Node.PROCESS_MODE_DISABLED)
		#Global.start_battle(enemy)
		# enemy.queue_free()
