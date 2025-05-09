# player_manager.gd
# Copyright 2025 Kemi-Amu
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
#
# SPDX-License-Identifier: MPL-2.0

# TODO HACK FIXME
# Player logic layer with serialization support
class_name PlayerManager
extends Node

signal player_added(player: PlayerEntity)
signal player_removed(player: PlayerEntity)

# Player entity management
var _player: PlayerEntity = null
var _pending_load_data := {}
var player_scene := preload("res://scenes/entity/player.tscn")

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
