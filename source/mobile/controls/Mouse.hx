import flixel.FlxG;
import mobile.controls.VirtualMouse;

#if mobile
import funkin.backend.system.Controls;
#end

class Call {
    public static var virtualMouse:VirtualMouse;

    public static function Mouse():Void {
        if (virtualMouse == null) {
            virtualMouse = new VirtualMouse(FlxG.width / 2, FlxG.height / 2);
            
            #if mobile
            if (Controls.virtualPad != null) {
                virtualMouse.ignoreGroup = Controls.virtualPad;
            }
            #end

            FlxG.state.add(virtualMouse);
        }
    }
}
