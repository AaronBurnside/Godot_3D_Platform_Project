extends RigidBody


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var gravity = ProjectSettings.get_setting("physics/3d/default_gravity") * ProjectSettings.get_setting("physics/3d/default_gravity_vector")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _physics_process(delta):
	if self.global_translation.y <= -11:
		if LevelSingleton.Level == "res://Stage_1.tscn":
			self.global_translation = Vector3(1, 2, 1)
		elif LevelSingleton.Level == "res://Stage2.tscn":
			self.global_translation = Vector3(1, 3, 1)
		
	if self.global_translation.x <= -30.5:
		if self.global_translation.z <= 2.5 and self.global_translation.z >= -6:
			if LevelSingleton.Level == "res://Stage_1.tscn":
				get_tree().change_scene("res://Stage2.tscn")
			elif LevelSingleton.Level == "res://Stage2.tscn":
				get_tree().change_scene("res://Victory.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
