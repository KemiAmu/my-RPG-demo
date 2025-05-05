# battle_system.gd
# Copyright 2025 Kemi-Amu
#
# This Source Code Form is subject to the terms of the Mozilla PUBLIC
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
#
# SPDX-License-Identifier: MPL-2.0

extends Node

# 战斗状态枚举
enum BattleState {
	INIT,		 # 初始化阶段
	PLAYER_TURN,  # 玩家回合
	ENEMY_MOVE,   # 敌人移动阶段
	RESOLVING	 # 结算阶段
}

# 信号定义
signal battle_ended(victory: bool)
signal player_action_ready

# 系统变量
var current_state: BattleState = BattleState.INIT
var active_player: CharacterBody2D = null
var active_enemies: Array = []

# ========================
# 核心逻辑
# ========================
func initialize(player: CharacterBody2D, enemies: Array) -> void:
	active_player = player
	active_enemies = enemies
	# 不再需要duplicate()
	_transition_state(BattleState.INIT)

func _process(delta: float) -> void:
	match current_state:
		BattleState.INIT:
			pass  # 初始化阶段由_transition_state处理
		BattleState.PLAYER_TURN:
			_process_player_turn()
		BattleState.ENEMY_MOVE:
			_process_enemy_move(delta)
		BattleState.RESOLVING:
			_process_resolving()

# ========================
# 状态管理
# ========================
func _transition_state(new_state: BattleState) -> void:
	current_state = new_state
	match new_state:
		BattleState.INIT:
			_setup_battle()
		BattleState.PLAYER_TURN:
			player_action_ready.emit()
		BattleState.ENEMY_MOVE:
			_start_enemy_move()

func _setup_battle() -> void:
	print("战斗初始化完成")
	_transition_state(BattleState.PLAYER_TURN)

# ========================
# 回合逻辑
# ========================
func _process_player_turn() -> void:
	if Input.is_action_just_pressed("ui_accept"):  # 使用默认的确认键
		execute_player_attack()

func _start_enemy_move() -> void:
	# [TODO] 添加敌人移动逻辑
	_transition_state(BattleState.RESOLVING)

func _process_enemy_move(delta: float) -> void:
	pass  # 移动逻辑在_start_enemy_move处理

func _process_resolving() -> void:
	if check_victory():
		battle_ended.emit(true)
	elif check_defeat():
		battle_ended.emit(false)
	else:
		_transition_state(BattleState.PLAYER_TURN)

# ========================
# 行动系统
# ========================
func execute_player_attack() -> void:
	# 简单AOE攻击实现
	for enemy in active_enemies:
		var damage = active_player.stats.attack - enemy.stats.defense
		enemy.take_damage(damage)
	_transition_state(BattleState.ENEMY_MOVE)

# ========================
# 胜负判定
# ========================
func check_victory() -> bool:
	return active_enemies.all(func(e): return e.is_queued_for_deletion())

func check_defeat() -> bool:
	return active_player.is_queued_for_deletion()

# ========================
# 生命周期
# ========================
func end_battle(victory: bool) -> void:
	battle_ended.emit(victory)
	queue_free()
