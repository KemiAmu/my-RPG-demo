# player_manager.gd
# Copyright 2025 Kemi-Amu
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
#
# SPDX-License-Identifier: MPL-2.0

# 玩家管理器类，负责动态调控玩家实体
# Player manager class, responsible for dynamic player entity control
# TODO: AI-generated code - pending review
class_name PlayerManager

# Player entity node
# TODO HACK WONTFIX: 弱连接，可能无效
var player: PlayerEntity

# Intermediate layer data maintained by player manager
var _intermediate_data := { "position": Vector2.ZERO }

# Player entity scene resource
# TODO HACK WONTFIX: 迁移至 Intermediate data
var player_scene := preload("res://scenes/entity/player.tscn")

# Player entity lifecycle signals
# TODO HACK: 用于兼容和阻断异常
signal player_ready(node: PlayerEntity)
signal player_unready(node: PlayerEntity)

# Handle portal entry: switch scenes and position player accordingly
func portal_entered(node: Node, scene: PackedScene, group: String, normal: float) -> void:
	Game.switch_scene(scene, func():
		# Locate all portal nodes in the new scene that belong to the same group
		var target_portals := Game.get_tree().get_nodes_in_group("portal")
		target_portals.erase(node)
		for p in target_portals:
			if p.portal_group != group: target_portals.erase(p)
		print(" Info: Found %d target portals in group '%s'" % [target_portals.size(), group])

		# Calculate the geometric center position of portals in the same group
		var group_center := Vector2.ZERO
		for p in target_portals: group_center += p.global_position
		if group_center != Vector2.ZERO: group_center /= target_portals.size()

		# Find the portal that best matches the entry angle
		var best_match: Portal = null
		var smallest_angle_diff := INF
	
		for portal in target_portals:
			var portal_angle: float = (portal.global_position - group_center).angle()
			var angle_diff: float = abs(wrapf(normal - portal_angle, -PI, PI))
	
			if angle_diff < smallest_angle_diff:
				smallest_angle_diff = angle_diff
				best_match = portal
		
		if best_match:
			# Calculate player's position offset relative to target portal
			var snapped_angle := roundf((normal + PI) / (PI / 2)) * (PI / 2)
			var exit_offset := Vector2(best_match.push_radius, 0).rotated(snapped_angle)

			# Set player position to target portal and apply offset
			teleport_player(best_match.position + exit_offset)
	)

# Teleport player to specified position and update intermediate data
func teleport_player(pos: Vector2) -> void:
	if not player: player = spawn_player()
	_intermediate_data["position"] = pos
	apply_player_data(_intermediate_data)
	print("Debug: Player teleported to position: %s" % str(_intermediate_data["position"]))

# Lifecycle callbacks
func _init():
	Game.save_manager.register("player", load_player, save_player)
	player_ready.connect(func(node: PlayerEntity):
		player = node
	)
	player_unready.connect(func(node: PlayerEntity):
		if player == node: player = null
	)

# Player data serialization
# TODO HACK WONTFIX: 我知道这很烂
func load_player(data: Dictionary) -> void:
	_intermediate_data = data
	apply_player_data(_intermediate_data)

func save_player() -> Dictionary:
	if player: _intermediate_data["position"] = player.position
	return _intermediate_data

# Spawn player entity instance and add to scene
# TODO HACK XXX: 假定节点树结构
func spawn_player() -> PlayerEntity:
	var new_player := player_scene.instantiate() as PlayerEntity
	Game.get_tree().current_scene.get_node("EntityLayer").add_child(new_player)
	return new_player

# Apply player datas
func apply_player_data(data: Dictionary) -> void:
	if not player: return
	player.position = data.get("position", player.position)
