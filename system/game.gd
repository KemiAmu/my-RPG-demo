# game.gd
# Copyright 2025 Kemi-Amu
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
#
# SPDX-License-Identifier: MPL-2.0

# 主游戏脚本
# Main game script
extends Node

# Global variable
var save_manager := SaveManager.new()
var signal_bus := SignalBus.new()

@onready var player_manager := PlayerManager.new()

# Switch scene
signal scene_changed

func switch_scene(next_scene: PackedScene, callback := (func(): pass)) -> void:
	if next_scene:
		(func():
			get_tree().change_scene_to_packed(next_scene)
			while not get_tree().current_scene: await get_tree().process_frame
			await get_tree().current_scene.ready
			scene_changed.emit()
		).call_deferred()
		await scene_changed
	callback.call_deferred()

# 进入节点树
func _ready() -> void:
	# 转发 Dialogic 信号到 SignalBus
	Dialogic.signal_event.connect(func(what: String) -> void:
		signal_bus.emit_signal(what)
	)
	
	# 开始游戏
	signal_bus.start_game.connect(func() -> void:
		print(" Info: signal_bus.start_game")
		switch_scene(preload("res://scenes/world/test.tscn"))
	)
	# 退出游戏
	signal_bus.exit_game.connect(func() -> void:
		print(" Info: signal_bus.exit_game")
		get_tree().quit()
	)
	
	# 空载存档
	save_manager.load()
