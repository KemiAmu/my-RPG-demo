# My RPG Demo
# Copyright 2025 Kemi-Amu
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
#
# SPDX-License-Identifier: MPL-2.0

extends Camera2D

@export var TARGET_VIEW_SIZE: Vector2 = Vector2(240, 160)
@export var DOLLY_DAMPING: float = -6.0
@export var base_zoom: float = 1.0
@export var target_position: Vector2 = Vector2(0, 0)

# resize the camera when window resized
func _on_window_resized(window: Window) -> void:
	var view_scale: Vector2 = Vector2(window.size) / TARGET_VIEW_SIZE
	var view_zoom: float = max(view_scale.x, view_scale.y) * base_zoom
	self.zoom = Vector2(view_zoom, view_zoom)
	print("camera zoomed: ", view_zoom)

# set the target position of the camera
func set_target_position(new_position: Vector2) -> void:
	target_position = new_position

func _ready() -> void:
	# change the camera zoom if window resized
	var window: Window = get_window()
	window.size_changed.connect(_on_window_resized.bind(window))
	_on_window_resized(window)
	
func _process(delta: float) -> void:
	# update the camera position
	position = position.lerp(target_position, 1 - exp(DOLLY_DAMPING * delta))
