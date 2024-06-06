extends Control

var pattern = []
var is_dragging = false

# Dictionary mapping valid patterns to their respective actions
var valid_patterns = {
	[1]: "Grab",
	[2]: "Block High",
	[3]: "Punch",
	[4]: "Move Left",
	[5]: "Block",
	[6]: "Move Right",
	[7]: "Special",
	[8]: "Block Low",
	[9]: "Kick",
	[5, 2]: "Jump",
	[9, 6, 3, 2, 1, 4, 7]: "Overhead Kick"
}

func _ready():
	for i in range(1, 10):
		$GridContainer.get_node("Dot" + str(i)).connect("pressed", Callable(self, "_on_Dot_pressed"), i)

# Handle mouse input for dragging between dots
func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				is_dragging = true
				_check_dot(event.position)
			else:
				is_dragging = false
				_check_pattern()

	elif event is InputEventMouseMotion and is_dragging:
		_check_dot(event.position)

# Check if the mouse is on a dot
func _check_dot(position):
	for i in range(1, 10):
		var dot = $GridContainer.get_node("Dot" + str(i))
		if dot.get_global_rect().has_point(position) and i not in pattern:
			pattern.append(i)
			dot.modulate = Color(1, 1, 0)  # Change color to indicate it's part of the pattern

func _on_Dot_pressed(dot_id):
	if dot_id not in pattern:
		pattern.append(dot_id)
	if len(pattern) == 1:  # Check if it's a single dot action
		_perform_action(dot_id)

func _perform_action(dot_id):
	if [dot_id] in valid_patterns:
		$Label.text = valid_patterns[[dot_id]]  # Display the action command
		_flash_selected_dots([dot_id], Color(0, 1, 0))  # Flash the selected dot green
		_reset_dots()

func _check_pattern():
	if pattern in valid_patterns:
		$Label.text = valid_patterns[pattern]  # Display the action command
		_flash_selected_dots(pattern, Color(0, 1, 0))  # Flash the selected dots green
	else:
		$Label.text = "Incorrect Pattern"
		_flash_selected_dots(pattern, Color(1, 0, 0))  # Flash the selected dots red for incorrect pattern
	pattern.clear()

func _flash_selected_dots(dots, color):
	for dot_id in dots:
		$GridContainer.get_node("Dot" + str(dot_id)).modulate = color
	await get_tree().create_timer(0.5).timeout  # Flash duration
	_reset_dots()

func _reset_dots():
	for i in range(1, 10):
		$GridContainer.get_node("Dot" + str(i)).modulate = Color(1, 1, 1)  # Reset color
	pattern.clear()  # Clear the pattern after resetting the dots
