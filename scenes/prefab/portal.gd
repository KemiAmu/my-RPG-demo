# portal.gd
# Copyright 2025 Kemi-Amu
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
#
# SPDX-License-Identifier: MPL-2.0

# TODO 理论上应该使用点状位置而不是碰撞面积作为传送判定，以避免碰撞面积差异。

# TODO FIXME: 起始传送门不应当记入目标传送门群组
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
	print(" Info: Player entered portal %s (group: %s)" % [name, portal_group])
	
	# 获取玩家相对于传送门的方向（弧度）
	# Get player's direction relative to portal (in radians)
	var direction_angle := (body.global_position - global_position).angle()

	# 切换到下一个场景
	# Change to the next scene
	if next_scene:
		# Game.signal_bus.scene_change_requested.emit(next_scene)
		Game.switch_scene.emit(next_scene)

	# 定位新场景中属于同一组的所有传送门节点
	# Locate all portal nodes in the new scene that belong to the same group
	var portals := get_tree().get_nodes_in_group("portal")
	for portal in portals:
		if portal.portal_group != portal_group:
			portals.erase(portal)

	# 获取同组传送门的几何中心位置
	# Calculate the geometric center position of portals in the same group
	var group_center := Vector2.ZERO
	for portal in portals:
		group_center += portal.global_position
	group_center /= max(portals.size(), 1)

	# 找到与进入角度最匹配的传送门
	# Find the portal that best matches the entry angle
	var best_match: Portal = null
	var smallest_angle_diff := INF

	for portal in portals:
		var portal_angle: float = (portal.global_position - group_center).angle()
		var angle_diff: float = abs(wrapf(direction_angle - portal_angle, -PI, PI))

		if angle_diff < smallest_angle_diff:
			smallest_angle_diff = angle_diff
			best_match = portal

	if best_match != null:
		# 计算玩家在目标传送门的位置偏移
		# Calculate player's position offset relative to target portal
		var exit_offset := Vector2(push_radius, 0).rotated(direction_angle + PI)

		# 设置玩家位置到目标传送门并应用偏移
		# Set player position to target portal and apply offset
		Game.player_manager.teleport_player.emit(best_match, exit_offset)
