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

func _on_player_entered(body: Node2D) -> void:
	# 获取玩家相对于传送门原点的位置（本地坐标）
	# Get player's position relative to portal origin (local coordinates)
	var relative_pos := body.global_position - global_position
	
	# 获取玩家相对于传送门的方向（弧度）
	# Get player's direction relative to portal (in radians)
	var direction_angle := relative_pos.angle()

	# 在切换场景前发射带有玩家位置数据的信号
	# Emit signal with player's position data before changing scene
	emit_signal("player_entered_portal", relative_pos, direction_angle)

	# 切换到下一个场景
	# Change to the next scene
	get_tree().change_scene_to_packed(next_scene)

	# 定位新场景中属于同一组的所有传送门节点
	# Locate all portal nodes in the new scene that belong to the same group
	var portals := get_tree().get_nodes_in_group("portal")
	for portal in portals:
		if portal.portal_group != portal_group:
			portals.erase(portal)

	# 获取同组传送门的中心位置
	# Get the center position of portals in the same group
	var group_center := Vector2.ZERO
	for portal in portals:
		group_center += portal.global_position
	group_center /= max(portals.size(), 1)

	# 找到与进入角度最匹配的传送门
	# Find the portal that best matches the entry angle
	var best_match: Portal = null
	var smallest_angle_diff := INF

	for portal in portals:
		# 计算传送门相对于群组中心的角度
		# Calculate portal's angle relative to group center
		var portal_angle: float = (portal.global_position - group_center).angle()

		# 计算角度差（考虑2π环绕）
		# Calculate angle difference (accounting for 2π wrap-around)
		var angle_diff: float = abs(wrapf(direction_angle - portal_angle, -PI, PI))

		if angle_diff < smallest_angle_diff:
			smallest_angle_diff = angle_diff
			best_match = portal

	if best_match != null:
		# 计算玩家在目标传送门的位置偏移
		# Calculate player's position offset relative to target portal
		var exit_offset := Vector2(push_radius, 0).rotated(direction_angle + PI)

		# 设置玩家在新传送门的位置
		# Set player's position at the new portal
		body.global_position = best_match.global_position + exit_offset
