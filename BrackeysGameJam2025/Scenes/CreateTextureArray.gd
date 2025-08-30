extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var order: Array[int] = [2, 3, 4, 5, 6, 7, 8, 9, 11, 12, 10, 1]
	var images: Array[Image] = []
	
	var stringToReplace: String = "res://Resources/Assets/Birds/far_bird%d.png"
	for i in order:
		var imagePath: String = stringToReplace % i
		var test = load(imagePath)
		images.push_back(test.get_image())
	
	# Create and save a 2D texture array. The array of images must have at least 1 Image.
	var texture_2d_array := Texture2DArray.new()
	texture_2d_array.create_from_images(images)
	ResourceSaver.save(texture_2d_array, "res://bird_2d_array.res", ResourceSaver.FLAG_COMPRESS)
