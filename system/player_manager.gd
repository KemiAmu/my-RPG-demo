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
class_name PlayerManager
extends Node

# 玩家基础数据和容器
# Player base data and containers
var _player: PlayerEntity
var _player_data_box := {}
var player_scene := preload("res://scenes/entity/player.tscn")

# 节点生命周期回调
# Node lifecycle callbacks
func _ready():
	Game.save_manager.register("player", load_player, save_player)

func _exit_tree():
	Game.save_manager.unregister("player")

# TODO WONTFIX HACK 空集/默认值 未预料的行为

# 玩家数据序列化
# Player data serialization
func load_player(data: Dictionary) -> void:
	_player_data_box = data.duplicate()
	_apply_player_data(_player_data_box)

func save_player() -> Dictionary:
	return {
		"position": _player.position
	} if _player else {}












# ############################## 以下内容全部删掉 ##############################
# ############################## 我正在做重构相关 ##############################




func _apply_player_data(data: Dictionary) -> void:
	if data.has("position"):
		_player.position = data["position"]
	if data.has("state"):
		_player.state_machine.transition_to(data["state"])















# TODO HACK FIXME 这是一个临时实现 AI 乱写的（

signal player_added(player: PlayerEntity)
signal player_removed(player: PlayerEntity)

signal teleported(anchor: Portal, offset: Vector2)

#region Persistence
# 注册玩家数据持久化回调
func _ready():
	Game.save_manager.register("player", load_player, save_player)

# 注销持久化回调
func _exit_tree():
	Game.save_manager.unregister("player")

# 加载玩家数据（立即应用或暂存待用）
func load_player(data: Dictionary) -> void:
	if _player:
		_apply_player_data(data)
	else:
		_pending_load_data = data.duplicate()
		_spawn_player_from_data()

# 序列化当前玩家状态
func save_player() -> Dictionary:
	return {
		"position": _player.position,
		"state": _player.current_state
	} if _player else {}

# 应用存储的玩家数据
func _apply_player_data(data: Dictionary) -> void:
	if data.has("position"):
		_player.position = data["position"]
	if data.has("state"):
		_player.state_machine.transition_to(data["state"])
#endregion

#region Player Management
# 动态生成玩家实体
func _spawn_player_from_data() -> void:
	if not player_scene or _player:
		return

	var new_player = player_scene.instantiate()
	get_tree().current_scene.add_child(new_player)
	add_player(new_player)

# 添加并初始化玩家实体
func add_player(player_node: PlayerEntity) -> void:
	if _player == player_node:
		return

	if _player:
		remove_player(_player)

	_player = player_node
	_player.tree_exited.connect(remove_player.bind(_player))

	if not _pending_load_data.is_empty():
		_apply_player_data(_pending_load_data)
		_pending_load_data.clear()

	player_added.emit(_player)

# 移除玩家实体并清理引用
func remove_player(player_node: PlayerEntity) -> void:
	if _player == player_node:
		_player.tree_exited.disconnect(remove_player)
		_player = null
		player_removed.emit(player_node)

# 传送玩家到指定锚点位置
func teleport_player(anchor: Portal, offset: Vector2) -> void:
	if not _player:
		return

	# 保存当前状态并移除旧玩家实体
	var saved_state = save_player()
	remove_player(_player)

	# 创建新玩家实例并应用位置偏移
	_pending_load_data = saved_state
	if _pending_load_data.has("position"):
		_pending_load_data["position"] = anchor.position + offset

	_spawn_player_from_data()
	teleported.emit(anchor, offset)
#endregion

#region Input Handling
# 处理玩家实体物理帧更新
func _physics_process(delta):
	if not _player:
		return

	var input_dir := Input.get_vector(
		"ui_left", "ui_right", 
		"ui_up", "ui_down", 
		0.5
	)
	_player.handle_physics_update(input_dir, delta)
#endregion
