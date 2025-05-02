# game.gd
# Copyright 2025 Kemi-Amu
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
#
# SPDX-License-Identifier: MPL-2.0

extends Node


# [TODO]
@export var battle_mod := false

# [TODO]
@export var battle_player_node: CharacterBody2D = null

# 共享的当前玩家上下文，不限于特定场景的玩家（比如怪物寻路会用到玩家坐标）
@export var player_node: CharacterBody2D = null

func get_player_node() -> CharacterBody2D:
	return battle_player_node if battle_mod else player_node

func set_player_node(new_player_node: CharacterBody2D) -> void:
	player_node = new_player_node
