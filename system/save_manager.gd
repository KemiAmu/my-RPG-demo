# save_manager.gd
# Copyright 2025 Kemi-Amu
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
#
# SPDX-License-Identifier: MPL-2.0

# 存档管理器，满足全局动态加载和保存
# Save manager for global dynamic loading and saving
class_name SaveManager
extends Resource

# 存档文件路径
# Path to the save file
var save_path := "user://save"

# 构造函数，可自定义存档路径
# Constructor, allows custom save path
func _init(custom_path := "") -> void:
	if not custom_path.is_empty():
		save_path = custom_path

# 保存回调函数
# Save callbacks
var save_funcs := {}
# 加载回调函数
# Load callbacks
var load_funcs := {}

# 存储数据的容器，用于同步和持久化保存
# Container for storing data, used for synchronization and persistent saving
var data_box := {}

# 为给定键注册新的保存/加载处理程序
# Register a new save/load handler for a given key
func register(key: String, save_cb: Callable, load_cb: Callable) -> void:
	save_funcs[key] = save_cb
	load_funcs[key] = load_cb

	if data_box.has(key):
		load_cb.call(data_box[key])

# 通过键取消注册保存/加载处理程序
# Unregister a save/load handler by key
func unregister(key: String) -> void:
	save_funcs.erase(key)
	load_funcs.erase(key)

# 将 data_box 中所有注册数据保存到文件
# Save all registered data in data_box to file
func save() -> bool:
	for key in save_funcs:
		data_box[key] = save_funcs[key].call()

	var file := FileAccess.open(save_path, FileAccess.WRITE)
	if file:
		file.store_var(data_box)
		file.close()
	else:
		printerr("SaveManager: Failed to open save file")
		return false

	return true

# 从文件加载所有注册数据到 data_box
# Load all registered data from file into data_box
func load() -> bool:
	if not FileAccess.file_exists(save_path):
		return false

	var file := FileAccess.open(save_path, FileAccess.READ)
	if file:
		data_box = file.get_var()
		file.close()
	else:
		printerr("SaveManager: Failed to open save file")
		return false

	for key in load_funcs:
		if data_box.has(key):
			load_funcs[key].call(data_box[key])

	return true
