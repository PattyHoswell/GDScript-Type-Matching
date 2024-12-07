using Godot;
using Godot.Collections;

[GlobalClass]
public partial class TestChildCSharp : TestParentCSharp
{
    public override void _Ready()
    {
        CheckGDScriptClass();
    }

    void CheckSimple()
    {
        foreach (var script in GDScriptType.ExtendingFrom(GetParent()))
        {
            if (script == GDScriptType.GetNativeScript<Area2D>() ||
                script == GDScriptType.GetNativeScript<StaticBody2D>() ||
                script == GDScriptType.GetNativeScript<CharacterBody2D>())

                GD.Print("I inherited Area2D, StaticBody2D, or CharacterBody2D (C# Check)");

            else if (script == GDScriptType.GetNativeScript<Node2D>())
                // Will print this
                GD.Print("I inherited Node2D (C# Check)");
        }
    }

    void CheckGDScriptClass(bool fromResource = true)
    {
        if (GDScriptType.InheritFrom("TestTypeMatcher", "TestParent"))
            GD.Print("TestTypeMatcher inherited TestParent (C# Check)");

        if (fromResource)
            GD.Print(GDScriptType.ExtendingNamesFrom(ResourceLoader.Load("res://TestTypeMatcher.gd")), " (C# Check)");

        else
            GD.Print(GDScriptType.ExtendingNamesFrom(GetParent()), " (C# Check)");
    }

    void CheckFromInheritanceCustomClass()
    {
        foreach (var script in GDScriptType.ExtendingFrom(this))
        {
            if (script == GDScriptType.GetCSharpScript<TestParentCSharp>())
                // Will print this
                GD.Print("I inherited TestParentCSharp (C# Check)");

            else if (script == GDScriptType.GetNativeScript<Node2D>())
                // Will print this
                GD.Print("I inherited Node2D (C# Check)");
        }
    }

    void ArrayIfCheck()
    {
        if (GDScriptType.ExtendingFrom(this).Contains(GDScriptType.GetNativeScript<Node2D>()))
            GD.Print("TestChildCSharp inherited Node2D (C# Check)");
    }
    void ArrayIfCheckName()
    {
        if (GDScriptType.ExtendingNamesFrom(this).Contains("Node2D"))
            GD.Print("TestChildCSharp inherited Node2D (C# Check)");
    }

    void CheckInheritance()
    {
        GD.Print(GDScriptType.InheritFrom("Area2D", "Node2D"), " (C# Check)");                    // prints true
        GD.Print(GDScriptType.InheritFrom("Area2D", "Node3D"), " (C# Check)");                    // prints false
        GD.Print(GDScriptType.InheritFrom("TestChildCSharp", "Node"), " (C# Check)");             // prints true
        GD.Print(GDScriptType.InheritFrom("TestTypeMatcher", "TestParent"), " (C# Check)");       // prints true
        GD.Print(GDScriptType.InheritFrom("TestParentCSharp", "TestTypeMatcher"), " (C# Check)"); // prints false
    }

    void CheckTypeName()
    {
        /* 
         * Most of the test showcased in GDScript side can be done simply by using nameof or typeof
         * So I'll only show the most obvious differences
         */

        GodotObject obj = null;
        GD.Print(GDScriptType.AsTypeName(obj));                 // prints Nil
        GD.Print(GDScriptType.AsTypeName(GetParent()));         // prints TestTypeMatcher
        GD.Print(GDScriptType.AsTypeName(new string[0]));       // prints PackedStringArray
        GD.Print(GDScriptType.AsTypeName(new Array<string>())); /* prints Array
                                                                 * There's a weird conversion happening on godot here but basically
                                                                 * Use the regular c# version when possible that can be automatically converted into the appropriate type
                                                                 */
    }
}
