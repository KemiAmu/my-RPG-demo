# save_manager.gd
# Copyright 2025 Kemi-Amu
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
#
# SPDX-License-Identifier: MPL-2.0

# 存档管理器，满足全局动态加载/保存

class_name SaveManager
extends Resource

const SAVE_PATH := "user://auto_save.data"

var registered_objects := {}
var loaded_data := {}

func register(key: String, obj: Object) -> void:
	registered_objects[key] = obj

	if loaded_data.has(key) and obj.has_method("load"):
		obj.call("load", loaded_data[key])

func save() -> void:
	var data := {}
	for key in registered_objects:
		if registered_objects[key].has_method("save"):
			data[key] = registered_objects[key].call("save")

	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_var(data)
		file.close()

func load() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		loaded_data = file.get_var()
		file.close()

	for key in registered_objects:
		if loaded_data.has(key) and registered_objects[key].has_method("load"):
			registered_objects[key].call("load", loaded_data[key])
