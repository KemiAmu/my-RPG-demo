# signal_bus.gd
# Copyright 2025 Kemi-Amu
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
#
# SPDX-License-Identifier: MPL-2.0

# 全局信号总线
# Global signal bus
class_name SignalBus
extends Node

# 游戏的欢迎界面
# Game welcome screen
signal start_new_game
signal load_game
signal exit_game

# TODO HACK TEST
signal battle_triggered(enemies: Array)
