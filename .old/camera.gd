# camera.gd
# Copyright 2025 Kemi-Amu
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
#
# SPDX-License-Identifier: MPL-2.0

extends Camera2D

@export var TARGET_VIEW_SIZE := Vector2(240, 160)  # 目标视图大小 / Target view size
@export var DOLLY_DAMPING := -7.0  # 摄像机移动阻尼 / Camera movement damping
@export var base_zoom := 1.0  # 基础缩放 / Base zoom level
@export var view_zoom := 1.0  # 视图缩放 / View zoom level
@export var target_position := Vector2(0, 0)  # 目标位置 / Target position

func _ready() -> void:
	# 窗口大小改变时调整摄像机缩放 / Adjust camera zoom when window is resized
	var window := get_window()
	window.size_changed.connect(_on_window_resized.bind(window))
	_on_window_resized(window)

func _process(delta: float) -> void:
	# 更新摄像机位置 / Update camera position
	position = position.lerp(target_position, 1 - exp(DOLLY_DAMPING * delta))

# [private] 更新摄像机缩放 / [private] Update camera zoom
func _update_zoom() -> void:
	var target_zoom := view_zoom * base_zoom
	zoom = Vector2(target_zoom, target_zoom)

# 窗口大小改变时调整摄像机 / Adjust camera when window is resized
func _on_window_resized(window: Window) -> void:
	var view_scale := Vector2(window.size) / TARGET_VIEW_SIZE
	view_zoom = max(view_scale.x, view_scale.y)
	_update_zoom()
	print("camera zoomed: ", view_zoom)

# 设置摄像机基础缩放 / Set camera base zoom
func set_base_zoom(new_zoom: float) -> void:
	base_zoom = new_zoom
	_update_zoom()

# 设置摄像机目标位置 / Set camera target position
func set_target_position(new_position: Vector2) -> void:
	target_position = new_position

# 直接设置摄像机位置 / Set camera position directly
func set_camera_position(new_position: Vector2) -> void:
	position = new_position
	target_position = new_position
