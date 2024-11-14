using Godot;
using Godot.Collections;
using System;

/// <summary>
/// Helper class to get class type (Also works for custom class and cross-scripting!). 
/// Can be used for pattern matching
/// <para/>
/// Your script must have class_name (Or <see cref="GlobalClassAttribute"/> if C#) for this to work as intended
/// </summary>
public static class GDScriptType
{
    private static readonly GDScript Internal_Script;
    private static readonly Dictionary<string, GodotObject> Internal_Engine_Scripts = new();
    private static readonly Dictionary<string, GDScript> Internal_GDScripts = new();

    /// <summary>
    /// This is technically not needed but in case you do need to compare <see cref="CSharpScript"/> when using <see cref="ExtendingFrom"/>
    /// <para/>
    /// Use <see cref="GetCSharpScript"/> to safely get the script
    /// </summary>
    private static readonly Dictionary<string, CSharpScript> Internal_CSharpScripts = new();

    static GDScriptType()
    {
        #region Get GDScript Class
        foreach (var globalClass in ProjectSettings.GetGlobalClassList())
        {
            var className = globalClass["class"].AsString();
            var language = globalClass["language"].AsString();
            switch (language)
            {
                case "GDScript":
                    try
                    {
                        Internal_GDScripts[className] = ResourceLoader.Load<GDScript>(globalClass["path"].AsString());

                        if (className == "Type" && globalClass["base"].AsString() == "RefCounted")
                            Internal_Script = Internal_GDScripts[className];

                    }
                    catch (Exception ex)
                    {
                        GD.PushError($"Unable to load GDScript {className}, reason: {ex.Message}");
                    }
                    break;
                case "C#":
                    try
                    {
                        Internal_CSharpScripts[className] = ResourceLoader.Load<CSharpScript>(globalClass["path"].AsString());
                    }
                    catch (Exception ex)
                    {
                        GD.PushError($"Unable to load C# Script {className}, reason: {ex.Message}");
                    }
                    break;
            }
        }
        #endregion

        if (Internal_Script is null)
        {
            GD.PushError("Unable to get Type.gd, did you modified the class?");
        }
        else
        {
            #region Get Engine Class
            var excluded = Internal_Script.Get("_excluded").AsGodotArray<StringName>();
            foreach (var engineClass in ClassDB.GetClassList())
            {
                if (!ClassDB.CanInstantiate(engineClass) && 
                    ClassDB.ClassGetMethodList(engineClass, true).Count == 0)
                    continue;

                if (excluded.Contains(engineClass))
                    continue;

                Internal_Engine_Scripts[engineClass] = GetNativeScript(engineClass);
            }
            #endregion

        }
    }

    /// <summary>
    /// Get all of the script <paramref name="obj"/> extending from.
    /// <para/>
    /// Usage demonstration:
    /// <code>
    /// Array&lt;GodotObject&gt; extendingScript = GDScript.ExtendingFrom(this);
    /// </code>
    /// </summary>
    /// <param name="obj"></param>
    /// <returns>An <see cref="Array{T}"/> wrapper of type <see cref="GodotObject"/></returns>
    public static Array<GodotObject> ExtendingFrom(GodotObject obj)
    {
        var readable_names = false;
        return Internal_Script.Call(MethodName.ExtendingFrom, obj, readable_names).AsGodotArray<GodotObject>();
    }

    /// <summary>
    /// Get all of the script <paramref name="obj"/> extending from.
    /// <para/>
    /// Usage demonstration:
    /// <code>
    /// Array&lt;StringName&gt; extendingScriptNames = GDScript.ExtendingNamesFrom(this);
    /// </code>
    /// </summary>
    /// <param name="obj"></param>
    /// <returns>An <see cref="Array{T}"/> wrapper of type <see cref="StringName"/></returns>
    public static Array<StringName> ExtendingNamesFrom(GodotObject obj)
    {
        var readable_names = true;
        return Internal_Script.Call(MethodName.ExtendingFrom, obj, readable_names).AsGodotArray<StringName>();
    }

    /// <summary>
    /// This is almost the same as <see cref="ClassDB.IsParentClass"/> except this also works for custom class and cross-scripting.
    /// <para/>
    /// Use this is if you don't have direct access to the class but has access to the class name
    /// <para/>
    /// Set <paramref name="check_cached_result"/> to false if the cached result is wrong somehow
    /// 
    /// Usage demonstration:
    /// <code>
    /// GD.Print(GDScriptType.InheritFrom("Area2D", "Node2D"));                    // prints true
    /// GD.Print(GDScriptType.InheritFrom("Area2D", "Node3D"));                    // prints false
    /// GD.Print(GDScriptType.InheritFrom("TestChildCSharp", "Node"));             // prints true
    /// GD.Print(GDScriptType.InheritFrom("TestTypeMatcher", "TestParent"));       // prints true
    /// GD.Print(GDScriptType.InheritFrom("TestParentCSharp", "TestTypeMatcher")); // prints false
    /// </code>
    /// </summary>
    /// <param name="child">The class name you want to check if it inherit <paramref name="parent"/></param>
    /// <param name="parent">The class name you want to check if it inherited by <paramref name="child"/></param>
    /// <param name="check_cached_result">Use a cached result if it already checked before</param>
    /// <returns>Whether <paramref name="child"/> inherit from <paramref name="parent"/> or not.</returns>
    public static bool InheritFrom(string child, string parent, bool check_cached_result = true)
    {
        return Internal_Script.Call(MethodName.InheritFrom, child, parent, check_cached_result).AsBool();
    }

    /// <summary>
    /// Only use this if you know what you're doing and can't use <see cref="GetNativeScript{T}"/> for whatever reason
    /// <para/>
    /// Usage demonstration:
    /// <code>
    /// var script = GDScriptType.GetNativeScript("Node");
    /// if (GDScriptType.ExtendingFrom(this).Contains(script))
    /// {
    ///     GD.Print("Success");
    /// }
    /// </code>
    /// </summary>
    /// <param name="name"></param>
    /// <returns></returns>
    public static GodotObject GetNativeScript(string name)
    {
        var check_cached_result = true;
        return Internal_Script.Call(MethodName.GetNativeClass, name, check_cached_result).AsGodotObject();
    }

    /// <summary>
    /// Use this to compare the result given by <see cref="ExtendingFrom"/>. 
    /// Note that this is only for getting the engine script (GDScriptNativeClass). 
    /// For getting your script <see cref="GDScript"/> use <see cref="GetGDScript"/>
    /// <para/>
    /// The reason they are separated is because GDScriptNativeClass doesn't actually extend from <see cref="GDScript"/>
    /// <para/>
    /// Usage demonstration:
    /// <code>
    /// var script = GDScriptType.GetNativeScript&lt;Node&gt;();
    /// if (GDScriptType.ExtendingFrom(this).Contains(script))
    /// {
    ///     GD.Print("Success");
    /// }
    /// </code>
    /// </summary>
    /// <typeparam name="T">The type you want to get script as</typeparam>
    /// <param name="check_exist">Check if it exist first before getting them,
    /// if you're 100% sure it exist. You can skip the check for faster lookup</param>
    /// <returns>GDScriptNativeClass as a <see cref="GodotObject"/> of the passed <typeparamref name="T"/></returns>
    /// <exception cref="ArgumentException"/>
    public static GodotObject GetNativeScript<T>(bool check_exist = true) where T : GodotObject
    {
        var name = typeof(T).Name;
        if (check_exist && !Internal_Engine_Scripts.ContainsKey(name))
        {
            throw new ArgumentException($"GetNativeClass is called with invalid or unsupported type ({name})");
        }
        return Internal_Engine_Scripts[name];
    }

    /// <summary>
    /// Use this to compare the result given by <see cref="ExtendingFrom"/>. 
    /// Note that this is only for getting the <see cref="GDScript"/>. 
    /// For getting engine script use <see cref="GetNativeScript{T}"/>
    /// <code>
    /// var script = GDScriptType.GetGDScript("TestParent");
    /// if (GDScriptType.ExtendingFrom(this).Contains(script))
    /// {
    ///     GD.Print("Success");
    /// }
    /// </code>
    /// </summary>
    /// <param name="name">The class_name of the script</param>
    /// <param name="check_exist">Check if it exist first before getting them,
    /// if you're 100% sure it exist. You can skip the check for faster lookup</param>
    /// <returns><see cref="GDScript"/> of the passed <paramref name="name"/></returns>
    /// <exception cref="ArgumentException"/>
    public static GDScript GetGDScript(string name, bool check_exist = true)
    {
        if (check_exist && !Internal_GDScripts.ContainsKey(name))
        {
            throw new ArgumentException($"GetGDScript is called with invalid or unsupported name ({name})");
        }
        return Internal_GDScripts[name];
    }

    /// <summary>
    /// Use this to compare the result given by <see cref="ExtendingFrom"/>. 
    /// Note that this is only for getting the <see cref="CSharpScript"/>. 
    /// For getting engine script use <see cref="GetNativeScript{T}"/> or <see cref="GetGDScript"/>
    /// <code>
    /// var script = GDScriptType.GetCSharpScript&lt;TestParentCSharp&gt;();
    /// if (GDScriptType.ExtendingFrom(this).Contains(script))
    /// {
    ///     GD.Print("Success");
    /// }
    /// </code>
    /// <para/>
    /// This check is not as strict as <see cref="GetNativeScript"/> due to how Godot handles <see cref="CSharpScript"/>. 
    /// It should still throw error if it doesn't found the script.
    /// </summary>
    /// <param name="name">The class_name of the script</param>
    /// <param name="check_exist">Check if it exist first before getting them,
    /// if you're 100% sure it exist. You can skip the check for faster lookup</param>
    /// <returns><see cref="CSharpScript"/> of the passed <paramref name="name"/></returns>
    /// <exception cref="ArgumentException"/>
    public static CSharpScript GetCSharpScript<T>(bool check_exist = true) where T : class
    {
        var name = typeof(T).Name;
        if (check_exist && !Internal_CSharpScripts.ContainsKey(name))
        {
            throw new ArgumentException($"GetCSharpScript is called with invalid or unsupported name ({name})");
        }
        return Internal_CSharpScripts[name];
    }

    /// <summary>
    /// Cached StringNames for the methods contained in this class, for fast lookup.
    /// </summary>
    public class MethodName
    {
        /// <summary>
        /// Cached name for the 'extending_from' method.
        /// </summary>
        public static readonly StringName ExtendingFrom = "extending_from";
        /// <summary>
        /// Cached name for the 'inherit_from' method.
        /// </summary>
        public static readonly StringName InheritFrom = "inherit_from";
        /// <summary>
        /// Cached name for the '_get_native_class' method.
        /// </summary>
        public static readonly StringName GetNativeClass = "_get_native_class";
    }
}
