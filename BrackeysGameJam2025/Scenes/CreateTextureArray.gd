extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var images = [
		preload("uid://cyim73qh68m3m").get_image(), preload("uid://be5arvi3hrw50").get_image(), preload("uid://dkkxol05yvvg1").get_image(),
		preload("uid://bv6o7e2priip7").get_image(), preload("uid://d0er6tcrwd4wa").get_image(), preload("uid://devjv5f72a82k").get_image(),
		preload("uid://beyd62rikorgp").get_image(), preload("uid://cdavl4ij0c4cr").get_image(), preload("uid://cfdnt0haf6a6b").get_image()
		#preload("uid://djbkikvehpcs7").get_image()
	]
	var LAYERS: int = images.size()

	# Create and save a 2D texture array. The array of images must have at least 1 Image.
	var texture_2d_array = Texture2DArray.new()
	texture_2d_array.create_from_images(images)
	ResourceSaver.save(texture_2d_array, "res://clouds_2d_array.res", ResourceSaver.FLAG_COMPRESS)
