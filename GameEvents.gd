extends Node

## Global signal bus — no state, just signals.

signal fish_kill(value: int)
signal intensity_changed(value: float)
signal fish_impaled(appearance: Node2D)
signal tier_changed(new_tier: int, old_tier: int)
