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
@warning_ignore("unused_signal")
signal start_game
@warning_ignore("unused_signal")
signal exit_game

# TODO
# 传送门触发
# Portal trigger
@warning_ignore("unused_signal")
signal portal_triggered(destination: String)

# TODO HACK TEST
@warning_ignore("unused_signal")
signal battle_triggered(enemies: Array)
