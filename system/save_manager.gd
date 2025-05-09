# save_manager.gd
# Copyright 2025 Kemi-Amu
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
#
# SPDX-License-Identifier: MPL-2.0

# Save Manager 文档
#
# SaveManager 类提供了一个集中式的游戏存档数据管理系统。
# 它允许为游戏的不同部分注册保存/加载回调函数，
# 处理数据序列化到磁盘的操作，并通过适当的回调执行来管理数据加载。
#
# 主要特性:
# - 用户目录中的持久化数据存储（跨平台）
# - 通过基于键的注册支持多个独立的存档系统
# - 数据加载时自动执行回调
# - 线程安全的文件操作
#
# 使用方法:
# 1. 创建一个 SaveManager 资源（通常作为自动加载的单例）
# 2. 使用 register() 从不同游戏系统注册保存/加载回调
# 3. 调用 save() 持久化所有注册的数据
# 4. 调用 load() 恢复之前保存的数据
#
# 注意: 所有回调必须是绑定方法（如果需要可使用 funcref()）
# 存档文件存储在 Godot 的 user:// 目录下（参见 OS.get_user_data_dir()）

# Save Manager Documentation
#
# The SaveManager class provides a centralized system for managing game save data.
# It allows registration of save/load callbacks for different parts of the game,
# handles serialization to disk, and manages data loading with proper callback execution.
#
# Key Features:
# - Persistent data storage in user directory (platform-independent)
# - Support for multiple independent save systems through key-based registration
# - Automatic callback execution when data is loaded
# - Thread-safe file operations
#
# Usage:
# 1. Create a SaveManager resource (typically as an autoload singleton)
# 2. Register save/load callbacks from different game systems using register()
# 3. Call save() to persist all registered data
# 4. Call load() to restore previously saved data
#
# Note: All callbacks must be bound methods (use funcref() if needed)
# The save file is stored in Godot's user:// directory (see OS.get_user_data_dir())

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
