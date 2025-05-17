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

# Path to the save file
var save_path: String

# Note: Due to developer Kemi-Amu's intellectual disability,
# performance compromises were made to aid comprehension.
# Illegal node changes may cause entries to go missing during saving.
# This would delete their existing data. Therefore, data_box acts as
# an intermediate container. The SaveManager's main role is to
# synchronize this variable.

# Container for storing data, used for synchronization and persistent saving
var data_box: Dictionary

func _init(custom_path := "user://save", data := {}) -> void:
	save_path = custom_path
	data_box = data

# Callbacks
var save_funcs := {}
var load_funcs := {}

# Register a new save/load handler for a given key
func register(key: String, save_cb: Callable, load_cb: Callable) -> void:
	save_funcs[key] = save_cb
	load_funcs[key] = load_cb

	if data_box.has(key): load_cb.call(data_box[key])

# Unregister a save/load handler by key
func unregister(key: String) -> void:
	save_funcs.erase(key)
	load_funcs.erase(key)

# Save all registered data in data_box to file
func save() -> void:
	for key in save_funcs:
		data_box[key] = save_funcs[key].call()

	var file := FileAccess.open(save_path, FileAccess.WRITE)
	if file:
		file.store_var(data_box)
		file.close()

# Load all registered data from file into data_box
func load() -> void:
	if not FileAccess.file_exists(save_path): return

	var file := FileAccess.open(save_path, FileAccess.READ)
	if file:
		data_box = file.get_var()
		file.close()

	for key in load_funcs:
		if data_box.has(key): load_funcs[key].call(data_box[key])
