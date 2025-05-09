# welcome.gd
# Copyright 2025 Kemi-Amu
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
#
# SPDX-License-Identifier: MPL-2.0

# 游戏的开始菜单
# Game start menu
extends Node

# 使用 Dialogic
# Using Dialogic
func _ready() -> void:
	Dialogic.start("welcome")
	Dialogic.signal_event.connect(_dialogic_event)

# 事件处理器
# Event handler
func _dialogic_event(what: String) -> void:
	match what:
		"start new game":
			Game.signal_bus.start_new_game.emit()
		"load game":
			Game.signal_bus.load_game.emit()
		"exit the game":
			Game.signal_bus.exit_game.emit()
