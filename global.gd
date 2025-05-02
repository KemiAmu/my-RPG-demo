# global.gd
# Copyright 2025 Kemi-Amu
#
# This Source Code Form is subject to the terms of the Mozilla PUBLIC
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
#
# SPDX-License-Identifier: MPL-2.0

# [TODO] [NOTE] 阿 sir，别看了，总线这里全都是技术债

extends Node

# 共享的当前玩家上下文，不限于特定场景的玩家（比如怪物寻路会用到玩家坐标）
# Note: 编辑器指定
@export var player_node: CharacterBody2D = null

# [PUBLIC]
func get_player_node() -> CharacterBody2D:
	if player_node == null:
		printerr("Player node not set")
	return battle_player_node if battle_mod else player_node

# [PUBLIC] [TODO] [REMOVE] 移除（1 引用）
func set_player_node(new_player_node: CharacterBody2D) -> void:
	player_node = new_player_node


# 故事线
# [TODO] [HACK] 现阶段不支持非线性叙事
@export var story_line: Node = null

# 世界环境上下文
# [TODO] [FIXME] [HACK]
@export var world_context := "lawn.tscn"

# [PUBLIC] [TODO] [HACK]
func get_world_context() -> String:
	return world_context

# [TODO] [HACK]
@export var battle_mod := false

# [TODO] [HACK]
@export var battle_player_node: CharacterBody2D = null

# [PUBLIC] [TODO] [HACK] 开始 Battle
func start_battle(enemy: CharacterBody2D) -> void:
	battle_mod = true
	_freeze_world_and_player()
	var battle_scene = _load_battle_scene()

	if battle_scene:
		_add_battle_scene_to_container(battle_scene)
		_setup_mirror_player(battle_scene)
		_transfer_enemy_to_scene(enemy, battle_scene)
	else:
		printerr("Failed to load battle scene")

# 冻结世界场景和玩家
func _freeze_world_and_player() -> void:
	var world_container = get_node("/root/Game/WorldContainer")
	if world_container:
		world_container.call_deferred("set", "process_mode", Node.PROCESS_MODE_DISABLED)
	if player_node:
		player_node.call_deferred("hide")
		player_node.call_deferred("set_process_mode", Node.PROCESS_MODE_DISABLED)

# 加载战斗场景
func _load_battle_scene() -> Node:
	return load("res://scene_battle/" + world_context).instantiate()

# 添加战斗场景到容器
func _add_battle_scene_to_container(battle_scene: Node) -> void:  # Changed parameter type from Resource to Node
	var battle_container = get_node("/root/Game/BattleContainer")
	if battle_container:
		battle_container.call_deferred("add_child", battle_scene)  # Removed redundant instantiate()

# 配置镜像玩家
func _setup_mirror_player(battle_scene: Node) -> void:
	var ysort_node = battle_scene.get_node("YSort")
	if ysort_node:
		battle_player_node = ysort_node.get_node("Player") as CharacterBody2D
		if battle_player_node:
			battle_player_node.show()
			battle_player_node.set_process_mode(Node.PROCESS_MODE_INHERIT)
		else:
			printerr("Built-in mirror player not found")

# 转移敌人到战斗场景
func _transfer_enemy_to_scene(enemy: CharacterBody2D, battle_scene: Node) -> void:
	var ysort_node = battle_scene.get_node("YSort")
	if ysort_node:
		enemy.get_parent().call_deferred("remove_child", enemy)
		ysort_node.call_deferred("add_child", enemy)
		enemy.call_deferred("set", "position", Vector2(0, 60))
		enemy.call_deferred("set", "process_mode", Node.PROCESS_MODE_INHERIT)
		enemy.call_deferred("show")

# [PUBLIC] [TODO] [HACK] 结束 Battle，结算呢？
func end_battle() -> void:
	battle_mod = false
	battle_player_node = null
