# global.gd
# Copyright 2025 Kemi-Amu
#
# This Source Code Form is subject to the terms of the Mozilla PUBLIC
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
#
# SPDX-License-Identifier: MPL-2.0

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
    battle_system.initialize(battle_player_node, [enemy], 1)
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
func _freeze_world_and_player() -> void:
    var world_container = get_node("/root/Game/WorldContainer")
    if world_container:
        world_container.process_mode = Node.PROCESS_MODE_DISABLED
    
    if player_node:
        player_node.hide()
        player_node.process_mode = Node.PROCESS_MODE_DISABLED

func _load_battle_scene() -> Node:
    return load("res://scene_battle/" + world_context).instantiate()

func _add_battle_scene_to_container(battle_scene: Node) -> void:
    var battle_container = get_node("/root/Game/BattleContainer")
    if battle_container:
        battle_container.add_child(battle_scene)

func _setup_mirror_player(battle_scene: Node) -> void:
    var spawn_point = battle_scene.get_node("YSort/PlayerSpawn")
    if spawn_point and player_node:
        battle_player_node = player_node.duplicate()
        spawn_point.add_child(battle_player_node)
        battle_player_node.global_position = spawn_point.global_position
        battle_player_node.show()

func _transfer_enemy_to_scene(enemy: CharacterBody2D, battle_scene: Node) -> void:
    var ysort_node = battle_scene.get_node("YSort")
    if ysort_node:
        enemy.get_parent().remove_child(enemy)
        ysort_node.add_child(enemy)
        enemy.global_position = Vector2(0, 60)
        enemy.show()

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
