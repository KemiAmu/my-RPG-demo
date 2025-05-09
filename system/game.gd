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

# Global variable
var save_manager := SaveManager.new()
var player_manager := PlayerManager.new()
var signal_bus := SignalBus.new()

# 切换场景
# Switch scene
func switch_scene(new_scene: PackedScene) -> void:
	get_tree().change_scene_to_packed(new_scene)

# 信号注册
func _ready() -> void:
	# 转发 Dialogic 信号到 SignalBus
	Dialogic.signal_event.connect(func(what: String) -> void:
		signal_bus.emit_signal(what)
	)
	
	# 开始游戏
	signal_bus.start_game.connect(func() -> void:
		print("INFO: _on_start_game")
		switch_scene(preload("res://scenes/world/test.tscn"))
	)
	# 退出游戏
	signal_bus.exit_game.connect(func() -> void:
		print("INFO: _on_exit_game")
		get_tree().quit()
	)
