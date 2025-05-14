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
var _intermediate_data := {
	"position": Vector2.ZERO }

# 玩家实体生命周期信号
# Player entity lifecycle signals
signal on_player_ready(node: PlayerEntity)
signal on_player_exit_tree(node: PlayerEntity)

func _on_player_ready(node: PlayerEntity) -> void:
	_player = node

func _on_player_exit_tree(node: PlayerEntity) -> void:
	if _player == node: _player = null

# 生命周期回调
# Lifecycle callbacks
func _ready():
	Game.save_manager.register("player", load_player, save_player)
	on_player_ready.connect(_on_player_ready)
	on_player_exit_tree.connect(_on_player_exit_tree)

func _exit_tree():
	Game.save_manager.unregister("player")

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

# 应用玩家数据
# Apply player datas
func _apply_player_data(data: Dictionary) -> void:
	if not _player: return
	_player.position = data.get("position", _player.position)



# 玩家实体场景资源
# Player entity scene resource
# TODO HACK WONTFIX: 迁移至 Intermediate data
var player_scene := preload("res://scenes/entity/player.tscn")

# 传送玩家到指定锚点位置
# Teleports player to specified anchor position with offset
# TODO HACK XXX: 为传送门作出妥协
func teleport_player(anchor: Node, offset: Vector2) -> void:
	if not _player: _player = _spawn_player()
	_intermediate_data["position"] = anchor.position + offset
	_apply_player_data(_intermediate_data)

# 生成玩家实体实例并添加到场景中
# Spawn player entity instance and add to scene
# TODO HACK XXX: 假定节点树结构
func _spawn_player() -> PlayerEntity:
	var new_player := player_scene.instantiate() as PlayerEntity
	get_tree().current_scene.get_node("EntityLayer").add_child(new_player)
	return new_player

# 处理玩家实体物理帧更新
# Handle player entity physics frame updates
# TODO HACK XXX: 结构性技术债
func _physics_process(delta):
	if not _player: return

	var input_dir := Input.get_vector(
		"ui_left", "ui_right", 
		"ui_up"  , "ui_down" , 0.5 )
	_player.handle_physics_update(input_dir, delta)
