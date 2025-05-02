# global.gd
# Copyright 2025 Kemi-Amu
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
#
# SPDX-License-Identifier: MPL-2.0

extends Node

@export var player_node: CharacterBody2D = null

func get_player_node() -> CharacterBody2D:
	return player_node

func set_player_node(new_player_node: CharacterBody2D) -> void:
	player_node = new_player_node
