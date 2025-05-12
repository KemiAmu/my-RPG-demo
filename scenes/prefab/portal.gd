# portal.gd
# Copyright 2025 Kemi-Amu
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
#
# SPDX-License-Identifier: MPL-2.0

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

func _ready() -> void:
	Game.portal_manager.register(self)

func _exit_tree() -> void:
	Game.portal_manager.unregister(self)

func _on_player_entered(body: Node2D) -> void:
	# Get player's position relative to portal origin (local coordinates)
	var relative_pos := body.global_position - global_position
	# Get player's direction relative to portal (in radians)
	var direction_angle := relative_pos.angle()
	# Get player's absolute position (global coordinates)
	var absolute_pos := body.global_position

	print("Player entered portal at:")
	print("Relative position: ", relative_pos)
	print("Absolute position: ", absolute_pos)
	print("Direction angle: ", direction_angle)
	
	Game.signal_bus.portal_triggered.emit(
		(body.global_position - global_position).angle()
	)
