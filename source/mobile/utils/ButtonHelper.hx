package mobile.utils;

#if mobile
import mobile.controls.VirtualPad;
import StringTools;
#end

class ButtonHelper
{
    #if mobile

    public static function create(parent:Dynamic, dpad:Dynamic, action:Dynamic):VirtualPad
    {
        var vpad = new VirtualPad(dpad, action);
        if (parent != null) parent.add(vpad);
        return vpad;
    }

    public static function bind(vpad:VirtualPad, dpad:Array<String>, actions:Array<String>):Void
    {
        if (vpad == null) return;

        // ---- DPAD ----
        if (dpad != null)
        {
            var up    = dpad.length > 0 ? dpad[0] : null;
            var down  = dpad.length > 1 ? dpad[1] : null;
            var left  = dpad.length > 2 ? dpad[2] : null;
            var right = dpad.length > 3 ? dpad[3] : null;

            // IMPORTANT: use control names (UP, DOWN, etc)
            vpad.bindDPad(up, down, left, right);
        }

        // ---- ACTION BUTTONS ----
        if (actions != null)
        {
            switch (actions.length)
            {
                case 1: vpad.bindActionGroup(actions[0]);
                case 2: vpad.bindActionGroup(actions[0], actions[1]);
                case 3: vpad.bindActionGroup(actions[0], actions[1], actions[2]);
                case 4: vpad.bindActionGroup(actions[0], actions[1], actions[2], actions[3]);
                case 5: vpad.bindActionGroup(actions[0], actions[1], actions[2], actions[3], actions[4]);
                default:
            }
        }
    }

    #end
}
