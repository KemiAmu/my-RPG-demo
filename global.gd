# global.gd
# Copyright 2025 Kemi-Amu
#
# This Source Code Form is subject to the terms of the Mozilla PUBLIC
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
#
# SPDX-License-Identifier: MPL-2.0

# 呱

extends Node

# ========================
# 全局状态管理
# ========================
signal scene_transition_started
signal scene_transition_finished

# 玩家节点引用
var player_node: CharacterBody2D = null
var battle_player_node: CharacterBody2D = null

# 战斗系统实例
var battle_system: Node = null

# 场景上下文
@export var world_context := "lawn.tscn"
@export var battle_mod := false

# ========================
# 公共接口
# ========================
func get_player_node() -> CharacterBody2D:
	if player_node == null:
		printerr("Player node not set")
	return battle_player_node if battle_mod else player_node

func set_player_node(new_player_node: CharacterBody2D, is_battle_active: bool) -> void:
	if is_battle_active:
		battle_player_node = new_player_node
	else:
		player_node = new_player_node

# ========================
# 战斗管理
# ========================
func start_battle(enemy: CharacterBody2D) -> void:
	battle_mod = true
	_freeze_world_and_player()
	
	var battle_scene = _load_battle_scene()
	if not battle_scene:
		printerr("Failed to load battle scene")
		return
	
	_add_battle_scene_to_container(battle_scene)
	_setup_mirror_player(battle_scene)
	_transfer_enemy_to_scene(enemy, battle_scene)
	
	# 初始化战斗系统
	battle_system = preload("res://battle_system.gd").new()
	battle_system.initialize(battle_player_node, [enemy])
	battle_system.connect("battle_ended", _on_battle_ended)
	add_child(battle_system)

func end_battle(victory: bool) -> void:
	battle_mod = false
	_cleanup_battle()
	_restore_world()
	
	if battle_system:
		battle_system.queue_free()
		battle_system = null

# ========================
# 内部实现
# ========================
# global.gd 修改_freeze_world_and_player()
func _freeze_world_and_player() -> void:
	var world_container = get_node("/root/Game/WorldContainer")
	if world_container:
		world_container.call_deferred("set", "process_mode", Node.PROCESS_MODE_DISABLED)
	
	if player_node:
		# 安全禁用玩家
		player_node.call_deferred("set", "process_mode", Node.PROCESS_MODE_DISABLED)
		player_node.call_deferred("hide")
		
		# 安全禁用碰撞
		var collision = player_node.get_node("CollisionShape2D")
		if collision:
			collision.call_deferred("set", "disabled", true)

func _load_battle_scene() -> Node:
	return load("res://scene_battle/" + world_context).instantiate()

# 修改添加战斗场景的方式
func _add_battle_scene_to_container(battle_scene: Node) -> void:
	var battle_container = get_node("/root/Game/BattleContainer")
	if battle_container:
		# 使用延迟调用确保安全添加
		battle_container.call_deferred("add_child", battle_scene)

# 修改 global.gd 的 _setup_mirror_player 函数：
func _setup_mirror_player(battle_scene: Node) -> void:
	var battle_player = battle_scene.get_node("YSort/Player")
	if battle_player and player_node:
		# 直接复用场景中的玩家节点
		battle_player_node = battle_player
		# 同步主玩家状态
		battle_player_node.position = player_node.position
		battle_player_node.stats = player_node.stats.duplicate()
		battle_player_node.show()
		print("已绑定战斗场景预置玩家")
	else:
		printerr("战斗场景未配置玩家节点！")
	
# 修改 global.gd 的 _transfer_enemy_to_scene 函数：
func _transfer_enemy_to_scene(enemy: CharacterBody2D, battle_scene: Node) -> void:
	if not enemy or not is_instance_valid(enemy):
		printerr("无效的敌人实例")
		return
	
	var ysort_node = battle_scene.get_node("YSort")
	if ysort_node:
		# 确保敌人脱离原场景
		if enemy.is_inside_tree():
			enemy.get_parent().remove_child(enemy)
		
		# 直接添加（不延迟）
		ysort_node.add_child(enemy)
		enemy.owner = battle_scene
		enemy.global_position = Vector2(0, 60)
		enemy.process_mode = Node.PROCESS_MODE_INHERIT
		
		# 启用物理
		enemy.set_physics_process(true)
		var collision = enemy.get_node("CollisionShape2D")
		if collision:
			collision.disabled = false
		
		print("敌人已转移：", enemy.name, " 父节点：", enemy.get_parent().name)

func _cleanup_battle() -> void:
	var battle_container = get_node("/root/Game/BattleContainer")
	if battle_container:
		for child in battle_container.get_children():
			child.queue_free()
	
	if battle_player_node:
		battle_player_node.queue_free()
		battle_player_node = null

func _restore_world() -> void:
	var world_container = get_node("/root/Game/WorldContainer")
	if world_container:
		world_container.process_mode = Node.PROCESS_MODE_INHERIT
	
	if player_node:
		player_node.show()
		player_node.process_mode = Node.PROCESS_MODE_INHERIT

# ========================
# 信号处理
# ========================
func _on_battle_ended(victory: bool) -> void:
	end_battle(victory)
	print("Battle ended with victory: %s" % victory)
