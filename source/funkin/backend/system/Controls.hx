package funkin.backend.system;

import flixel.input.FlxInput;
import flixel.input.actions.FlxAction;
import flixel.input.actions.FlxActionInput;
import flixel.input.actions.FlxActionManager;
import flixel.input.actions.FlxActionSet;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.keyboard.FlxKey;

#if mobile
import mobile.controls.VirtualPad;
import flixel.FlxG;
#end

enum Control
{
	UP;
	LEFT;
	RIGHT;
	DOWN;
	NOTE_UP;
	NOTE_LEFT;
	NOTE_RIGHT;
	NOTE_DOWN;
	RESET;
	ACCEPT;
	BACK;
	PAUSE;
	CHANGE_MODE;
	SWITCHMOD;
	FPS_COUNTER;

	// Debugs
	DEV_ACCESS;
	DEV_CONSOLE;
	DEV_RELOAD;
}

enum KeyboardScheme
{
	Solo;
	Duo(first:Bool);
	None;
	Custom;
}

#if mobile
typedef VirtualPadConfig = {
	?dpadMode:Dynamic,
	?actionMode:Dynamic,
	?directionBindings:Array<String>,
	?actionBindings:Array<String>
}
#end

@:noCustomClass
@:nullSafety
@:build(funkin.backend.system.macros.ControlsMacro.build())
class Controls extends FlxActionSet
{
	#if mobile
	public static var virtualPad:Null<VirtualPad>;
	public static var padConfig:VirtualPadConfig = {};

	static var holdStates:Map<String, Bool> = [];
    static var pressTimers:Map<String, Float> = [];

	private var holdTimers:Map<String, Float> = new Map();
	private var holdStates:Map<String, Bool> = new Map();

	public static inline var HOLD_DELAY:Float = 0.10;
	public static inline var HOLD_REPEAT:Float = 0.025;
	#end

	// Menus
	#if !switch
	@:rawGamepad([DPAD_UP, LEFT_STICK_DIGITAL_UP])
	#else
	@:rawGamepad([DPAD_UP, LEFT_STICK_DIGITAL_UP, RIGHT_STICK_DIGITAL_UP])
	#end
	@:pressed("up") public var UP(get, set): Bool;
	@:justPressed("up") public var UP_P(get, set): Bool;
	@:justReleased("up") public var UP_R(get, set): Bool;

	#if !switch
	@:rawGamepad([DPAD_LEFT, LEFT_STICK_DIGITAL_LEFT])
	#else
	@:rawGamepad([DPAD_LEFT, LEFT_STICK_DIGITAL_LEFT, RIGHT_STICK_DIGITAL_LEFT])
	#end
	@:pressed("left") public var LEFT(get, set): Bool;
	@:justPressed("left") public var LEFT_P(get, set): Bool;
	@:justReleased("left") public var LEFT_R(get, set): Bool;

	#if !switch
	@:rawGamepad([DPAD_RIGHT, LEFT_STICK_DIGITAL_RIGHT])
	#else
	@:rawGamepad([DPAD_RIGHT, LEFT_STICK_DIGITAL_RIGHT, RIGHT_STICK_DIGITAL_RIGHT])
	#end
	@:pressed("right") public var RIGHT(get, set): Bool;
	@:justPressed("right") public var RIGHT_P(get, set): Bool;
	@:justReleased("right") public var RIGHT_R(get, set): Bool;

	#if !switch
	@:rawGamepad([DPAD_DOWN, LEFT_STICK_DIGITAL_DOWN])
	#else
	@:rawGamepad([DPAD_DOWN, LEFT_STICK_DIGITAL_DOWN, RIGHT_STICK_DIGITAL_DOWN])
	#end
	@:pressed("down") public var DOWN(get, set): Bool;
	@:justPressed("down") public var DOWN_P(get, set): Bool;
	@:justReleased("down") public var DOWN_R(get, set): Bool;

	// Note Controls

	#if !switch
	@:rawGamepad([DPAD_UP, LEFT_STICK_DIGITAL_UP])
	#else
	@:rawGamepad([DPAD_UP, LEFT_STICK_DIGITAL_UP, RIGHT_STICK_DIGITAL_UP])
	#end
	@:pressed("note-up") public var NOTE_UP(get, set): Bool;
	@:justPressed("note-up") public var NOTE_UP_P(get, set): Bool;
	@:justReleased("note-up") public var NOTE_UP_R(get, set): Bool;

	#if !switch
	@:rawGamepad([DPAD_LEFT, LEFT_STICK_DIGITAL_LEFT])
	#else
	@:rawGamepad([DPAD_LEFT, LEFT_STICK_DIGITAL_LEFT, RIGHT_STICK_DIGITAL_LEFT])
	#end
	@:pressed("note-left") public var NOTE_LEFT(get, set): Bool;
	@:justPressed("note-left") public var NOTE_LEFT_P(get, set): Bool;
	@:justReleased("note-left") public var NOTE_LEFT_R(get, set): Bool;

	#if !switch
	@:rawGamepad([DPAD_RIGHT, LEFT_STICK_DIGITAL_RIGHT])
	#else
	@:rawGamepad([DPAD_RIGHT, LEFT_STICK_DIGITAL_RIGHT, RIGHT_STICK_DIGITAL_RIGHT])
	#end
	@:pressed("note-right") public var NOTE_RIGHT(get, set): Bool;
	@:justPressed("note-right") public var NOTE_RIGHT_P(get, set): Bool;
	@:justReleased("note-right") public var NOTE_RIGHT_R(get, set): Bool;

	#if !switch
	@:rawGamepad([DPAD_DOWN, LEFT_STICK_DIGITAL_DOWN])
	#else
	@:rawGamepad([DPAD_DOWN, LEFT_STICK_DIGITAL_DOWN, RIGHT_STICK_DIGITAL_DOWN])
	#end
	@:pressed("note-down") public var NOTE_DOWN(get, set): Bool;
	@:justPressed("note-down") public var NOTE_DOWN_P(get, set): Bool;
	@:justReleased("note-down") public var NOTE_DOWN_R(get, set): Bool;

	@:gamepad([A])
	@:justPressed("accept") public var ACCEPT(get, set): Bool;
	@:pressed("accept") public var ACCEPT_HOLD(get, set): Bool;
	@:justReleased("accept") public var ACCEPT_R(get, set): Bool;

	@:gamepad([B])
	@:justPressed("back") public var BACK(get, set): Bool;
	@:pressed("back") public var BACK_HOLD(get, set): Bool;
	@:justReleased("back") public var BACK_R(get, set): Bool;

	@:gamepad([START])
	@:justPressed("pause") public var PAUSE(get, set): Bool;
	@:pressed("pause") public var PAUSE_HOLD(get, set): Bool;
	@:justReleased("pause") public var PAUSE_R(get, set): Bool;

	@:gamepad([Y])
	@:justPressed("reset") public var RESET(get, set): Bool;
	@:pressed("reset") public var RESET_HOLD(get, set): Bool;
	@:justReleased("reset") public var RESET_R(get, set): Bool;

	@:gamepad([FlxGamepadInputID.BACK])
	@:justPressed("change-mode") public var CHANGE_MODE(get, set): Bool;
	@:pressed("change-mode") public var CHANGE_MODE_HOLD(get, set): Bool;
	@:justReleased("change-mode") public var CHANGE_MODE_R(get, set): Bool;

	@:gamepad([FlxGamepadInputID.BACK])
	@:justPressed("switchmod") public var SWITCHMOD(get, set): Bool;
	@:pressed("switchmod") public var SWITCHMOD_HOLD(get, set): Bool;
	@:justReleased("switchmod") public var SWITCHMOD_R(get, set): Bool;

	@:gamepad([])
	@:justPressed("fps-counter") public var FPS_COUNTER(get, set): Bool;
	@:pressed("fps-counter") public var FPS_COUNTER_HOLD(get, set): Bool;
	@:justReleased("fps-counter") public var FPS_COUNTER_R(get, set): Bool;

	@:devModeOnly
	@:gamepad([])
	@:justPressed("dev-access") public var DEV_ACCESS(get, set): Bool;
	@:pressed("dev-access") public var DEV_ACCESS_HOLD(get, set): Bool;
	@:justReleased("dev-access") public var DEV_ACCESS_R(get, set): Bool;

	@:devModeOnly
	@:gamepad([])
	@:justPressed("dev-console") public var DEV_CONSOLE(get, set): Bool;
	@:pressed("dev-console") public var DEV_CONSOLE_HOLD(get, set): Bool;
	@:justReleased("dev-console") public var DEV_CONSOLE_R(get, set): Bool;

	@:devModeOnly
	@:gamepad([])
	@:justPressed("dev-reload") public var DEV_RELOAD(get, set): Bool;
	@:pressed("dev-reload") public var DEV_RELOAD_HOLD(get, set): Bool;
	@:justReleased("dev-reload") public var DEV_RELOAD_R(get, set): Bool;

	@:allow(funkin.backend.utils.ControlsUtil)
	var byName:Map<String, FlxActionDigital> = [];

	public var gamepadsAdded:Array<Int> = [];
	public var keyboardScheme:KeyboardScheme = None;

	public function new(name, scheme = None)
	{
		super(name);

		macro_addKeysToActions();

		for (action in digitalActions)
			byName[action.name] = action;

		setKeyboardScheme(scheme, false);
	}

	public function getActionFromControl(control:Control):FlxAction return macro_getActionFromControl(control);

	public function getKeyName(control:Control, idx:Int = 0):String
	{
		var action = macro_getActionFromControl(control);
		var input = action.inputs[idx];
		return switch input.device
		{
			case KEYBOARD: return '${(input.inputID : FlxKey)}';
			case GAMEPAD: return '${(input.inputID : FlxGamepadInputID)}';
			case device: throw 'unhandled device: $device';
		}
	}

	public function replaceBindingKeyboard(control:Control, ?toAdd:Int, ?toRemove:Int)
	{
		if (toAdd == toRemove)
			return;

		if (toRemove != null)
			unbindKeys(control, [toRemove]);
		if (toAdd != null)
			bindKeys(control, [toAdd]);
	}

	public function replaceBindingGamepad(control:Control, deviceID:Int, ?toAdd:Int, ?toRemove:Int)
	{
		if (toAdd == toRemove)
			return;

		if (toRemove != null)
			unbindButtons(control, deviceID, [toRemove]);
		if (toAdd != null)
			bindButtons(control, deviceID, [toAdd]);
	}

	public inline function bindKeys(control:Control, keys:Array<FlxKey>)
	{
		macro_forEachBound(control, (action, state) -> addKeys(action, keys, state));
	}

	public inline function unbindKeys(control:Control, keys:Array<FlxKey>)
	{
		macro_forEachBound(control, (action, _) -> removeKeys(action, keys));
	}

	public inline static function addKeys(action:FlxActionDigital, keys:Array<FlxKey>, state:FlxInputState)
	{
		for (key in keys)
			action.addKey(key, state);
	}

	public static function removeKeys(action:FlxActionDigital, keys:Array<FlxKey>)
	{
		var i = action.inputs.length;
		while (i-- > 0)
		{
			var input = action.inputs[i];
			if (input.device == KEYBOARD && keys.contains(cast input.inputID))
				action.remove(input);
		}
	}

	public function setKeyboardScheme(scheme:KeyboardScheme, reset = true)
	{
		if (reset)
			removeKeyboard();

		keyboardScheme = scheme;

		macro_bindControls(scheme);
	}

	function removeKeyboard()
	{
		for (action in this.digitalActions)
		{
			var i = action.inputs.length;
			while (i-- > 0)
			{
				var input = action.inputs[i];
				if (input.device == KEYBOARD)
					action.remove(input);
			}
		}
	}

	public function addGamepad(id:Int, buttonMap:Map<Control, Array<FlxGamepadInputID>>):Void
	{
		gamepadsAdded.push(id);

		for (control => buttons in buttonMap)
			bindButtons(control, id, buttons);
	}

	public function removeGamepad(deviceID:Int = FlxInputDeviceID.ALL):Void
	{
		for (action in this.digitalActions)
		{
			var i = action.inputs.length;
			while (i-- > 0)
			{
				var input = action.inputs[i];
				if (isGamepad(input, deviceID))
					action.remove(input);
			}
		}

		gamepadsAdded.remove(deviceID);
	}

	public inline function bindButtons(control:Control, id, buttons)
	{
		macro_forEachBound(control, (action, state) -> addButtons(action, buttons, state, id));
	}

	public inline function unbindButtons(control:Control, gamepadID:Int, buttons)
	{
		macro_forEachBound(control, (action, _) -> removeButtons(action, gamepadID, buttons));
	}

	public inline static function addButtons(action:FlxActionDigital, buttons:Array<FlxGamepadInputID>, state, id)
	{
		for (button in buttons)
			action.addGamepad(button, state, id);
	}

	public static function removeButtons(action:FlxActionDigital, gamepadID:Int, buttons:Array<FlxGamepadInputID>)
	{
		var i = action.inputs.length;
		while (i-- > 0)
		{
			var input = action.inputs[i];
			if (isGamepad(input, gamepadID) && buttons.contains(cast input.inputID))
				action.remove(input);
		}
	}

	public inline static function isGamepad(input:FlxActionInput, deviceID:Int)
	{
		return input.device == GAMEPAD && (deviceID == FlxInputDeviceID.ALL || input.deviceID == deviceID);
	}

	@:nullSafety(Off)
	public function getJustPressed(name:String):Bool {
		#if mobile
		if (virtualPad != null && virtualPad.exists && name != null) {
			var pad = virtualPad;
			switch(name) {
				case "up" | "note-up" | "ui_up" | "UP":
					if (pad.buttonUp != null && pad.buttonUp.justPressed) return true;
				case "down" | "note-down" | "ui_down" | "DOWN":
					if (pad.buttonDown != null && pad.buttonDown.justPressed) return true;
				case "left" | "note-left" | "ui_left" | "LEFT":
					if (pad.buttonLeft != null && pad.buttonLeft.justPressed) return true;
				case "right" | "note-right" | "ui_right" | "RIGHT":
					if (pad.buttonRight != null && pad.buttonRight.justPressed) return true;
				case "accept" | "ACCEPT":
					if (pad.buttonA != null && pad.buttonA.justPressed) return true;
				case "back" | "BACK":
					if (pad.buttonB != null && pad.buttonB.justPressed) return true;
				case "switchmod" | "SWITCHMOD":
					if (pad.buttonX != null && pad.buttonX.justPressed) return true;
				case "dev-access" | "DEV_ACCESS":
					if (pad.buttonY != null && pad.buttonY.justPressed) return true;
				case "pause" | "change-mode" | "PAUSE":
					if (pad.buttonC != null && pad.buttonC.justPressed) return true;
				case "fps-counter" | "cheat" | "reset" | "RESET":
					// Handle reset/fps-counter
			}
		}
		#end
		return funkin.backend.utils.ControlsUtil.getJustPressed(this, name);
	}

	@:nullSafety(Off)
	public function getJustReleased(name:String):Bool {
		#if mobile
		if (virtualPad != null && virtualPad.exists && name != null) {
			var pad = virtualPad;
			switch(name) {
				case "up" | "note-up" | "ui_up" | "UP":
					if (pad.buttonUp != null && pad.buttonUp.justReleased) return true;
				case "down" | "note-down" | "ui_down" | "DOWN":
					if (pad.buttonDown != null && pad.buttonDown.justReleased) return true;
				case "left" | "note-left" | "ui_left" | "LEFT":
					if (pad.buttonLeft != null && pad.buttonLeft.justReleased) return true;
				case "right" | "note-right" | "ui_right" | "RIGHT":
					if (pad.buttonRight != null && pad.buttonRight.justReleased) return true;
				case "accept" | "ACCEPT":
					if (pad.buttonA != null && pad.buttonA.justReleased) return true;
				case "back" | "BACK":
					if (pad.buttonB != null && pad.buttonB.justReleased) return true;
				case "switchmod" | "SWITCHMOD":
					if (pad.buttonX != null && pad.buttonX.justReleased) return true;
				case "dev-access" | "DEV_ACCESS":
					if (pad.buttonY != null && pad.buttonY.justReleased) return true;
				case "pause" | "change-mode" | "PAUSE":
					if (pad.buttonC != null && pad.buttonC.justReleased) return true;
			}
		}
		#end
		return funkin.backend.utils.ControlsUtil.getJustReleased(this, name);
	}

	@:nullSafety(Off)
    public function getPressed(name:String):Bool {
    var isPressed:Bool = false;

    #if mobile
    if (virtualPad != null && virtualPad.exists && name != null) {
        var pad = virtualPad;
        switch(name) {
            case "up" | "note-up" | "ui_up" | "UP":
                isPressed = pad.buttonUp != null && pad.buttonUp.pressed;
            case "down" | "note-down" | "ui_down" | "DOWN":
                isPressed = pad.buttonDown != null && pad.buttonDown.pressed;
            case "left" | "note-left" | "ui_left" | "LEFT":
                isPressed = pad.buttonLeft != null && pad.buttonLeft.pressed;
            case "right" | "note-right" | "ui_right" | "RIGHT":
                isPressed = pad.buttonRight != null && pad.buttonRight.pressed;
            case "accept" | "ACCEPT":
                isPressed = pad.buttonA != null && pad.buttonA.pressed;
            case "back" | "BACK":
                isPressed = pad.buttonB != null && pad.buttonB.pressed;
            case "switchmod" | "SWITCHMOD":
                isPressed = pad.buttonX != null && pad.buttonX.pressed;
            case "dev-access" | "DEV_ACCESS":
                isPressed = pad.buttonY != null && pad.buttonY.pressed;
            case "pause" | "change-mode" | "PAUSE":
                isPressed = pad.buttonC != null && pad.buttonC.pressed;
        }
    }
    #end

    isPressed = isPressed || funkin.backend.utils.ControlsUtil.checkControl(this, name);

    var currentTime:Float = haxe.Timer.stamp();

    if (isPressed) {
        if (!holdStates.exists(name) || holdStates.get(name) == false) {
            holdStates.set(name, true);
            pressTimers.set(name, currentTime + 0.15);
            return true;
        } else if (currentTime >= pressTimers.get(name)) {
            pressTimers.set(name, currentTime + 0.05);
            return true;
        }
    } else {
        holdStates.set(name, false);
    }

    return false;
}

    public function pressedRepeat(name:String):Bool
{
    #if mobile
    var isHeld = getPressed(name);
    var just = getJustPressed(name);

    if (!isHeld)
    {
        holdTimers.set(name, 0);
        holdStates.set(name, false);
        return false;
    }

    if (just)
    {
        holdTimers.set(name, 0);
        holdStates.set(name, false);
        return true;
    }

    var timer:Float = holdTimers.get(name) ?? 0;
    var active:Bool = holdStates.get(name) ?? false;

    timer += FlxG.elapsed;

    if (!active)
    {
        if (timer >= HOLD_DELAY)
        {
            holdStates.set(name, true);
            timer -= HOLD_DELAY;
            holdTimers.set(name, timer);
            return true;
        }
    }
    else
    {
        if (timer >= HOLD_REPEAT)
        {
            timer -= HOLD_REPEAT;
            holdTimers.set(name, timer);
            return true;
        }
    }

    holdTimers.set(name, timer);
    return false;
    #else
    return false;
    #end
}

	public static function updateMouseBlock():Void
	{
		#if mobile
		if (virtualPad != null && virtualPad.exists)
		{
			var onUI:Bool = false;
			for (touch in FlxG.touches.list)
			{
				var touchPos = touch.getScreenPosition(); 
				
				if (virtualPad.isTouchOnPad(touchPos))
				{
					onUI = true;
					touchPos.put();
					break;
				}
				touchPos.put();
			}

			if (!onUI)
			{
				var mousePos = FlxG.mouse.getScreenPosition();
				onUI = virtualPad.isTouchOnPad(mousePos);
				mousePos.put();
			}

			// FlxG.mouse.enabled = !onUI;
		}
		#end
	}
}
