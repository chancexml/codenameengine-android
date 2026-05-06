package mobile.utils;

import flixel.FlxG;
import flixel.FlxBasic;
import flixel.math.FlxPoint;
import openfl.Lib;
import flixel.text.FlxInputText; 

class AndroidKeyboard extends FlxBasic
{
    private static var _instance:AndroidKeyboard;

    public static function init():Void
    {
        if (_instance == null) {
            _instance = new AndroidKeyboard();
            FlxG.plugins.add(_instance);
        }
    }

    public function new()
    {
        super();
        visible = false;
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (FlxG.mouse.justReleased || (FlxG.touches.getFirst() != null && FlxG.touches.getFirst().justReleased)) {
            checkInputFocus();
        }
    }

    private function checkInputFocus():Void
    {
        var foundInput:Bool = false;
        var mousePos:FlxPoint = FlxG.mouse.getScreenPosition();

        var checkObject = function(obj:Dynamic) {
            if (obj != null && obj.visible && obj.exists) {
                if (Std.isOfType(obj, FlxInputText)) {
                    var input:FlxInputText = cast obj;
                    
                    var targetCam = input.camera; 
                    if (input.getScreenBounds(null, targetCam).containsXY(mousePos.x, mousePos.y)) {
                        
                        @:privateAccess input.hasFocus = true;
                        
                        Lib.application.window.textInputEnabled = true;
                        
                        foundInput = true;
                    }
                }
            }
        };

        FlxG.state.forEach(checkObject, true);

        if (FlxG.state.subState != null) {
            FlxG.state.subState.forEach(checkObject, true);
        }
    }
}
