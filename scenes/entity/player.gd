# player.gd
# Copyright 2025 Kemi-Amu
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
#
# SPDX-License-Identifier: MPL-2.0

# 玩家的视图层逻辑
# Player view layer logic
class_name PlayerEntity
extends EntityInterface

func _notification(what: int) -> void:
	if what in [NOTIFICATION_READY, NOTIFICATION_UNPAUSED]:
		PlayerManager.add_player(self)
	elif what in [NOTIFICATION_EXIT_TREE, NOTIFICATION_PAUSED]:
		PlayerManager.remove_player(self)

func handle_physics_updat(input_direction: Vector2, delta: float) -> void:
	# interpret input
	if input_direction != Vector2.ZERO:
		current_state = EntityState.MOVE
	else:
		current_state = EntityState.IDLE
	
	traveling_towards(input_direction, 1, delta)

# TODO HACK 交互区域
func _on_interaction_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		var enemy := body as CharacterBody2D
		enemy.set_physics_process(false) # 立即停止物理计算
		if not enemy:
			printerr("Enemy is null")
			return
		# TODO HACK
		print("触发战斗的敌人：", enemy.name)
		print("敌人当前场景：", enemy.get_tree().current_scene.name)
		enemy.hide()
		enemy.set_process_mode(Node.PROCESS_MODE_DISABLED)
		#Global.start_battle(enemy)
		# enemy.queue_free()
