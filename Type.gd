## Helper class to get class type (Also works for custom class and cross-scripting!). 
##
## Can be used for pattern matching
## [br][br]
## Your script must have class_name (Or [GlobalClass] if C#) for this to work as intended
class_name Type

static var _gdscript_native_class := GDScript.new()
static var _gdscript_type_to_string : Dictionary
static var _gdscript_string_to_type : Dictionary
static var _cached_inherit_result : Dictionary
static var _excluded : Array[StringName] = [&"GDScriptNativeClass"]

static func _static_init() -> void:
	for native_class in ClassDB.get_class_list():
		# Since ClassDB.get_class_list() returns PackedStringArray we convert it to StringName
		# This is for Type.as_type_name() to be consistently returns StringName
		var native_class_string_name = StringName(native_class)
		
		# Exclude class that are on the class list but can't actually be accessed from the script
		# And if they don't have any method at all
		if not ClassDB.can_instantiate(native_class_string_name) and ClassDB.class_get_method_list(native_class_string_name, true).size() == 0:
			continue
		
		# Exclude native class that cannot be instantiated but they do have a method
		# If there's new class in the future that cannot be accessed normally but have a method
		# Feel free to add them to the exclusion yourself
		if _excluded.has(native_class_string_name):
			continue
		
		var type = _get_native_class(native_class_string_name)
		_gdscript_string_to_type[native_class_string_name] = type
		_gdscript_type_to_string[type] = native_class_string_name

## Get the type name of the passed type
## [br][br]
## This is almost similar to 
## [url=https://learn.microsoft.com/en-us/dotnet/api/system.type.gettype](Microsoft Documentation) Type.Name C#[/url]
## and passing [method @GlobalScope.typeof] result into [method @GlobalScope.type_string]. 
## But in [method @GlobalScope.type_string] case if the passed obj is an instance then it will always return Object.
## It also doesn't know if [Array] or (If you're using v4.4 and above) [Dictionary] is typed or not
## [codeblock]
## print(type_string(typeof(Node2D))) # print Object
## print(Type.as_type_name(Node2D))   # print Node2D
##
## var typed_array : Array[Vector2]
## print(type_string(typeof(typed_array)))  # print Array
## print(Type.as_type_name(typed_array))    # print Array[Vector2]
##
## # Only on 4.4 and above which supports typed dictionary
## var typed_dictionary : Dictionary[Vector2, Node]
## print(type_string(typeof(typed_dictionary))) # print Dictionary
## print(Type.as_type_name(typed_dictionary))   # print Dictionary[Vector2, Node]
## [/codeblock]
## [b]Note:[/b] Since you can't use some built in type directly, e.g.
## [codeblock]
## Type.as_type_name(Array)
## [/codeblock]
## Instead you have to do it like
## [codeblock]
## Type.as_type_name([])
## # Or
## Type.as_type_name(Array())
## # Or
## var array : Array
## Type.as_type_name(array)
## [/codeblock]
## The order of the check:
## [br]
## -- Custom Script
## [br]
## -- Engine Script
## [br]
## -- An instance
## [br]
## ---- An instance with custom script
## [br]
## ---- An instance without custom script
## [br]
## -- Built-in types based off 
## [url=https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_basics.html#built-in-types]Built-in Types Documentation[/url]
## [br][br]
## 
## Example usage:
## [codeblock]
##class_name TestTypeMatcher extends TestParent
##
##func _ready() -> void:
##    print(Type.as_type_name(null))                           # print Nil
##    print(Type.as_type_name(Node))                           # print Node
##    print(Type.as_type_name(Node2D.new()))                   # print Node2D
##    print(Type.as_type_name(TestParent))                     # print TestParent
##    print(Type.as_type_name(TestTypeMatcher.new()))          # print TestTypeMatcher
##    print(Type.as_type_name(TestParentCSharp))               # print TestParentCSharp
##    print(Type.as_type_name(0))                              # print int
##    print(Type.as_type_name(0.0))                            # print float
##    print(Type.as_type_name([]))                             # print Array
##    print(Type.as_type_name(Array()), " (constructor)")      # print Array (constructor)
##    var typed_array_engine_class : Array[Vector2]
##    print(Type.as_type_name(typed_array_engine_class))       # print Array[Vector2]
##    var typed_array_custom_class : Array[TestTypeMatcher]
##    print(Type.as_type_name(typed_array_custom_class))       # print Array[TestTypeMatcher]
##    print(Type.as_type_name({}))                             # print Dictionary
##    print(Type.as_type_name(Dictionary()), " (constructor)") # print Dictionary (constructor)
##    
##    # Only on 4.4 and above which supports typed dictionary
##    var typed_dictionary : Dictionary[Vector2, Node]
##    print(Type.as_type_name(typed_dictionary))               # print Dictionary[Vector2, Node]
## [/codeblock]
## Example with built-in type:
## [codeblock]
##class_name TestTypeMatcher extends TestParent
##
##func _ready() -> void:
##    print(Type.as_type_name(null))                           # print Nil
##    print(Type.as_type_name(false))                          # print bool
##    print(Type.as_type_name(bool()), " (constructor)")       # print bool (constructor)
##    print(Type.as_type_name(0))                              # print int
##    print(Type.as_type_name(int()), " (constructor)")        # print int (constructor)
##    print(Type.as_type_name(0.0))                            # print float
##    print(Type.as_type_name(float()), " (constructor)")      # print float (constructor)
##    print(Type.as_type_name(""))                             # print String
##    print(Type.as_type_name(String()), " (constructor)")     # print String (constructor)
##    print(Type.as_type_name(&""))                            # print StringName
##    print(Type.as_type_name(StringName()), " (constructor)") # print StringName (constructor)
##    print(Type.as_type_name(^""))                            # print NodePath
##    print(Type.as_type_name(NodePath()), " (constructor)")   # print NodePath (constructor)
##    print(Type.as_type_name(Vector2.ZERO))                   # print Vector2
##    print(Type.as_type_name(Vector2i.ZERO))                  # print Vector2i
##    print(Type.as_type_name(Rect2()))                        # print Rect2
##    print(Type.as_type_name(Rect2i()))                       # print Rect2i
##    print(Type.as_type_name(Vector3.ZERO))                   # print Vector3
##    print(Type.as_type_name(Vector3i.ZERO))                  # print Vector3i
##    print(Type.as_type_name(Vector4.ZERO))                   # print Vector4
##    print(Type.as_type_name(Vector4i.ZERO))                  # print Vector4i
##    print(Type.as_type_name(Transform2D.IDENTITY))           # print Transform2D
##    print(Type.as_type_name(Plane()))                        # print Plane
##    print(Type.as_type_name(Quaternion.IDENTITY))            # print Quaternion
##    print(Type.as_type_name(AABB()))                         # print AABB
##    print(Type.as_type_name(Basis.IDENTITY))                 # print Basis
##    print(Type.as_type_name(Transform3D.IDENTITY))           # print Transform3D
##    print(Type.as_type_name(Projection.ZERO))                # print Projection
##    print(Type.as_type_name(Color.BLACK))                    # print Color
##    print(Type.as_type_name(RID()))                          # print RID
##    print(Type.as_type_name(Object))                         # print Object
##    print(Type.as_type_name([]))                             # print Array
##    print(Type.as_type_name(Array()), " (constructor)")      # print Array (constructor)
##    var typed_array_engine_class : Array[Vector2]
##    print(Type.as_type_name(typed_array_engine_class))       # print Array[Vector2]
##    var typed_array_custom_class : Array[TestTypeMatcher]
##    print(Type.as_type_name(typed_array_custom_class))       # print Array[TestTypeMatcher]
##    print(Type.as_type_name(PackedByteArray()))              # print PackedByteArray
##    print(Type.as_type_name(PackedInt32Array()))             # print PackedInt32Array
##    print(Type.as_type_name(PackedInt64Array()))             # print PackedInt64Array
##    print(Type.as_type_name(PackedFloat32Array()))           # print PackedFloat32Array
##    print(Type.as_type_name(PackedFloat64Array()))           # print PackedFloat64Array
##    print(Type.as_type_name(PackedStringArray()))            # print PackedStringArray
##    print(Type.as_type_name(PackedVector2Array()))           # print PackedVector2Array
##    print(Type.as_type_name(PackedVector3Array()))           # print PackedVector3Array
##    print(Type.as_type_name(PackedVector4Array()))           # print PackedVector4Array
##    print(Type.as_type_name(PackedColorArray()))             # print PackedColorArray
##    print(Type.as_type_name({}))                             # print Dictionary
##    print(Type.as_type_name(Dictionary()), " (constructor)") # print Dictionary (constructor)
##    print(Type.as_type_name(Signal()))                       # print Signal
##    print(Type.as_type_name(Callable()))                     # print Callable
## [/codeblock]
static func as_type_name(type) -> StringName:
	if typeof(type) == TYPE_OBJECT:
		# You can change the order of the check but you need to remember
		# A custom script is not the same as engine script
		# But both script extends from Object and an instance also extends from Object
		# If you don't know what this means then I don't recommend changing the order
		
		# Check if the passed parameter is a custom script
		# e.g. Type.as_type_name(TestTypeMatcher)
		if type is Script:
			return type.get_global_name()
		
		# Check if the passed parameter is an engine class
		# e.g. Type.as_type_name(Node)
		if _gdscript_type_to_string.has(type):
			return _gdscript_type_to_string[type]
		
		# Check if the passed parameter is an instance
		if type.has_method(&"get_script"):
			# Check if it's an instance that has custom script
			# e.g. Type.as_type_name(TestTypeMatcher.new())
			if type.get_script() is Script:
				return type.get_script().get_global_name()
	
			# Check if it's an instance of engine class but doesn't have custom script
			# e.g. Type.as_type_name(Node.new())
			elif _gdscript_string_to_type.has(type.get_class()):
				return _gdscript_type_to_string[_gdscript_string_to_type[type.get_class()]]
	
	return _get_built_in_type_name(type)

# dont_convert is set to true when called by typed containers
static func _get_built_in_type_name(type, dont_convert: bool = false) -> StringName:
	match typeof(type):
		TYPE_ARRAY:
			if type.is_typed():
				# Check if the key is a custom script
				# e.g. Array[TestParent]
				if type.get_typed_script() != null:
					return &"Array[%s]" % type.get_typed_script().get_global_name()
				# Check if the key is a built-in type
				# e.g. Array[Vector2]
				elif type.get_typed_builtin() != TYPE_OBJECT:
					return &"Array[%s]" % _get_built_in_type_name(type.get_typed_builtin(), true)
				else:
					# If it's typed, and all check doesn't pass. then we can safely use the class name of engine class
					# e.g. Array[Node]
					return &"Array[%s]" % type.get_typed_class_name()
			return &"Array"
		TYPE_DICTIONARY:
			var engine_ver : Dictionary = Engine.get_version_info()
			# Check if the engine the user use is on version that support typed dictionary
			if engine_ver.major >= 4 and engine_ver.minor >= 4:
				if type.is_typed():
					var typed_dictionary := &"Dictionary[{key}, {value}]"
					if not type.is_typed_key():
						typed_dictionary = typed_dictionary.format({&"key": &"Variant"})
					# Check if the key is a custom script
					# e.g. Dictionary[TestParent, Variant]
					elif type.get_typed_key_script() != null:
						typed_dictionary = typed_dictionary.format({&"key": type.get_typed_key_script().get_global_name()})
					# Check if the key is a built-in type
					# e.g. Dictionary[Vector2, Variant]
					elif type.get_typed_key_builtin() != TYPE_OBJECT:
						typed_dictionary = typed_dictionary.format({&"key": _get_built_in_type_name(type.get_typed_key_builtin(), true)})
					else:
						# If it's typed, and all check doesn't pass. then we can safely use the class name of engine class
						# e.g. Dictionary[Node, Variant]
						typed_dictionary = typed_dictionary.format({&"key": type.get_typed_key_class_name()})
					
					# Same check as before but on value this time
					if not type.is_typed_value():
						typed_dictionary = typed_dictionary.format({&"value": &"Variant"})
					elif type.get_typed_value_script() != null:
						typed_dictionary = typed_dictionary.format({&"value": type.get_typed_value_script().get_global_name()})
					elif type.get_typed_value_builtin() != TYPE_OBJECT:
						typed_dictionary = typed_dictionary.format({&"value": _get_built_in_type_name(type.get_typed_value_builtin(), true)})
					else:
						typed_dictionary = typed_dictionary.format({&"value": type.get_typed_value_class_name()})
					
					return typed_dictionary
			return &"Dictionary"
		_:
			# Use the regular type_string conversion
			# If the passed parameter told to don't convert then don't use typeof
			# It should be set to true when called by typed containers
			# Since the passed type is already an enum value from Variant.Type
			return StringName(type_string(type if dont_convert else typeof(type)))

## The passed object must be of type [enum Variant.Type] TYPE_OBJECT.
## The parameter actual type is not specified because GDScriptNativeClass is not accessible from normal code
## [br][br]
## Returns an array of all of the script this object extending from. 
## If [param readable_names] is true, returns all of the type in [StringName]
## [br][br]
## Example with simple [Node2D]:
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
### TestParent inherit Node2D
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
## Example with checking if type is in array:
## [codeblock]
##class_name TestTypeMatcher extends Node2D
##
##func _ready() -> void:
##    if Node2D in Type.extending_from(self):
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
### TestParent inherit Node2D
##class_name TestTypeMatcher extends TestParent
## 
##func _ready() -> void:
##    match Type.extending_from(TestTypeMatcher):
##        [TestParent]:
##            # Will not print this because the size doesn't match
##            print("I inherited TestParent (fixed size)")
##        [Node2D, ..]:
##            # Will not print this because Node2D is not the first item on the array
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
##            # Will not print this because the first is already a match
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
			var to_add = current_script if not readable_names else current_script.get_global_name()
			result.append(to_add)
	
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
##    print(Type.inherit_from("Area2D", "Node2D"))                    # prints true
##    print(Type.inherit_from("Area2D", "Node3D"))                    # prints false
##    print(Type.inherit_from("TestTypeMatcher", "Node"))             # prints true
##    print(Type.inherit_from("TestChildCSharp", "TestParentCSharp")) # prints true
##    print(Type.inherit_from("TestTypeMatcher", "TestParentCSharp")) # prints false
## [/codeblock]
static func inherit_from(child : String, parent : String, check_cached_result : bool = true) -> bool:
	var is_child_native := ClassDB.class_exists(child)
	var is_parent_native := ClassDB.class_exists(parent)
	
	if is_child_native and is_parent_native:
		return ClassDB.is_parent_class(child, parent)
	else:
		# Check for cached result so we don't have to do the same process all over again
		if check_cached_result and _cached_inherit_result.has(child) and _cached_inherit_result[child] == parent:
			return true
		
		# Get all of the global class on this project
		# If your class is not available here then check if it has assigned class_name (or [GlobalClass] if C#)
		var all_custom_class := ProjectSettings.get_global_class_list()
		var current_class : Dictionary
		var is_target_native : bool
		
		# Doesn't explicitly specify the target_class type because it can be Dictionary or Script or GDScriptNativeClass
		var target_class
		
		# We don't add it to cache in case the user check for type that exist but can't be instantiated
		if _gdscript_string_to_type.has(parent) and _is_native_class(_gdscript_string_to_type[parent]):
			target_class = _gdscript_string_to_type[parent]
			is_target_native = true
		
		for custom_class in all_custom_class:
			# If both child and parent class is found, then stop iterating
			if current_class.size() > 0 and not is_target_native and target_class is Dictionary:
				break
			elif current_class.size() > 0 and is_target_native:
				break
			
			if custom_class.class == child:
				current_class = custom_class
			elif target_class == null and custom_class.class == parent:
				target_class = custom_class
		
		if not is_child_native and current_class.size() == 0:
			push_warning("Type.inherit_from cannot find engine class named %s (Child)" % child)
		
		# Check if the child class is valid and can be loaded
		if current_class.size() > 0 and not current_class.class.is_empty() and ResourceLoader.exists(current_class.path):
			var current_script = ResourceLoader.load(current_class.path)
			
			# Check if the target class is not native and is valid
			if not is_target_native and target_class is Dictionary:
				
				# Load the target class to be compared
				var target_script = ResourceLoader.load(target_class.path)
				
				while current_script != null:
					if current_script == target_script:
						_cached_inherit_result[child] = parent
						return true
					current_script = current_script.get_base_script()
				
				# If it doesn't found the script and is not an engine class, then check if it exist on the global class list
				if all_custom_class.all(func(custom_class): return custom_class.class != parent):
					# Warn the user if they passed a parent name that's not found anywhere
					push_warning("Type.inherit_from cannot find class named %s (Parent)" % parent)
			
			elif is_parent_native:
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
			else:
				# In case every check passed except this last check, warns the user the that the passed parameter is invalid
				push_warning("Type.inherit_from cannot find class named %s (Parent)" % parent)
			
		elif is_child_native and not is_parent_native:
			push_warning("Type.inherit_from is called with engine class on child parameter (%s), but not on the parent parameter (%s)" % [child, parent])
	
	return false

static func _is_native_class(type) -> bool:
	return _gdscript_type_to_string.has(type)

static func _get_native_class(name : String, check_exist: bool = false) -> Object:
	# This is for C# cross scripting to check if it exist and if it has been cached or not
	if check_exist:
		if not ClassDB.class_exists(name):
			return null
		elif _gdscript_string_to_type.has(name):
			return _gdscript_string_to_type[name]
	
	# Set the script code to return the current class
	# This is a hack to get GDScriptNativeClass which isn't normally obtainable
	_gdscript_native_class.set_source_code("static func get_gdscript_native_class(): return %s" % name)
	_gdscript_native_class.reload()
	
	var type = _gdscript_native_class.get_gdscript_native_class()
	
	if check_exist:
		# This is for C# cross scripting in case it gets a type that has not been cached
		_gdscript_string_to_type[name] = type
		_gdscript_type_to_string[type] = name
	
	return type
