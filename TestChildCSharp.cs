using Godot;

[GlobalClass]
public partial class TestChildCSharp : TestParentCSharp
{
    public override void _Ready()
    {
        if (GDScriptType.InheritFrom("TestTypeMatcher", "TestParent"))
            GD.Print("TestTypeMatcher inherit TestParent (C# check)");
    }
}
