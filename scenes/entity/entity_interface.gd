# entity_interface.gd
# Copyright 2025 Kemi-Amu
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
#
# SPDX-License-Identifier: MPL-2.0

# 实体接口
# Entity interface
extends CharacterBody2D
class_name EntityInterface



# 实体状态
# Entity State
enum EntityState { IDLE, MOVE, DASH, JUMP }

# 当前角色状态（来自State枚举）
# Current state of the character from State enum
@export var current_state := EntityState.IDLE

# 获取当前实体状态
# Get current entity state
func get_current_state() -> EntityState:
	return current_state

# 设置当前实体状态
# Set current entity state
func set_current_state(new_state: EntityState) -> void:
	current_state = new_state



# 面向方向更新模式
# Facing direction update modes
# TRACK: 4方向移动（上/下/左/右）
# TRACK: 4-way directional movement (up/down/left/right)
# HORIZONTAL: 仅水平移动（左/右）
# HORIZONTAL: Horizontal-only movement (left/right)
enum FacingMode { TRACK, HORIZONTAL }

# 更新面向方向的方法
# Method to update facing direction
@export var facing_updater := FacingMode.TRACK

# 当前实体的面向方向
# Current facing direction of the entity
var facing_direction := Vector2.RIGHT

# 根据输入确定面向方向
# Determine facing direction based on input
func set_facing_direction(target_direction: Vector2) -> void:
	if facing_updater == FacingMode.TRACK \
	and abs(target_direction.x) * 1.2 < abs(target_direction.y):
		facing_direction = Vector2(0, signf(target_direction.y))
	facing_direction = Vector2(signf(target_direction.x), 0)

# 根据目标方向和当前面向更新方法更新面向方向
# Updates facing direction based on target direction and current facing updater method
func update_facing_direction(target_direction: Vector2) -> void:
	if target_direction != Vector2.ZERO:
		set_facing_direction(target_direction)



# 将实体状态映射到对应的动画名称
# Maps entity states to their corresponding animation names
const ENTITY_STATE_MAP := {
		EntityState.IDLE: "idle",
		EntityState.MOVE: "move",
		EntityState.DASH: "dash",
		EntityState.JUMP: "jump"
}

# 将 Vector2 方向映射到对应的字符串名称
# Maps Vector2 directions to their corresponding string names
const ENTITY_FACING_MAP := {
		Vector2.RIGHT: "right",
		Vector2.LEFT: "left",
		Vector2.DOWN: "down",
		Vector2.UP: "up"
}

# 角色动画的 AnimationPlayer 节点引用
# Reference to the AnimationPlayer node for character animations
@export var animation_player: AnimationPlayer

# 播放动画的函数
# Function to play an animation
func play_animation(animation_name: String) -> void:
		animation_player.play(animation_name)



# 移动速度（像素/秒）
# Movement speed in pixels per second
@export var move_speed := 100.0
# 移动平滑的阻尼系数（负值）
# Damping factor for movement smoothing (negative value)
@export var move_damping := -20.0

# 处理角色移动
# Handle character movement
# 注意：应该在_physics_process(delta) 中调用以获得正确的物理帧计时
# Note: Should be called from _physics_process(delta) for proper physics frame timing
func apply_movement(target_direction: Vector2, damping: float, delta) -> void:
	velocity = velocity.lerp (
		target_direction.normalized() * move_speed,
		1 - exp(damping * move_damping * delta)
	)
	move_and_slide()



# 向目标方向移动（自动更新面向方向）
# Move towards target direction (automatically updates facing direction)
# 注意：应该在 _physics_process(delta) 中调用以获得正确的物理帧计时
# Note: Should be called from _physics_process(delta) for proper physics frame timing
func traveling_towards(target_direction: Vector2, damping: float, delta) -> void:
	update_facing_direction(target_direction)
	play_animation(ENTITY_STATE_MAP[current_state]
		+ "_"
		+ ENTITY_FACING_MAP[facing_direction])
	apply_movement(target_direction, damping, delta)

# 移动到目标位置（自动更新面向方向）
# Move to target position (automatically updates facing direction)
# 注意：应该在 _physics_process(delta) 中调用以获得正确的物理帧计时
# Note: Should be called from _physics_process(delta) for proper physics frame timing
func traveling_to(target_position: Vector2, damping: float, delta) -> void:
	traveling_towards((target_position - position), damping, delta)
