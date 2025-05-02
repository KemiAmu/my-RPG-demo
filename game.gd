# game.gd
# Copyright 2025 Kemi-Amu
#
# This Source Code Form is subject to the terms of the Mozilla PUBLIC
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
#
# SPDX-License-Identifier: MPL-2.0

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

	# 1. 冻结 $WorldContainer
	$WorldContainer.process_mode = Node.PROCESS_MODE_DISABLED

	# 2. 加载战斗场景
	var battle_scene = load("res://scene_battle/" + world_context).instantiate()
	$BattleContainer.add_child(battle_scene)

	# [TODO] [HACK] 3. 移动怪物到战斗场景
	var ysort_node = battle_scene.get_node("YSort")
	if ysort_node:
		enemy.get_parent().remove_child(enemy)
		ysort_node.add_child(enemy)
		enemy.position = Vector2(0, 60) # [TODO] [HACK] 测试用值

# [PUBLIC] [TODO] [HACK] 结束 Battle，结算呢？
func end_battle() -> void:
	battle_mod = false
	battle_player_node = null
