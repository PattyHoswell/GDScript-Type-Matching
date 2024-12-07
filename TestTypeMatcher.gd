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

func _array_if_in_check():
	if Node2D in Type.extending_from(self):
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
	print(Type.inherit_from("Area2D", "Node2D"))                    # print true
	print(Type.inherit_from("Area2D", "Node3D"))                    # print false
	print(Type.inherit_from("TestTypeMatcher", "Node"))             # print true
	print(Type.inherit_from("TestChildCSharp", "TestParentCSharp")) # print true
	print(Type.inherit_from("TestTypeMatcher", "TestParentCSharp")) # print false

func _check_type_name() -> void:
	print(Type.as_type_name(null))                           # print Nil
	print(Type.as_type_name(Node))                           # print Node
	print(Type.as_type_name(Node2D.new()))                   # print Node2D
	print(Type.as_type_name(TestParent))                     # print TestParent
	print(Type.as_type_name(TestTypeMatcher.new()))          # print TestTypeMatcher
	print(Type.as_type_name(TestParentCSharp))               # print TestParentCSharp
	print(Type.as_type_name(0))                              # print int
	print(Type.as_type_name(0.0))                            # print float
	print(Type.as_type_name([]))                             # print Array
	print(Type.as_type_name(Array()), " (constructor)")      # print Array (constructor)
	var typed_array_engine_class : Array[Vector2]
	print(Type.as_type_name(typed_array_engine_class))       # print Array[Vector2]
	var typed_array_custom_class : Array[TestTypeMatcher]
	print(Type.as_type_name(typed_array_custom_class))       # print Array[TestTypeMatcher]
	print(Type.as_type_name({}))                             # print Dictionary
	print(Type.as_type_name(Dictionary()), " (constructor)") # print Dictionary (constructor)

func _check_all_built_in_type_name() -> void:
	print(Type.as_type_name(null))                           # print Nil
	print(Type.as_type_name(false))                          # print bool
	print(Type.as_type_name(bool()), " (constructor)")       # print bool (constructor)
	print(Type.as_type_name(0))                              # print int
	print(Type.as_type_name(int()), " (constructor)")        # print int (constructor)
	print(Type.as_type_name(0.0))                            # print float
	print(Type.as_type_name(float()), " (constructor)")      # print float (constructor)
	print(Type.as_type_name(""))                             # print String
	print(Type.as_type_name(String()), " (constructor)")     # print String (constructor)
	print(Type.as_type_name(&""))                            # print StringName
	print(Type.as_type_name(StringName()), " (constructor)") # print StringName (constructor)
	print(Type.as_type_name(^""))                            # print NodePath
	print(Type.as_type_name(NodePath()), " (constructor)")   # print NodePath (constructor)
	print(Type.as_type_name(Vector2.ZERO))                   # print Vector2
	print(Type.as_type_name(Vector2i.ZERO))                  # print Vector2i
	print(Type.as_type_name(Rect2()))                        # print Rect2
	print(Type.as_type_name(Rect2i()))                       # print Rect2i
	print(Type.as_type_name(Vector3.ZERO))                   # print Vector3
	print(Type.as_type_name(Vector3i.ZERO))                  # print Vector3i
	print(Type.as_type_name(Vector4.ZERO))                   # print Vector4
	print(Type.as_type_name(Vector4i.ZERO))                  # print Vector4i
	print(Type.as_type_name(Transform2D.IDENTITY))           # print Transform2D
	print(Type.as_type_name(Plane()))                        # print Plane
	print(Type.as_type_name(Quaternion.IDENTITY))            # print Quaternion
	print(Type.as_type_name(AABB()))                         # print AABB
	print(Type.as_type_name(Basis.IDENTITY))                 # print Basis
	print(Type.as_type_name(Transform3D.IDENTITY))           # print Transform3D
	print(Type.as_type_name(Projection.ZERO))                # print Projection
	print(Type.as_type_name(Color.BLACK))                    # print Color
	print(Type.as_type_name(RID()))                          # print RID
	print(Type.as_type_name(Object))                         # print Object
	print(Type.as_type_name([]))                             # print Array
	print(Type.as_type_name(Array()), " (constructor)")      # print Array (constructor)
	var typed_array_engine_class : Array[Vector2]
	print(Type.as_type_name(typed_array_engine_class))       # print Array[Vector2]
	var typed_array_custom_class : Array[TestTypeMatcher]
	print(Type.as_type_name(typed_array_custom_class))       # print Array[TestTypeMatcher]
	print(Type.as_type_name(PackedByteArray()))              # print PackedByteArray
	print(Type.as_type_name(PackedInt32Array()))             # print PackedInt32Array
	print(Type.as_type_name(PackedInt64Array()))             # print PackedInt64Array
	print(Type.as_type_name(PackedFloat32Array()))           # print PackedFloat32Array
	print(Type.as_type_name(PackedFloat64Array()))           # print PackedFloat64Array
	print(Type.as_type_name(PackedStringArray()))            # print PackedStringArray
	print(Type.as_type_name(PackedVector2Array()))           # print PackedVector2Array
	print(Type.as_type_name(PackedVector3Array()))           # print PackedVector3Array
	print(Type.as_type_name(PackedVector4Array()))           # print PackedVector4Array
	print(Type.as_type_name(PackedColorArray()))             # print PackedColorArray
	print(Type.as_type_name({}))                             # print Dictionary
	print(Type.as_type_name(Dictionary()), " (constructor)") # print Dictionary (constructor)
	
	# If the engine supports typed dictionary
	var engine_ver : Dictionary = Engine.get_version_info()
	if engine_ver.major >= 4 and engine_ver.minor >= 4:
		# To avoid godot from screaming if the engine version doesn't actually support it
		var typed_dict_print := GDScript.new()
		typed_dict_print.source_code = "
		static func print_typed_dict():
			var typed_dict_v1 : Dictionary[Variant, Node]
			print(Type.as_type_name(typed_dict_v1))
			var typed_dict_v2 : Dictionary[Node3D, Variant]
			print(Type.as_type_name(typed_dict_v2))
			var typed_dict_v3 : Dictionary[TestParent, Node]
			print(Type.as_type_name(typed_dict_v3))
			var typed_dict_v4 : Dictionary[Vector2i, TestParentCSharp]
			print(Type.as_type_name(typed_dict_v4))
			"
		typed_dict_print.reload()
		# print Dictionary[Variant, Node]
		# Dictionary[Node3D, Variant]
		# Dictionary[TestParent, Node]
		# Dictionary[Vector2i, TestParentCSharp]
		typed_dict_print.print_typed_dict()
	
	print(Type.as_type_name(Signal()))                       # print Signal
	print(Type.as_type_name(Callable()))                     # print Callable
