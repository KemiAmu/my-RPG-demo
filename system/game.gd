# game.gd
# Copyright 2025 Kemi-Amu
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
#
# SPDX-License-Identifier: MPL-2.0

# TODO HACK FIXME

# 主游戏脚本
# Main game script
extends Node

# Global var
var save_manager := SaveManager.new()
var player_manager := PlayerManager.new()
var signal_bus := SignalBus.new()

# 切换场景
# Switch scene
func switch_scene(new_scene: PackedScene) -> void:
	pass
	# TODO

func _ready() -> void:
	signal_bus.start_new_game.connect(_on_start_new_game)
	signal_bus.load_game.connect(_on_load_game)
	signal_bus.exit_game.connect(_on_exit_game)

func _on_start_new_game() -> void:
	# 开始新游戏逻辑
	pass

func _on_load_game() -> void:
	# 加载游戏逻辑
	pass

func _on_exit_game() -> void:
	# 退出游戏逻辑
	get_tree().quit()
