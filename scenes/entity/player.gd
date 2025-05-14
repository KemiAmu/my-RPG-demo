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

# 处理引擎通知
# Handle engine notifications
func _notification(what: int) -> void:
	if what in [NOTIFICATION_READY, NOTIFICATION_UNPAUSED]:
		Game.player_manager.player_ready.emit(self)
	elif what in [NOTIFICATION_EXIT_TREE, NOTIFICATION_PAUSED]:
		Game.player_manager.player_unready.emit(self)

# 处理物理更新
# Handle physics update
# TODO WONTFIX: 结构性问题
func _physics_process(delta: float) -> void:
	var input_direction := Input.get_vector(
		"ui_left", "ui_right", 
		"ui_up"  , "ui_down" , 0.5 )
	
	current_state = EntityState.IDLE \
	if input_direction == Vector2.ZERO else EntityState.MOVE

	traveling_towards(input_direction, 1, delta)

# 交互区域进入处理
# Interaction area body entered handler
# TODO HACK 遭遇战
func _on_interaction_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		var enemy := body as EntityInterface
		Game.signal_bus.emit_signal("battle_triggered", [enemy])
