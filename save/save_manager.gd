# save_manager.gd
# Copyright 2025 Kemi-Amu
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
#
# SPDX-License-Identifier: MPL-2.0

class_name SaveManager
extends Resource

const SAVE_PATH := "user://auto_save.data"

var registered_objects := {}

func save() -> void:
	var data := {}
	for key in registered_objects:
		data[key] = registered_objects[key].save()

	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_var(data)
	file.close()

func load() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	var data = file.get_var()
	file.close()

	for key in data:
		if key in registered_objects:
			registered_objects[key].load(data[key])
