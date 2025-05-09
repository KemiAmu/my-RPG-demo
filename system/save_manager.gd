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
const SAVE_PATH := "user://save.data"

# 保存回调函数
# Save callbacks
var save_funcs := {}
# 加载回调函数
# Load callbacks
var load_funcs := {}
# 存储已加载数据的字典
# Dictionary to store loaded data
var loaded_data := {}

# 为给定键注册新的保存/加载处理程序
# Register a new save/load handler for a given key
func register(key: String, save_cb: Callable, load_cb: Callable) -> void:
	save_funcs[key] = save_cb
	load_funcs[key] = load_cb

	if loaded_data.has(key):
		load_cb.call(loaded_data[key])

# 通过键取消注册保存/加载处理程序
# Unregister a save/load handler by key
func unregister(key: String) -> void:
	save_funcs.erase(key)
	load_funcs.erase(key)

# 将所有注册数据保存到文件
# Save all registered data to file
func save() -> bool:
	var data := {}
	for key in save_funcs:
		data[key] = save_funcs[key].call()

	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_var(data)
		file.close()
	else:
		printerr("SaveManager: Failed to open save file")
		return false

	return true

# 从文件加载所有注册数据
# Load all registered data from file
func load() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		return false

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		loaded_data = file.get_var()
		file.close()
	else:
		printerr("SaveManager: Failed to open save file")
		return false

	for key in load_funcs:
		if loaded_data.has(key):
			load_funcs[key].call(loaded_data[key])

	return true
