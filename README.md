# GDScript Type Matching
 A Script to get class type (Also works for custom class and cross-scripting). Can be used for pattern matching. 
Your script must have `class_name` (Or `[GlobalClass]` if C#) for this to work as intended

### **You really only need the `Type.gd`, the other files are only for demonstration.**

## Usage demonstration `as_type_name`:
#### `as_type_name(type:Variant) -> StringName`
Get the type name of the passed type

This is almost similar to [(Microsoft Documentation) Type.Name C#](https://learn.microsoft.com/en-us/dotnet/api/system.type.gettype) and passing `typeof` result into `type_string`. But in `type_string` case if the passed obj is an instance then it will always return `Object`. It also doesn't know if `Array` or (If you're using v4.4 and above) `Dictionary` is typed or not

Example usage:
```gdscript
class_name TestTypeMatcher extends TestParent

func _ready() -> void:
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

	# Only on 4.4 and above which supports typed dictionary
	var typed_dictionary : Dictionary[Vector2, Node]
	print(Type.as_type_name(typed_dictionary))               # print Dictionary[Vector2, Node]
```

## Usage demonstration `extending_from`:
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
Example with checking if type is in array:
```gdscript
class_name TestTypeMatcher extends Node2D

func _ready() -> void:
	if Node2D in Type.extending_from(self):
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

## Usage demonstration `inherit_from`:
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

# C#
All of the method shown here are on a static class named `GDScriptType`
## Usage demonstration `AsTypeName`:
#### `string AsTypeName(Variant obj)`
Get the type name of the passed `obj`

This is intended for getting a type name of GDScript obj that you can't normally access from C# which are based off from [Built-in Types Documentation](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_basics.html#built-in-types)
```c#
switch (GDScriptType.AsTypeName(this))
{
    case "TestTypeMatcher":
        // do something
        break;
    case "TestParent":
        // do something
        break;
    case "PackedStringArray":
        // do something
        break;
}
```
## Usage demonstration `ExtendingFrom`:
#### `Array<GodotObject> ExtendingFrom(GodotObject obj)`
Get all of the script `obj` extending from. return an `Array` wrapper of type `GodotObject`
```c#
Array<GodotObject> extendingScript = GDScriptType.ExtendingFrom(this);
```

## Usage demonstration `ExtendingNamesFrom`:
#### `Array<StringName> ExtendingNamesFrom(GodotObject obj)`
Get all of the script `obj` extending from. return an `Array` wrapper of type `StringName`
```c#
Array<StringName> extendingScript = GDScriptType.ExtendingNamesFrom(this);
```

## Usage demonstration `InheritFrom`:
#### `bool InheritFrom(string child, string parent, bool check_cached_result = true)`
This is almost the same as `ClassDB.IsParentClass` except this also works for custom class and cross-scripting.

Use this is if you don't have direct access to the class but has access to the class name

Set `check_cached_result` to false if the cached result is wrong somehow
```c#
GD.Print(GDScriptType.InheritFrom("Area2D", "Node2D"));                    // prints true
GD.Print(GDScriptType.InheritFrom("Area2D", "Node3D"));                    // prints false
GD.Print(GDScriptType.InheritFrom("TestChildCSharp", "Node"));             // prints true
GD.Print(GDScriptType.InheritFrom("TestTypeMatcher", "TestParent"));       // prints true
GD.Print(GDScriptType.InheritFrom("TestParentCSharp", "TestTypeMatcher")); // prints false
```

## Usage demonstration `GetNativeScript<T>`:
#### `GodotObject GetNativeScript<T>(bool check_exist = true) where T : GodotObject`
Use this to compare the result given by `ExtendingFrom`. Note that this is only for getting the engine script `GDScriptNativeClass`
For getting your script `GDScript` use `GetGDScript`

The reason they are separated is because `GDScriptNativeClass` doesn't actually extend from `GDScript`
```c#
var script = GDScriptType.GetNativeScript<Node>();
if (GDScriptType.ExtendingFrom(this).Contains(script))
{
	GD.Print("Success");
}
```

## Usage demonstration `GetGDScript`:
#### `GDScript GetGDScript(string name, bool check_exist = true)`
Use this to compare the result given by `ExtendingFrom`. Note that this is only for getting `GDScript`
For getting engine script use `GetNativeScript<T>`
```c#
var script = GDScriptType.GetGDScript("TestParent");
if (GDScriptType.ExtendingFrom(this).Contains(script))
{
	GD.Print("Success");
}
```

## Usage demonstration `GetCSharpScript<T>`:
#### `CSharpScript GetCSharpScript<T>(bool check_exist = true) where T : class`
Use this to compare the result given by `ExtendingFrom`. Note that this is only for getting `CSharpScript`
For getting engine script use `GetNativeScript<T>` or `GetGDScript`
```c#
var script = GDScriptType.GetCSharpScript<TestParentCSharp>();
if (GDScriptType.ExtendingFrom(this).Contains(script))
{
	GD.Print("Success");
}
```
