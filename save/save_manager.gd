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

var save_funcs := {}
var load_funcs := {}
var loaded_data := {}

func register(key: String, save_cb: Callable, load_cb: Callable) -> void:
    save_funcs[key] = save_cb
    load_funcs[key] = load_cb
    
    if loaded_data.has(key):
        load_cb.call(loaded_data[key])

func save() -> void:
    var data := {}
    for key in save_funcs:
        data[key] = save_funcs[key].call()
    
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
    
    for key in load_funcs:
        if loaded_data.has(key):
            load_funcs[key].call(loaded_data[key])
