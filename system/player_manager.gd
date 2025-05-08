# player_manager.gd
# Copyright 2025 Kemi-Amu
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
#
# SPDX-License-Identifier: MPL-2.0

# 玩家逻辑层
# Player logic layer
extends Node

# Save and load
func _ready():
	SaveManager.register("player", load_player, save_player)

func _exit_tree():
	SaveManager.unregister("player")

func load_player(data: Dictionary) -> void:
	if players.size() > 0:
		var player = players[0]
		if data.has("position"):
			player.position = data["position"]
		if data.has("state"):
			player.current_state = data["state"]

func save_player() -> Dictionary:
	var data := {}
	if players.size() > 0:
		var player = players[0]
		data["position"] = player.position
		data["state"] = player.current_state
	return data

# List of player entities
var players := []

func add_player(player_node: PlayerEntity) -> void:
	if player_node not in players:
		players.append(player_node)

func remove_player(player_node: PlayerEntity) -> void:
	if player_node in players:
		players.erase(player_node)

# Pass control down
func _physics_process(delta):
	var input_direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down", 0.5)
	for player in players:
		player.handle_physics_update(input_direction, delta)
