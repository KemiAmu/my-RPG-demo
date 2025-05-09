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

func switch_scene(new_scene: PackedScene) -> void:
	if current_scene:
		current_scene.queue_free()
	current_scene = new_scene.instantiate()
	get_tree().root.add_child(current_scene)

func _ready():
	save_manager.register( "game",
		func() -> Dictionary:
			return {
				"current_scene": current_scene.get_scene_file_path()
			} if current_scene else {},

		func(data: Dictionary) -> void:
			if data.has("current_scene"):
				var scene := load(data["current_scene"]) as PackedScene
				if scene:
					switch_scene(scene)
	)

	if save_manager.load():
		if not current_scene:
			switch_scene(preload("res://scenes/world/overworld.tscn"))
	else:
		switch_scene(preload("res://scenes/world/overworld.tscn"))
