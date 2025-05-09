# game.gd
# Copyright 2025 Kemi-Amu
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
#
# SPDX-License-Identifier: MPL-2.0

# @autoload class_name Game
extends Node

# Global var
var save_manager := SaveManager.new()
var player_manager := PlayerManager.new()
var signal_bus := SignalBus.new()

var current_scene: Node
var _default_world := preload("res://scenes/world/overworld.tscn")

func switch_scene(new_scene: PackedScene) -> void:
	if current_scene:
		current_scene.queue_free()
	current_scene = new_scene.instantiate()
	get_tree().root.add_child.call_deferred(current_scene)

func _init():
	save_manager.register("game",
		func() -> Dictionary:
			return {
				"current_scene": current_scene.get_scene_file_path()
			} if current_scene else {},

		func(data: Dictionary):
			if data.has("current_scene"):
				call_deferred("_deferred_load_scene", data["current_scene"])
	)

func _ready():
	var load_success := save_manager.load()

	if not current_scene:
		switch_scene(_default_world)

	if not load_success:
		save_manager.save()
