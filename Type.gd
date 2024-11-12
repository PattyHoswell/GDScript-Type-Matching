## Helper class to get class type (Also works for custom class and cross-scripting!). 
## Can be used for pattern matching
## [br][br]
## Your script must have class_name (Or [GlobalClass] if C#) for this to work as intended
class_name Type

static var _gdscript_native_class := GDScript.new()
static var _gdscript_type_to_string : Dictionary
static var _gdscript_string_to_type : Dictionary
static var _cached_inherit_result : Dictionary
static var _excluded : Array = ["GDScriptNativeClass"]

static func _static_init() -> void:
	for native_class in ClassDB.get_class_list():
		
		# Exclude class that are on the class list but can't actually be accessed from the script
		# And if they don't have any method at all
		if not ClassDB.can_instantiate(native_class) and ClassDB.class_get_method_list(native_class, true).size() == 0:
			continue
		
		# Native class cannot be instantiated but they do have a method
		# If there's new class in the future that cannot be accessed normally but have a method
		# Feel free to add them to the exclusion yourself
		if _excluded.has(native_class):
			continue
		
		var type = _get_native_class(native_class)
		_gdscript_string_to_type[native_class] = type
		_gdscript_type_to_string[type] = native_class
		

## The passed object must be of type [enum Variant.Type] TYPE_OBJECT.
## The parameter actual type is not specified because GDScriptNativeClass is not accessible from normal code
## [br][br]
## Returns all of the script this object extending from. 
## If [param readable_names] is true, returns all of the type in [String]
## [br][br]
## Example with simple Node2D:
## [codeblock]
##class_name TestTypeMatcher extends Node2D
##
##func _ready() -> void:
##    for type in Type.extending_from(self):
##        match type:
##            # You can use comma to check multiple types
##            Area2D, StaticBody2D, CharacterBody2D:
##                print("I inherited Area2D, StaticBody2D, or CharacterBody2D")
##            Node2D:
##                # Will print this
##                print("I inherited Node2D")
## [/codeblock]
## Example with custom class that inherit custom class:
## [codeblock]
## # TestParent inherit Node2D
##class_name TestTypeMatcher extends TestParent
##
##func _ready() -> void:
##    for type in Type.extending_from(self):
##        match type:
##            TestParent:
##                # Will print this
##                print("I inherited TestParent")
##            Node2D:
##                # Will print this
##                print("I inherited Node2D")
## [/codeblock]
## Example that use the class directly:
## [codeblock]
##class_name TestTypeMatcher extends Node2D
##
##func _ready() -> void:
##    Type.extending_from(TestTypeMatcher)
##    # Also works for engine class
##    Type.extending_from(Node2D)
## [/codeblock]
## Example that check on the array directly:
## [codeblock]
##class_name TestTypeMatcher extends Node2D
## 
##func _ready() -> void:
##    if Type.extending_from(TestTypeMatcher).has(Node2D):
##        # Will print this
##        print("TestTypeMatcher inherited Node2D")
## [/codeblock]
## Example that gets a readable class name:
## [codeblock]
##class_name TestTypeMatcher extends Node2D
##
##func _ready() -> void:
##    if Type.extending_from(TestTypeMatcher, true).has("Node2D"):
##        print("TestTypeMatcher inherited Node2D")
## [/codeblock]
## Example that pattern match on the array directly.
## [br][br]
## [color=yellow][b]Note:[/b][/color] This is more strict and you have less control over what you can match on the array:
## [codeblock]
##class_name TestTypeMatcher extends TestParent
## 
##func _ready() -> void:
##    match Type.extending_from(TestTypeMatcher):
##        [TestParent]:
##            # Will not print this because the size doesn't match
##            print("I inherited TestParent (fixed size)")
##        [Node2D, ..]:
##            # Will not print this because the size doesn't match
##            # And because Node2D is not the first item on the array
##            print("I inherited Node2D")
##        [TestParent, ..]:
##            # Will print this because of the ..
##            # It specify that size may be bigger than the array we're trying to match
##            # And TestParent is the first item on the array
##            print("I inherited TestParent")
## [/codeblock]
## Example that uses the array variable
## [br][br]
## [color=yellow][b]Note:[/b][/color] You have more control over pattern matching the array this way but the code won't look as pretty:
## [codeblock]
##class_name TestTypeMatcher extends Node2D
## 
##func _ready() -> void:
##    match Type.extending_from(TestTypeMatcher):
##        var arr when arr.has(Node):
##            # Will print this because the type inherit Node
##            print("I inherited Node (binding pattern)")
##
##    # You can also put it on a variable before matching it
##    var extending_types : Array = Type.extending_from(TestTypeMatcher)
##    match extending_types:
##        # You can combine both match and if else check
##        [Node2D, ..] when extending_types.has(Node):
##            # Will print this because the type inherit Node2D and Node
##            print("I inherited Node2D and Node")
##        # Underscore means default
##        # This is indistinguishable to an if check
##        _ when extending_types.has(Node):
##            print("I inherited Node")
## [/codeblock]
static func extending_from(obj, readable_names: bool = false) -> Array:
	var result : Array = []
	if typeof(obj) != TYPE_OBJECT:
		push_error("Type.extending_from is called with invalid or unsupported parameter [ %s ], please make sure the passed type is an object" % str(obj))
		return result
	
	var is_native = _is_native_class(obj)
	
	# Check for user specified class
	var current_script
	if not is_native and obj is not Script:
		current_script = obj.get_script()
	else:
		current_script = obj
	
	# Iterate through all user specified class
	while current_script != null and not is_native:
		current_script = current_script.get_base_script()
		# Check if the next class is not null, if its not then add to the result
		if current_script != null:
			if readable_names:
				result.append(current_script.get_global_name())
			else:
				result.append(current_script)
	
	# Get the base engine class
	var current_class
	if not is_native:
		# Using get class on a script will return GDScript type so this is necessary
		# If object is a script, then get the base type
		# Else if object is not a script, then get the class
		current_class = obj.get_instance_base_type() if obj is Script else obj.get_class()
	else:
		current_class = _gdscript_type_to_string.get(obj)
	
	# Iterate through all engine class
	while not current_class.is_empty():
		
		# If the current class doesn't exist in cache then try to get them again
		if not _gdscript_string_to_type.has(current_class):
			_gdscript_string_to_type[current_class] = _get_native_class(current_class)
		
		var to_add = _gdscript_string_to_type[current_class] if not readable_names else current_class
		result.append(to_add)
		# Get the class this class extend from
		current_class = ClassDB.get_parent_class(current_class)
	
	return result

## Returns whether [param child] inherit from [param parent] or not. 
## This is almost the same as [method ClassDB.is_parent_class] except this also works for custom class and cross-scripting
## [br][br]
## Use this is you don't have direct access to the class but has access to the class name 
## [br][br]
## Set [param check_cached_result] to false if the cached result is wrong somehow
## [br][br]
## Example usage:
## [codeblock]
##class_name TestTypeMatcher extends Node2D
##
##func _ready() -> void:
##    print(Type.inherit_from("Area2D", "Node2D"))                    # returns true
##    print(Type.inherit_from("Area2D", "Node3D"))                    # returns false
##    print(Type.inherit_from("TestTypeMatcher", "Node"))             # returns true
##    print(Type.inherit_from("TestChildCSharp", "TestParentCSharp")) # returns true
##    print(Type.inherit_from("TestTypeMatcher", "TestParentCSharp")) # returns false
## [/codeblock]
static func inherit_from(child : String, parent: String, check_cached_result : bool = false) -> bool:
	if ClassDB.class_exists(child) and ClassDB.class_exists(parent):
		return ClassDB.is_parent_class(child, parent)
	else:
		# Check for cached result so we don't have to do the same process all over again
		if check_cached_result and _cached_inherit_result.has(child) and _cached_inherit_result[child] == parent:
			return true
			
		var all_custom_class := ProjectSettings.get_global_class_list()
		var current_class : Dictionary
		var target_class
		if _gdscript_string_to_type.has(parent) and _is_native_class(_gdscript_string_to_type[parent]):
			target_class = _gdscript_string_to_type[parent]
		
		for custom_class in all_custom_class:
			# If both child and parent class is found, then stop iterating
			if current_class.size() > 0 and target_class is Dictionary and target_class.size() > 0:
				break
			elif current_class.size() > 0 and target_class is not Dictionary and _gdscript_type_to_string.has(target_class):
				break
			
			if custom_class.class == child:
				current_class = custom_class
			elif target_class == null and custom_class.class == parent:
				target_class = custom_class
		
		# Check if the child class is valid and can be loaded
		if current_class.size() > 0 and not current_class.class.is_empty() and ResourceLoader.exists(current_class.path):
			var current_script = ResourceLoader.load(current_class.path)
			
			# Check if the target class is not native and is valid
			if not _is_native_class(parent) and target_class != null and target_class is Dictionary:
				
				# Load the target class to be compared
				var target_script = ResourceLoader.load(target_class.path)
				
				while current_script != null:
					if current_script == target_script:
						_cached_inherit_result[child] = parent
						return true
					current_script = current_script.get_base_script()
			
			elif ClassDB.class_exists(parent):
				var current_checking_class = current_script.get_instance_base_type()
				while not current_checking_class.is_empty():
					if current_checking_class == parent:
						_cached_inherit_result[child] = parent
						return true
					# If the current class doesn't exist in cache then try to get them again
					if not _gdscript_string_to_type.has(current_checking_class):
						_gdscript_string_to_type[current_checking_class] = _get_native_class(current_checking_class)
					# Get the class this class derive from
					current_checking_class = ClassDB.get_parent_class(current_checking_class)
	
	return false

static func _is_native_class(type) -> bool:
	return _gdscript_type_to_string.has(type)

static func _get_native_class(name : String):
	# Set the script code to return the current class
	# This is a hack to get GDScriptNativeClass which isn't normally obtainable
	_gdscript_native_class.set_source_code("static func get_gdscript_native_class(): return %s" % name)
	_gdscript_native_class.reload()
	
	return _gdscript_native_class.get_gdscript_native_class()
