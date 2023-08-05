extends Node

var loader = null
func goto_scene(path): # Game requests to switch to this scene.
	var root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() -1)
	loader = ResourceLoader.load_interactive(path)
	if loader == null: # Check for errors.
		print("loading error")
		return
	set_process(true)

	wait_frames = 1

var wait_frames
var time_max = 100 # msec
var current_scene
func _process(_time):
	if loader == null:
		# no need to process anymore
		set_process(false)
		return

	# Wait for frames to let the "loading" animation show up.
	if wait_frames > 0:
		wait_frames -= 1
		return

	var t = OS.get_ticks_msec()
	# Use "time_max" to control for how long we block this thread.
	while OS.get_ticks_msec() < t + time_max:
		# Poll your loader.
		var err = loader.poll()

		if err == ERR_FILE_EOF: # Finished loading.
			var resource = loader.get_resource()
			loader = null
			set_new_scene(resource)
			print("scene switched success")
			break
		elif err == OK:
			pass
		else: # Error during loading.
			print(err)
			loader = null
			break
func set_new_scene(scene_resource):
	current_scene.queue_free() # Get rid of the old scene.
	current_scene = scene_resource.instance()
	get_node("/root").add_child(current_scene)
