# GDScript Type Matching
 A Script to get class type (Also works for custom class and cross-scripting). Can be used for pattern matching. 
Your script must have `class_name` (Or `[GlobalClass]` if C#) for this to work as intended

### **You really only need the `Type.gd`, the other files are only for demonstration.**

## Usage demonstration:
#### `extending_from(obj:Variant, readable_names:bool=false) -> Array`
The passed object must be of type `Variant.Type.TYPE_OBJECT`. The parameter actual type is not specified because `GDScriptNativeClass` is not accessible from normal code 

Returns an `Array` of all of the script this object extending from. If `readable_names` is true, returns all of the type in `StringName`

Example with simple `Node2D`:
```gdscript
class_name TestTypeMatcher extends Node2D

func _ready() -> void:
	for type in Type.extending_from(self):
		match type:
			# You can use comma to check multiple types
			Area2D, StaticBody2D, CharacterBody2D:
				print("I inherited Area2D, StaticBody2D, or CharacterBody2D")
			Node2D:
				# Will print this
				print("I inherited Node2D")
```
Example with custom class that inherit custom class:
```gdscript
# TestParent inherit Node2D
class_name TestTypeMatcher extends TestParent

func _ready() -> void:
	for type in Type.extending_from(self):
		match type:
			TestParent:
			 	# Will print this
			 	print("I inherited TestParent")
			Node2D:
			 	# Will print this
			 	print("I inherited Node2D")
```
Example that use the class directly:
```gdscript
class_name TestTypeMatcher extends Node2D

func _ready() -> void:
	Type.extending_from(TestTypeMatcher)
	# Also works for engine class
	Type.extending_from(Node2D)
```
Example that check on the array directly:
```gdscript
class_name TestTypeMatcher extends Node2D

func _ready() -> void:
	if Type.extending_from(TestTypeMatcher).has(Node2D):
		# Will print this
		print("TestTypeMatcher inherited Node2D")
```
Example that gets a readable class name:
```gdscript
class_name TestTypeMatcher extends Node2D

func _ready() -> void:
	if Type.extending_from(TestTypeMatcher, true).has("Node2D"):
		print("TestTypeMatcher inherited Node2D")
```
Example that pattern match on the array directly. 

**Note:** This is more strict and you have less control over what you can match on the array:
```gdscript
class_name TestTypeMatcher extends TestParent

func _ready() -> void:
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
```
Example that uses the array variable 

**Note:** You have more control over pattern matching the array this way but the code won't look as pretty:
```gdscript
class_name TestTypeMatcher extends Node2D

func _ready() -> void:
	match Type.extending_from(TestTypeMatcher):
		var arr when arr.has(Node):
			# Will print this because the type inherit Node
			print("I inherited Node (binding pattern)")

	# You can also put it on a variable before matching it
	var extending_types : Array = Type.extending_from(TestTypeMatcher)
	match extending_types:
		# You can combine both match and if else check
		[Node2D, ..] when extending_types.has(Node):
			# Will print this because the type inherit Node2D and Node
			print("I inherited Node2D and Node")
		# Underscore means default
		# This is indistinguishable to an if check
		_ when extending_types.has(Node):
			# Will not print this because the first is already a match
			print("I inherited Node")
```
## Usage demonstration:
#### `inherit_from(child:String, parent:String, check_cached_result:bool=true) -> bool`
Returns whether child inherit from parent or not. This is almost the same as `ClassDB.is_parent_class()` except this also works for custom class and cross-scripting 

Use this is you don't have direct access to the class but has access to the class name 

Set `check_cached_result` to false if the cached result is wrong somehow

```gdscript
class_name TestTypeMatcher extends Node2D

func _ready() -> void:
	print(Type.inherit_from("Area2D", "Node2D"))                    # returns true
	print(Type.inherit_from("Area2D", "Node3D"))                    # returns false
	print(Type.inherit_from("TestTypeMatcher", "Node"))             # returns true
	print(Type.inherit_from("TestChildCSharp", "TestParentCSharp")) # returns true
	print(Type.inherit_from("TestTypeMatcher", "TestParentCSharp")) # returns false
```
