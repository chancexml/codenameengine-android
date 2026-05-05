package mobile.utils;

import flixel.FlxG;
import openfl.Lib;
import openfl.text.TextField;
import flixel.group.FlxGroup;

class MobileKeyboard {
    public static var isKeyboardShown:Bool = false;

    public static function init():Void {
        #if mobile
        if (!FlxG.signals.postUpdate.has(updateKeyboardStatus)) {
            FlxG.signals.postUpdate.add(updateKeyboardStatus);
        }
        #end
    }

    #if mobile
    private static function updateKeyboardStatus():Void {
        var isFocused:Bool = Std.isOfType(Lib.current.stage.focus, TextField);

        if (!isFocused && FlxG.state != null) {
            isFocused = checkGenericFocus(FlxG.state);
        }

        if (isFocused && !isKeyboardShown) {
            Lib.application.window.textInputEnabled = true;
            isKeyboardShown = true;
        } else if (!isFocused && isKeyboardShown) {
            Lib.application.window.textInputEnabled = false;
            isKeyboardShown = false;
        }
    }

    private static function checkGenericFocus(object:Dynamic):Bool {
        if (object == null) return false;

        if (Reflect.hasField(object, "hasFocus") && Reflect.field(object, "hasFocus") == true) {
            return true;
        }

        if (Std.isOfType(object, FlxTypedGroup)) {
            var group:FlxTypedGroup<Dynamic> = cast object;
            for (member in group.members) {
                if (member != null && checkGenericFocus(member)) return true;
            }
        }
        return false;
    }
    #end
}
