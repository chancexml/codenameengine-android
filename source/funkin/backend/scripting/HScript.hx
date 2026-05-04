package funkin.backend.scripting;

import hscript.*;
import hscript.Expr.Error;
import hscript.Parser;
import openfl.Assets;

import funkin.backend.system.Controls;

import funkin.backend.utils.NativeAPI;

#if mobile
import extension.androidtools.Tools;
import extension.androidtools.content.Context;
import mobile.utils.ButtonHelper;
import mobile.controls.VirtualPad;
#end

class HScript extends Script {
	public var interp:Interp;
	public var parser:Parser;
	public var expr:Expr;
	public var code:String = null;
	var __importedPaths:Array<String>;

	public static function initParser() {
		var parser = new Parser();
		parser.allowJSON = parser.allowMetadata = parser.allowTypes = true;
		parser.preprocessorValues = Script.getDefaultPreprocessors();
		return parser;
	}

	public override function onCreate(path:String) {
		super.onCreate(path);

		interp = new Interp();

		try {
			if(Assets.exists(rawPath)) code = Assets.getText(rawPath);
		} catch(e) {
			var errorMsg = 'Error while reading $path: ${Std.string(e)}';
			Logs.error(errorMsg);
			#if android
			extension.androidtools.Tools.showAlertDialog("Error!", errorMsg, "Got It!");
			#end
		}
		
		parser = initParser();
		__importedPaths = [path];

		interp.errorHandler = _errorHandler;
		interp.warnHandler = _warnHandler;
		interp.importFailedCallback = importFailedCallback;
		interp.staticVariables = Script.staticVariables;
		interp.allowStaticVariables = interp.allowPublicVariables = true;

		interp.variables.set("trace", Reflect.makeVarArgs((args) -> {
			var v:String = Std.string(args.shift());
			for (a in args) v += ", " + Std.string(a);
			this.trace(v);
		}));
		
		interp.variables.set("Controls", Controls);

		#if mobile
		interp.variables.set("ButtonHelper", ButtonHelper);
		interp.variables.set("VirtualPad", VirtualPad);
		#end
        /**
        if u want to. you can add the virtualpad to any mod made for pc inputs
        you just have to add

        createPad(FULL, A_B); // found here // uh uh
        bindPad(
            ['ui_up','ui_down','ui_left','ui_right'], // variables found in Controls.hx
            ['accept','back'] // same thing as the one above this one
        );

        you'll still need to change how the script checks for inputs
        heres an example:
        original
        if (controls.ACCEPT)
        new
        if (controls.getJustPressed("accept"))
        **/
		#if mobile
        interp.variables.set("NONE", NONE);
		interp.variables.set("UP_DOWN", UP_DOWN);
		interp.variables.set("LEFT_RIGHT", LEFT_RIGHT);
		interp.variables.set("UP_LEFT_RIGHT", UP_LEFT_RIGHT);
		interp.variables.set("DOWN_LEFT_RIGHT", DOWN_LEFT_RIGHT);
		interp.variables.set("RIGHT_FULL", RIGHT_FULL);
		interp.variables.set("FULL", FULL);
        interp.variables.set("A", A);
		interp.variables.set("B", B);
		interp.variables.set("C", C);
		interp.variables.set("X", X);
		interp.variables.set("Y", Y);
		interp.variables.set("A_B", A_B);
		interp.variables.set("A_C", A_C);
	    interp.variables.set("A_X", A_X);
		interp.variables.set("A_Y", A_Y);
		interp.variables.set("A_B_C", A_B_C);
		interp.variables.set("A_X_Y", A_X_Y);
		interp.variables.set("A_B_X_Y", A_B_X_Y);
		interp.variables.set("A_C_X_Y", A_C_X_Y);
		interp.variables.set("A_B_C_X_Y", A_B_C_X_Y);
		interp.variables.set("B_C", B_C);
		interp.variables.set("B_X", B_X);
		interp.variables.set("B_X_Y", B_X_Y);
		interp.variables.set("B_C_X_Y", B_C_X_Y);
        #end

		#if mobile
        interp.variables.set("createPad", function(mode, buttons) {
        var state = interp.scriptObject;
          var pad = ButtonHelper.create(state, mode, buttons);
            Controls.virtualPad = pad;
          return pad;
        });

        interp.variables.set("bindPad", function(dpad:Array<String>, actions:Array<String>) {
        if (Controls.virtualPad != null) {
            ButtonHelper.bind(Controls.virtualPad, dpad, actions);
           }
        });
        #end

		#if GLOBAL_SCRIPT
		funkin.backend.scripting.GlobalScript.call("onScriptCreated", [this, "hscript"]);
		#end
		loadFromString(code);
	}

	public override function loadFromString(code:String) {
		try {
			if (code != null && code.trim() != "")
				expr = parser.parseString(code, fileName);
		} catch(e:Error) {
			_errorHandler(e);
		} catch(e) {
			_errorHandler(new Error(ECustom(e.toString()), 0, 0, fileName, 0));
		}

		return this;
	}

	private function importFailedCallback(cl:Array<String>, ?asName:String):Bool {
		if(_importFailedCallback(cl, "source/") || _importFailedCallback(cl, "")) {
			return true;
		}
		return false;
	}

	private function _importFailedCallback(cl:Array<String>, prefix:String):Bool {
		var assetsPath = 'assets/$prefix${cl.join("/")}';
		for(hxExt in ["hx", "hscript", "hsc", "hxs"]) {
			var p = '$assetsPath.$hxExt';
			if (__importedPaths.contains(p))
				return true; 
			if (Assets.exists(p)) {
				var code = Assets.getText(p);
				var expr:Expr = null;
				try {
					if (code != null && code.trim() != "") {
						parser.line = 1; 
						expr = parser.parseString(code, cl.join("/") + "." + hxExt);
					}
				} catch(e:Error) {
					_errorHandler(e);
				} catch(e) {
					_errorHandler(new Error(ECustom(e.toString()), 0, 0, fileName, 0));
				}
				if (expr != null) {
					@:privateAccess
					interp.exprReturn(expr);
					__importedPaths.push(p);
				}
				return true;
			}
		}
		return false;
	}

	private function _errorHandler(error:Error) {
	var fileName = error.origin;
	var oldfn = '$fileName:${error.line}: ';
	if(remappedNames.exists(fileName))
		fileName = remappedNames.get(fileName);
	var fn = '$fileName:${error.line}: ';
	var err = error.toString();
	while(err.startsWith(oldfn) || err.startsWith(fn)) {
		if (err.startsWith(oldfn)) err = err.substr(oldfn.length);
		if (err.startsWith(fn)) err = err.substr(fn.length);
	}

		Logs.traceColored([
		  Logs.logText(fn, GREEN),
		  Logs.logText(err, RED)
		], ERROR);
		
		#if android
		extension.androidtools.Tools.showAlertDialog("HScript Error", fn + err, "Got it!");
		#end
	}

	private function _warnHandler(error:Error) {
	var fileName = error.origin;
	var oldfn = '$fileName:${error.line}: ';
	if(remappedNames.exists(fileName))
		fileName = remappedNames.get(fileName);
	var fn = '$fileName:${error.line}: ';
	var err = error.toString();
	while(err.startsWith(oldfn) || err.startsWith(fn)) {
		if (err.startsWith(oldfn)) err = err.substr(oldfn.length);
		if (err.startsWith(fn)) err = err.substr(fn.length);
	}

	Logs.traceColored([
	    Logs.logText(fn, GREEN),
        Logs.logText(err, YELLOW)
	], WARNING);

	#if android
	extension.androidtools.Tools.showAlertDialog("Warning!", fn + err, "Continue");
	#end
	}

	public override function setParent(parent:Dynamic) {
		interp.scriptObject = parent;
	}

	public override function onLoad() {
		@:privateAccess
		interp.execute(parser.mk(EBlock([]), 0, 0));
		if (expr != null) {
			interp.execute(expr);
			call("new", []);
		}

		#if GLOBAL_SCRIPT
		funkin.backend.scripting.GlobalScript.call("onScriptSetup", [this, "hscript"]);
		#end
	}

	public override function reload() {
		interp.allowStaticVariables = interp.allowPublicVariables = false;
		var savedVariables:Map<String, Dynamic> = [];
		for(k=>e in interp.variables) {
			if (!Reflect.isFunction(e)) {
				savedVariables[k] = e;
			}
		}
		var oldParent = interp.scriptObject;
		onCreate(path);

		for(k=>e in Script.getDefaultVariables(this))
			set(k, e);

		load();
		setParent(oldParent);

		for(k=>e in savedVariables)
			interp.variables.set(k, e);

		interp.allowStaticVariables = interp.allowPublicVariables = true;
	}

	private override function onCall(funcName:String, parameters:Array<Dynamic>):Dynamic {
		if (interp == null) return null;
		if (!interp.variables.exists(funcName)) return null;

		var func = interp.variables.get(funcName);
		if (func != null && Reflect.isFunction(func))
			return Reflect.callMethod(null, func, parameters);

		return null;
	}

	public override function get(val:String):Dynamic {
		return interp.variables.get(val);
	}

	public override function set(val:String, value:Dynamic) {
		interp.variables.set(val, value);
	}

	public override function trace(v:Dynamic) {
	var posInfo = interp.posInfos();
	Logs.traceColored([
		Logs.logText('${fileName}:${posInfo.lineNumber}: ', GREEN),
		Logs.logText(Std.isOfType(v, String) ? v : Std.string(v))
	], TRACE);
	}

	public override function setPublicMap(map:Map<String, Dynamic>) {
		this.interp.publicVariables = map;
	}
}
