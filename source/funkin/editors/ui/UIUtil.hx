package funkin.editors.ui;

import flixel.util.typeLimit.OneOfTwo;
import flixel.input.FlxInput.FlxInputState;
import flixel.input.keyboard.FlxKey;
import funkin.editors.ui.UIContextMenu.UIContextMenuOption;
import flixel.group.FlxGroup;
import flixel.FlxSprite;
import flixel.FlxG;
import funkin.backend.system.Controls;

#if mobile
import funkin.options.keybinds.KeybindsOptions;
import mobile.controls.VirtualPad;
import mobile.controls.FlxButton;
import mobile.utils.ButtonHelper;
#end
	
@:access(flixel.FlxSprite)
class UIUtil {
	public static function follow(spr:FlxSprite, target:FlxSprite, x:Float = 0, y:Float = 0) {
		if (spr == null || target == null) return;

		spr._cameras = target is UISprite ? ({var _:UISprite = cast target;_;}).__lastDrawCameras : target.cameras;
		spr.x = target.x + x;
		spr.y = target.y + y;
		spr.scrollFactor.set(target.scrollFactor.x, target.scrollFactor.y);
	}

	public static function contextMenuOpened(contextMenu:UIContextMenu) {
		return contextMenu != null && UIState.state.curContextMenu == contextMenu;
	}

	@:noUsing public static function fixKey(key:FlxKey):FlxKey {
		return switch(key) {
			#if mac
			case CONTROL: WINDOWS; 
			#end
			default: key;
		}
	}

	public static function keyToActionString(key:FlxKey):String {
		return switch(key) {
			case W: "up";
			case S: "down";
			case A: "left";
			case D: "right";
			case ENTER: "accept";
			case ESCAPE, BACKSPACE: "back";
			case P: "pause";
			case R: "reset";
			case TAB: "change-mode";
			case Q: "change-mode";
			case E: "pause";
			default: ""; 
		}
	}

	public static function getKeyState(key:FlxKey, Status:FlxInputState):Bool {
		if (FlxG.keys.checkStatus(fixKey(key), Status)) {
			return true;
		}

		var actionString = keyToActionString(key);
		if (actionString == "") {
			return false;
		}

		var controls:Controls = null;
		if (FlxG.state != null && Std.isOfType(FlxG.state, funkin.backend.MusicBeatState)) {
			controls = (cast FlxG.state).controls;
		} 
		else if (FlxG.state != null && FlxG.state.subState != null && Std.isOfType(FlxG.state.subState, funkin.backend.MusicBeatState)) {
			controls = (cast FlxG.state.subState).controls;
		}

		if (controls != null) {
			var propName = actionString.toUpperCase().split("-").join("_");
			var isPressed:Bool = Reflect.getProperty(controls, propName) == true;

			return switch (Status) {
				case JUST_PRESSED:  Reflect.getProperty(controls, propName + "_P") == true;
				case PRESSED:       isPressed;
				case JUST_RELEASED: Reflect.getProperty(controls, propName + "_R") == true;
				case RELEASED:      !isPressed;
				default:            false;
			};
		}

		return false;
	}
	
	public static function processShortcuts(topMenuOptions:Array<UIContextMenuOption>) {
		var maxKeyLength = 0;
		var curTopMenuOption = null;

		for(o in topMenuOptions) {
			if (o == null) continue;

			if (o.keybinds == null) {
				if (o.keybind != null) {
					o.keybinds = [o.keybind];
				}
			}

			if (o.keybinds != null) {
				for (keybind in o.keybinds) {
					var pressed = true;
					var justPressed = false;
					var needsShift = keybind.contains(SHIFT);

					for (key in keybind) {
						var shouldPress = Std.int(key) > 0;
						if(!shouldPress) key = -key;

						var k = fixKey(key);
						
						if (getKeyState(k, shouldPress ? JUST_PRESSED : JUST_RELEASED)) {
							justPressed = true;
						} else if (!getKeyState(k, shouldPress ? PRESSED : RELEASED)) {
							pressed = false;
							break;
						}
					}
					
					var shiftPressed = FlxG.keys != null && FlxG.keys.pressed != null && FlxG.keys.pressed.SHIFT;
					if (!needsShift && shiftPressed) continue;
					if (!pressed || !justPressed) continue;

					if (maxKeyLength < o.keybinds.length) {
						maxKeyLength = o.keybinds.length;
						curTopMenuOption = o;
					}
				}
			}

			if (o.childs != null && processShortcuts(o.childs))
				return true;
		}

		if (curTopMenuOption != null) {
			if (curTopMenuOption.onSelect != null)
				curTopMenuOption.onSelect(curTopMenuOption);
			return true;
		}
		return false;
	}

	public static function toUIString(key:FlxKey):String {
		return switch(key) {
			case CONTROL: 		#if mac "Cmd" #else "Ctrl" #end; 
			case ALT:			#if mac "Option" #else "Alt" #end;
			case HOME:			"Home";
			case ENTER:			"Enter";
			case DELETE:		"Del";
			case SHIFT:			"Shift";
			case SPACE:			"Space";
			case NUMPADZERO:	"[0]";
			case NUMPADONE:		"[1]";
			case NUMPADTWO:		"[2]";
			case NUMPADTHREE:	"[3]";
			case NUMPADFOUR:	"[4]";
			case NUMPADFIVE:	"[5]";
			case NUMPADSIX:		"[6]";
			case NUMPADSEVEN:	"[7]";
			case NUMPADEIGHT:	"[8]";
			case NUMPADNINE:	"[9]";
			case NUMPADPLUS:	"[+]";
			case NUMPADMINUS:	"[-]";
			case ZERO:			"0";
			case ONE:			"1";
			case TWO:			"2";
			case THREE:			"3";
			case FOUR:			"4";
			case FIVE:			"5";
			case SIX:			"6";
			case SEVEN:			"7";
			case EIGHT:			"8";
			case NINE:			"9";
			default: prettify(key.toString());
		}
	}

	public static inline function prettify(str:String) {
		return [for(s in str.split(" ")) [for(k=>l in s.split("")) k == 0 ? l.toUpperCase() : l.toLowerCase()].join("")].join(" ");
	}

	public static function confirmUISelections(ui:Dynamic) {
		if (ui == null) return;

		var members:Array<FlxBasic> = [];

		if (Reflect.fields(ui).contains("members")) 
			members = Reflect.field(ui, "members");
		else return;

		if (members == null) return; 

		for (member in members) {
			if (member == null) continue;
			
			if (member is UINumericStepper) @:privateAccess {
				var stepper:UINumericStepper = cast member;
				if (stepper.onChange != stepper.__onChange && stepper.__wasFocused) {
					stepper.onChange(stepper.label.text);
					stepper.__wasFocused = false;
				} else stepper.__onChange(stepper.label.text);

			} else if (member is UITextBox) @:privateAccess {
				var textbox:UITextBox = cast member;
				if (textbox.__wasFocused) {
					if (textbox.onChange != null) textbox.onChange(textbox.label.text);
					textbox.__wasFocused = false;
				}
			}

			if (member is UISprite || ui is UIState)
				confirmUISelections(cast member);
		}
	}
}
