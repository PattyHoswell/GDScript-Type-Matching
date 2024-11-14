class_name TestTypeMatcher extends TestParent

func _ready() -> void:
	_check_csharp_script()

func _check_simple() -> void:
	for type in Type.extending_from(self):
		match type:
			# You can use comma to check multiple types
			Area2D, StaticBody2D, CharacterBody2D:
				print("I inherited Area2D, StaticBody2D, or CharacterBody2D")
			Node2D:
				# Will print this
				print("I inherited Node2D")

func _check_csharp_script(from_resource: bool = true) -> void:
	if Type.inherit_from("TestChildCSharp", "TestParentCSharp"):
		print("TestChildCSharp inherited TestParentCSharp")
	
	if from_resource:
		print(Type.extending_from(ResourceLoader.load("res://TestChildCSharp.cs"), true))
	else:
		print(Type.extending_from(get_node("TestChildCSharp"), true))

func _check_from_inheritance_custom_class() -> void:
	for type in Type.extending_from(self):
		match type:
			TestParent:
				# Will print this
				print("I inherited TestParent")
			Node2D:
				# Will print this
				print("I inherited Node2D")

func _check_from_class() -> void:
	print(Type.extending_from(TestTypeMatcher))
	# Also works for engine class
	print(Type.extending_from(Node2D))

func _array_if_check() -> void:
	if Type.extending_from(TestTypeMatcher).has(Node2D):
		# Will print this
		print("TestTypeMatcher inherited Node2D")

func _array_if_check_name() -> void:
	if Type.extending_from(TestTypeMatcher, true).has("Node2D"):
		print("TestTypeMatcher inherited Node2D")

func _array_pattern_match_v1() -> void:
	match Type.extending_from(TestTypeMatcher):
		[TestParent]:
			# Will not print this because the size doesn't match
			print("I inherited TestParent (fixed size)")
		[Node2D, ..]:
			# Will not print this because Node2D is not the first item on the array
			print("I inherited Node2D")
		[TestParent, ..]:
			# Will print this because of the ..
			# It specify that size may be bigger than the array we're trying to match
			# And TestParent is the first item on the array
			print("I inherited TestParent")

func _array_pattern_match_v2() -> void:
	match Type.extending_from(TestTypeMatcher):
		var arr when arr.has(Node):
			# Will print this because the type inherit Node
			print("I inherited Node (binding pattern)")
	# You can also put it on a variable before matching it
	var extending_types : Array = Type.extending_from(TestTypeMatcher)
	match extending_types:
		# You can combine both match and if else check
		[TestParent, ..] when extending_types.has(Node):
			# Will print this because the type inherit Node2D and Node
			print("I inherited Node2D and Node")
		# Underscore means default
		# This is indistinguishable to an if check
		_ when extending_types.has(Node):
			# Will not print this because the first is already a match
			print("I inherited Node")

func _check_inheritance() -> void:
	print(Type.inherit_from("Area2D", "Node2D"))                    # returns true
	print(Type.inherit_from("Area2D", "Node3D"))                    # returns false
	print(Type.inherit_from("TestTypeMatcher", "Node"))             # returns true
	print(Type.inherit_from("TestChildCSharp", "TestParentCSharp")) # returns true
	print(Type.inherit_from("TestTypeMatcher", "TestParentCSharp")) # returns false
