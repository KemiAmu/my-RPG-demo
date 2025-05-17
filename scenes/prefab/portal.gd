# portal.gd
# Copyright 2025 Kemi-Amu
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
#
# SPDX-License-Identifier: MPL-2.0

# TODO 理论上应该使用点状位置而不是碰撞面积作为传送判定，以避免碰撞面积差异。

# TODO FIXME: 场景切换问题

# 传送门实体逻辑
# Portal entity logic
class_name Portal
extends Area2D

# 如果要切换的场景
# If you want to switch the scene
@export var next_scene: PackedScene

# 传送门所属的群组标识符
# Identifier of the portal group
@export var portal_group: String

# 传送门推出实体的半径
# Radius for pushing entities out of the portal
@export var push_radius := 50.0

# 当玩家进入传送门
# When the player enters the portal
func _on_player_entered(body: Node2D) -> void:
	# 获取玩家相对于传送门的方向（弧度）
	# Get player's direction relative to portal (in radians)
	var direction_angle := (body.global_position - global_position).angle()

	return Game.player_manager.portal_entered(
		null if next_scene else self,
		next_scene,
		portal_group,
		direction_angle
	)
