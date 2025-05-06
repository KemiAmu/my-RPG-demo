# game_manager.gd
# Copyright 2025 Kemi-Amu
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
#
# SPDX-License-Identifier: MPL-2.0

extends Node

@onready var save_manager = SaveManager.new()

func _ready():
	if save_manager.load():
		print("Game loaded successfully.")
	else:
		print("Failed to load save data.")
