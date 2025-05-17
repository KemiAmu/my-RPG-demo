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
extends Node

# 玩家实体节点
# Player entity node
# TODO HACK WONTFIX: 弱连接，可能无效
var _player: PlayerEntity

# 玩家管理器维护的中间层数据
# Intermediate layer data maintained by player manager
var _intermediate_data := { "position": Vector2.ZERO }

# 玩家实体场景资源
# Player entity scene resource
# TODO HACK WONTFIX: 迁移至 Intermediate data
var player_scene := preload("res://scenes/entity/player.tscn")

# 玩家实体生命周期信号
# Player entity lifecycle signals
# TODO HACK: 用于兼容和阻断异常
signal player_ready(node: PlayerEntity)
signal player_unready(node: PlayerEntity)

func portal_entered(node: Node, scene: PackedScene, group: String, normal: float) -> void:
	Game.switch_scene(scene, func():
		# 定位新场景中属于同一组的所有传送门节点
		# Locate all portal nodes in the new scene that belong to the same group
		var target_portals := get_tree().get_nodes_in_group("portal")
		target_portals.erase(node)
		for p in target_portals:
			if p.portal_group != group: target_portals.erase(p)
		print(" Info: Found %d target portals in group '%s'" % [target_portals.size(), group])

		# 获取同组传送门的几何中心位置
		# Calculate the geometric center position of portals in the same group
		var group_center := Vector2.ZERO
		for p in target_portals: group_center += p.global_position
		if group_center == Vector2.ZERO: group_center /= target_portals.size()
		
		# 找到与进入角度最匹配的传送门
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
			# 计算玩家在目标传送门的位置偏移
			# Calculate player's position offset relative to target portal
			var snapped_angle := roundf((normal + PI) / (PI / 2)) * (PI / 2)
			var exit_offset := Vector2(best_match.push_radius * sqrt(2), 0).rotated(snapped_angle)
	
			# 设置玩家位置到目标传送门并应用偏移
			# Set player position to target portal and apply offset
			_teleport_player(best_match, exit_offset)
	)

func _teleport_player(anchor: Node, offset: Vector2) -> void:
	if not _player: _player = _spawn_player()
	_intermediate_data["position"] = anchor.position + offset
	_apply_player_data(_intermediate_data)
	print("Debug: Player teleported to position: %s" % str(_intermediate_data["position"]))

# 生命周期回调
# Lifecycle callbacks
func _init():
	Game.save_manager.register("player", load_player, save_player)
	player_ready.connect(_player_ready)
	player_unready.connect(_player_unready)

func _player_ready(node: PlayerEntity) -> void:
	_player = node

func _player_unready(node: PlayerEntity) -> void:
	if _player == node: _player = null

# 玩家数据序列化
# Player data serialization
# TODO HACK WONTFIX: 我知道这很烂
func load_player(data: Dictionary) -> void:
	_intermediate_data = data.duplicate()
	_apply_player_data(_intermediate_data)

func save_player() -> Dictionary:
	if _player:
		_intermediate_data["position"] = _player.position
	return _intermediate_data.duplicate()

# 生成玩家实体实例并添加到场景中
# Spawn player entity instance and add to scene
# TODO HACK XXX: 假定节点树结构
func _spawn_player() -> PlayerEntity:
	var new_player := player_scene.instantiate() as PlayerEntity
	get_tree().current_scene.get_node("EntityLayer").add_child(new_player)
	return new_player

# 应用玩家数据
# Apply player datas
func _apply_player_data(data: Dictionary) -> void:
	if not _player: return
	_player.position = data.get("position", _player.position)
