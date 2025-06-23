using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

//MADE BY PETER CHRISTENSEN
#if UNITY_EDITOR
[CustomPropertyDrawer(typeof(ButtonAttribute))]
public class ButtonPropertyDrawer : PropertyDrawer
{
    public override void OnGUI(Rect position, SerializedProperty property, GUIContent label)
    {
        ButtonAttribute attri = attribute as ButtonAttribute;
        string methodName = attri.methodName;
        string buttonName = methodName;
        int buttonWidth = attri.buttonWidth;
        if (attri.buttonName != "")
            buttonName = attri.buttonName;

        Object target = property.serializedObject.targetObject;
        System.Type type = target.GetType();
        System.Reflection.MethodInfo method = type.GetMethod(methodName);
        if (method == null)
        {
            GUI.Label(position, "Method could not be found. Is it public?");
            return;
        }
        if (method.GetParameters().Length > 0)
        {
            GUI.Label(position, "Method cannot have parameters.");
            return;
        }
        if (GUI.Button(new Rect(position.x + (position.width/2 - buttonWidth/2), position.y, buttonWidth, position.height), buttonName))
        {
            method.Invoke(target, null);
        }

    }
}
#endif
/// <summary>
/// Attribute for quickly making a button to call a method.<br/>
/// Proper usage: <br/>
/// - Make a "dummy" field. The type doesn't matter but bool is recommended. <br/>
/// - Make sure it is serialized. <br/>
/// - Add this attribute to it.
/// </summary>
public class ButtonAttribute : PropertyAttribute
{
    public readonly string methodName;
    public readonly string buttonName;
    public readonly int buttonWidth;

    /// <summary>
    /// The constructor for the attribute.
    /// </summary>
    /// <param name="methodName">The name of the method to call. Use nameof to get this.</param>
    /// <param name="buttonName">Optional override of the text written on the button.</param>
    /// <param name="buttonWidth">The width of the button. Default is 200.</param>
    public ButtonAttribute(string methodName, string buttonName = "", int buttonWidth = 200)
    {
        this.methodName = methodName;
        this.buttonName = "";
        this.buttonWidth = buttonWidth;
    }
}
