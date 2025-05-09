# game.gd
# Copyright 2025 Kemi-Amu
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
#
# SPDX-License-Identifier: MPL-2.0

# TODO HACK FIXME
# @autoload class_name Game
extends Node

# Global var
var save_manager := SaveManager.new()
var player_manager := PlayerManager.new()
var signal_bus := SignalBus.new()

var current_scene: Node
var _default_world := preload("res://scenes/world/overworld.tscn")

func switch_scene(new_scene: PackedScene) -> void:
	if current_scene:
		# 确保完全移除旧场景
		current_scene.queue_free()
		await current_scene.tree_exited  # 等待场景完全退出
	
	# 显式设置新场景为根节点的唯一子节点
	var root = get_tree().root
	for child in root.get_children():
		if child != self:  # 保留 Game 单例
			child.queue_free()
	
	current_scene = new_scene.instantiate()
	root.add_child(current_scene)


func _init():
	save_manager.register("game",
		func() -> Dictionary: return {"current_scene": current_scene.scene_file_path},
		# 使用 bind() 绑定作用域
		func(data: Dictionary):
			if data.has("current_scene"):
				call_deferred("_load_scene_deferred", data["current_scene"])
	)

# 明确的场景加载方法
func _load_scene_deferred(scene_path: String) -> void:
	var scene := load(scene_path) as PackedScene
	if scene:
		switch_scene(scene)
		print("场景加载完成: ", scene_path)
	else:
		printerr("无效的场景路径: ", scene_path)

func _ready() -> void:
	# 确保所有节点完成初始化
	await get_tree().process_frame
	
	# 优先加载存档场景
	# if save_manager.load():
	# 	if not current_scene:
	# 		switch_scene(_default_world)
	# else:
	# 	# 初始化新游戏
	# 	switch_scene(_default_world)
	# 	save_manager.save()
