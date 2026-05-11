package mobile.backend;

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

    public static function Kill():Void {
        if (_instance != null) {
            FlxG.plugins.remove(_instance);
            Lib.application.window.textInputEnabled = false;
            _instance = null;
        }
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (FlxG.mouse.justReleased || (FlxG.touches.list.length > 0 && FlxG.touches.list[0].justReleased)) {
            checkInputFocus();
        }
    }

    private function checkInputFocus():Void
    {
        var foundInput:Bool = false;
        var mousePos = FlxG.mouse.getScreenPosition();

        function search(basic:FlxBasic):Void {
            if (foundInput || basic == null || !basic.exists || !basic.visible) return;

            if (Std.isOfType(basic, FlxInputText)) {
                var input:FlxInputText = cast basic;
                if (FlxG.mouse.overlaps(input, input.camera)) {
                    @:privateAccess input.hasFocus = true;
                    Lib.application.window.textInputEnabled = true;
                    foundInput = true;
                } else {
                    @:privateAccess input.hasFocus = false;
                }
            } 
            else if (Std.isOfType(basic, FlxTypedGroup)) {
                var group:FlxTypedGroup<Dynamic> = cast basic;
                group.forEach(search, true);
            }
        }

        if (FlxG.state != null) {
            FlxG.state.forEach(search, true);
            
            if (FlxG.state.subState != null) {
                FlxG.state.subState.forEach(search, true);
            }
        }

        if (!foundInput) {
            Lib.application.window.textInputEnabled = false;
        }
    }
}
