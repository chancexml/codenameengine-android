package mobile.utils;

#if mobile
import mobile.controls.VirtualPad;
import funkin.options.Options;
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

        Options.controlButtons.clear();

        // ---- DPAD ----
        if (dpad != null)
        {
            if (dpad.length > 0 && dpad[0] != null) Options.controlButtons.set(dpad[0].toUpperCase(), vpad.buttonUp);
            if (dpad.length > 1 && dpad[1] != null) Options.controlButtons.set(dpad[1].toUpperCase(), vpad.buttonDown);
            if (dpad.length > 2 && dpad[2] != null) Options.controlButtons.set(dpad[2].toUpperCase(), vpad.buttonLeft);
            if (dpad.length > 3 && dpad[3] != null) Options.controlButtons.set(dpad[3].toUpperCase(), vpad.buttonRight);

            vpad.bindDPad(
                dpad.length > 0 ? dpad[0] : null,
                dpad.length > 1 ? dpad[1] : null,
                dpad.length > 2 ? dpad[2] : null,
                dpad.length > 3 ? dpad[3] : null
            );
        }

        // ---- ACTION BUTTONS ----
        if (actions != null)
        {
            if (actions.length > 0) Options.controlButtons.set(actions[0].toUpperCase(), vpad.buttonA);
            if (actions.length > 1) Options.controlButtons.set(actions[1].toUpperCase(), vpad.buttonB);
            if (actions.length > 2) Options.controlButtons.set(actions[2].toUpperCase(), vpad.buttonX);
            if (actions.length > 3) Options.controlButtons.set(actions[3].toUpperCase(), vpad.buttonY);
            if (actions.length > 4) Options.controlButtons.set(actions[4].toUpperCase(), vpad.buttonC);

            switch (actions.length)
            {
                case 1: vpad.bindActionGroup(actions[0]);
                case 2: vpad.bindActionGroup(actions[0], actions[1]);
                case 3: vpad.bindActionGroup(actions[0], actions[1], actions[2]);
                case 4: vpad.bindActionGroup(actions[0], actions[1], actions[2], actions[3]);
                case 5: vpad.bindActionGroup(actions[0], actions[1], actions[2], actions[3], actions[4]);
            }
        }
    }
    #end
}
