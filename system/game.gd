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
	pass
	# await get_tree().process_frame
