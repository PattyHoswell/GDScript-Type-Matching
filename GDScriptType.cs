using Godot;
using Godot.Collections;

public static class GDScriptType
{
    private static GDScript Internal_Script;

    static GDScriptType()
    {
        Internal_Script = GD.Load<GDScript>("res://Type.gd");
        if (Internal_Script is null)
        {
            GD.PushError("Unable to get Type.gd, please make sure the path is correct");
        }
    }

    public static Array ExtendingFrom(GodotObject obj, bool readable_names = false)
    {
        return Internal_Script.Call("extending_from", obj, readable_names).AsGodotArray();
    }

    public static bool InheritFrom(string child, string parent, bool check_cached_result = true)
    {
        return Internal_Script.Call("inherit_from", child, parent, check_cached_result).AsBool();
    }
}
