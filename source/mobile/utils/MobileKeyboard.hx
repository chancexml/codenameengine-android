package mobile.utils;

import flixel.FlxG;
import flixel.FlxBasic;
import flixel.group.FlxGroup;
import flixel.addons.ui.FlxInputText;

class MobileKeyboard {
    public static var isKeyboardShown:Bool = false;

    public static function init():Void {
        #if mobile
        if (!FlxG.signals.postUpdate.has(checkInputFocus)) {
            FlxG.signals.postUpdate.add(checkInputFocus);
        }
        #end
    }

    #if mobile
    private static function checkInputFocus():Void {
        var inputFocused:Bool = false;
        
        function checkMember(member:FlxBasic) {
            if (inputFocused || member == null) return; 

            if (Std.isOfType(member, FlxGroup)) {
                var group:FlxGroup = cast member;
                group.forEachAlive(checkMember);
            } 
            else if (Std.isOfType(member, FlxInputText)) {
                var inputText:FlxInputText = cast member;
                
                if (inputText.hasFocus) {
                    inputFocused = true;
                }
            }
        }

        if (FlxG.state != null) {
            FlxG.state.forEachAlive(checkMember);
          
            if (FlxG.state.subState != null) {
                FlxG.state.subState.forEachAlive(checkMember);
            }
        }

        if (inputFocused && !isKeyboardShown) {
            openfl.Lib.application.window.textInputEnabled = true;
            isKeyboardShown = true;
        } else if (!inputFocused && isKeyboardShown) {
            openfl.Lib.application.window.textInputEnabled = false;
            isKeyboardShown = false;
        }
    }
    #end
}
