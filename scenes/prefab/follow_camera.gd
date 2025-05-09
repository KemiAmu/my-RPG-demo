# follow_camera.gd
# Copyright 2025 Kemi-Amu
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
#
# SPDX-License-Identifier: MPL-2.0

# Follow Camera 2D
#
# 一个带有平滑阻尼和自动缩放调整的相机，跟随目标位置并根据窗口大小自动调整缩放以保持目标视图区域
#
# 功能:
# - 可配置阻尼的平滑跟随移动
# - 自动缩放调整以保持目标视图大小
# - 独立的基础缩放和视图缩放控制
# - 可直接设置位置或平滑跟随目标
#
# 使用方法:
# 1. 将此脚本附加到 Camera2D 节点
# 2. 设置 target_position 属性使相机跟随
# 3. 调整 TARGET_VIEW_SIZE 来控制基础视图区域
# 4. 使用 set_base_zoom() 控制额外的缩放级别

# Follow Camera 2D
#
# A camera that follows a target position with smooth damping and automatic zoom adjustment
# based on window size to maintain a target view area.
#
# Features:
# - Smooth follow movement with configurable damping
# - Automatic zoom adjustment to maintain target view size
# - Separate base zoom and view zoom controls
# - Direct position setting or smooth target following
#
# Usage:
# 1. Attach this script to a Camera2D node
# 2. Set the target_position property to make the camera follow
# 3. Adjust TARGET_VIEW_SIZE to control the base view area
# 4. Use set_base_zoom() to control additional zoom levels

# 可以跟随目标的相机
# A camera that can follow targets
extends Camera2D

# 目标视图大小 / Target view size
@export var TARGET_VIEW_SIZE := Vector2(240, 160)
# 摄像机移动阻尼 / Camera movement damping
@export var DOLLY_DAMPING := -7.0
# 基础缩放 / Base zoom level
@export var base_zoom := 1.0
# 视图缩放 / View zoom level
@export var view_zoom := 1.0
# 目标位置 / Target position
@export var target_position := Vector2(0, 0)

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
