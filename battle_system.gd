# battle_system.gd
# Copyright 2025 Kemi-Amu
#
# This Source Code Form is subject to the terms of the Mozilla PUBLIC
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
#
# SPDX-License-Identifier: MPL-2.0

extends Node

# [TODO] [NODE] 玩家攻击时调用
# func execute_player_attack():
# 	for enemy in active_enemies:
# 		var damage = active_player.attack_power - enemy.defense
# 		enemy.take_damage(damage)
# 	_transition_state(BattleState.ENEMY_MOVE)

# 战斗状态枚举
enum BattleState {
	PLAYER_TURN,
	ENEMY_MOVE,
	RESOLVING
}

# 信号定义
signal battle_ended(victory: bool)
signal player_action_ready

# 系统变量
var current_state: BattleState = BattleState.PLAYER_TURN  # 当前战斗状态
var active_player: CharacterBody2D = null                 # 当前玩家单位
var active_enemies: Array = []                            # 存活敌人列表

# 初始化战斗系统
func initialize(player: CharacterBody2D, enemies: Array) -> void:
	active_player = player
	active_enemies = enemies
	_start_player_turn()

# 主处理循环
func _process(delta: float) -> void:
	match current_state:
		BattleState.PLAYER_TURN:
			_process_player_turn()
		BattleState.ENEMY_MOVE:
			_process_enemy_move(delta)
		BattleState.RESOLVING:
			_process_resolving()

# 启动玩家回合
func _start_player_turn() -> void:
	player_action_ready.emit()
	current_state = BattleState.PLAYER_TURN

# 处理玩家回合逻辑
func _process_player_turn() -> void:
	if Input.is_action_just_pressed("ui_attack"):
		execute_player_attack()

# 执行玩家攻击
func execute_player_attack() -> void:
	# 简单AOE攻击实现
	for enemy in active_enemies:
		var damage = active_player.stats.attack - enemy.stats.defense
		enemy.take_damage(damage)

	_transition_state(BattleState.ENEMY_MOVE)

# 处理敌人移动阶段
func _process_enemy_move(delta: float) -> void:
	# [TODO] 后续实现敌人移动逻辑
	# 暂时直接进入结算
	_transition_state(BattleState.RESOLVING)

# 处理战斗结算
func _process_resolving() -> void:
	if check_victory():
		battle_ended.emit(true)
	elif check_defeat():
		battle_ended.emit(false)
	else:
		_transition_state(BattleState.PLAYER_TURN)

# 状态转换控制
func _transition_state(new_state: BattleState) -> void:
	current_state = new_state

# 胜利条件检查
func check_victory() -> bool:
	return active_enemies.all(func(e): return e.is_queued_for_deletion())

# 失败条件检查
func check_defeat() -> bool:
	return active_player.is_queued_for_deletion()

# 结束战斗
func end_battle(victory: bool) -> void:
	queue_free()
