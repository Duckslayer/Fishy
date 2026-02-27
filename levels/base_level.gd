extends Resource

class_name BaseLevel

## Base class for levels. Subclasses define which fish can spawn at
## which depths and with what relative probability.

## Override in subclasses to return the list of spawn entries.
func _get_entries() -> Array:
	return []

## Returns a random fish PackedScene appropriate for the given depth.
func draw_fish(depth: float) -> PackedScene:
	var entries := _get_entries()
	var eligible: Array = []
	var total_weight := 0.0

	for entry in entries:
		if depth >= entry.min_depth:
			eligible.append(entry)
			total_weight += entry.weight

	if eligible.is_empty():
		# Fallback: return the first entry regardless of depth
		return entries[0].scene

	var roll := randf() * total_weight
	var cumulative := 0.0
	for entry in eligible:
		cumulative += entry.weight
		if roll <= cumulative:
			return entry.scene

	return eligible.back().scene

## Returns how far off-screen (in pixels) a fish scene should spawn
## so that it does not pop into view. Override to customise per-level.
func get_spawn_margin(_scene: PackedScene) -> float:
	return 150.0
