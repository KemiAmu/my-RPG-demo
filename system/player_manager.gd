# player_manager.gd
# Copyright 2025 Kemi-Amu
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
#
# SPDX-License-Identifier: MPL-2.0

# 实体接口
# Entity interface
extends Node

# List of player entities
var players: Array = []

func add_player(player_node: PlayerEntity) -> void:
	players.append(player_node)

func remove_player(player_node: PlayerEntity) -> void:
	players.erase(player_node)

func _physics_process(delta):
	var input_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down", 0.5)
	for player in players:
		player.handle_physics_update(input_direction, delta)
