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

# 帮助 Dialogic 发出信号
func helper_emit_signal(what: String):
	signal_bus.emit_signal(what)

# 切换场景
# Switch scene
func switch_scene(new_scene: PackedScene) -> void:
	get_tree().change_scene_to_packed(new_scene)

# 信号注册
func _ready() -> void:
	signal_bus.start_game.connect(_on_start_game)
	signal_bus.exit_game.connect(func(): get_tree().quit())

# 开始游戏
func _on_start_game() -> void:
	print("INFO: _on_start_game")
	switch_scene(preload("res://scenes/world/test.tscn"))
	pass
