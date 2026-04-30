package mobile.controls;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.util.FlxColor;
import flixel.FlxCamera;
import flixel.math.FlxPoint;
import funkin.options.Options;
import funkin.backend.assets.Paths; 

typedef HitboxCallback = {
    var callback:Void->Void;
}

class HitBox extends FlxSpriteGroup {
    public var hitboxCamera:FlxCamera;

    public var buttonLeft:HitboxButton;
    public var buttonDown:HitboxButton;
    public var buttonUp:HitboxButton;
    public var buttonRight:HitboxButton;

    public var hintLeft:HitboxButton;
    public var hintDown:HitboxButton;
    public var hintUp:HitboxButton;
    public var hintRight:HitboxButton;

    public function new(hitboxStyle:String = "Simple", hintStyle:String = "Simple") {
        super();

        var w:Int = Std.int(FlxG.width / 4);
        var h:Int = Std.int(FlxG.height);

        var hintH:Int = hintStyle == "Gradient" ? h : Std.int(FlxG.height / 17);
        var hintY:Int = hintStyle == "Gradient" ? 0 : FlxG.height - hintH;

        hitboxCamera = new FlxCamera(0, 0, FlxG.width, FlxG.height);
        hitboxCamera.bgColor = 0x00000000;
        
        buttonLeft  = new HitboxButton(0, 0, w, h, 0xFFC24B99, hitboxCamera, false);
        buttonDown  = new HitboxButton(w, 0, w, h, 0xFF00FFFF, hitboxCamera, false);
        buttonUp    = new HitboxButton(w * 2, 0, w, h, 0xFF12FA05, hitboxCamera, false);
        buttonRight = new HitboxButton(w * 3, 0, w, h, 0xFFF9393F, hitboxCamera, false);

        if (hitboxStyle == "Gradient") {
            applyGradientSafe([buttonLeft, buttonDown, buttonUp, buttonRight], w, h, false);
        }

        hintLeft  = new HitboxButton(0, hintY, w, hintH, 0xFFC24B99, hitboxCamera, true);
        hintDown  = new HitboxButton(w, hintY, w, hintH, 0xFF00FFFF, hitboxCamera, true);
        hintUp    = new HitboxButton(w * 2, hintY, w, hintH, 0xFF12FA05, hitboxCamera, true);
        hintRight = new HitboxButton(w * 3, hintY, w, hintH, 0xFFF9393F, hitboxCamera, true);

        hintLeft.parentButton = buttonLeft;
        hintDown.parentButton = buttonDown;
        hintUp.parentButton = buttonUp;
        hintRight.parentButton = buttonRight;

        if (hintStyle == "Gradient") {
            applyGradientSafe([hintLeft, hintDown, hintUp, hintRight], w, hintH, true);
        }

        for (btn in [buttonLeft, buttonDown, buttonUp, buttonRight, hintLeft, hintDown, hintUp, hintRight]) {
            add(btn);
            btn.cameras = [hitboxCamera];
            btn.scrollFactor.set(0, 0);
        }
    }

    private function applyGradientSafe(buttons:Array<HitboxButton>, width:Int, height:Int, isHint:Bool):Void {
        var path:String = isHint 
            ? 'images/game/hitbox/hint/hintgradient'
            : 'images/game/hitbox/gradient';

        var frames = Paths.getSparrowAtlas(path);

        if (frames == null) {
            trace("FAILED TO LOAD GRADIENT: " + path);
            return;
        }

        var names:Array<String> = ["left", "down", "up", "right"];

        for (i in 0...buttons.length) {
            var btn = buttons[i];

            btn.makeGraphic(1, 1, FlxColor.TRANSPARENT);

            btn.frames = frames;
            btn.animation.addByPrefix('idle', names[i], 24, false);
            btn.animation.play('idle', true);

            btn.setGraphicSize(width, height);
            btn.updateHitbox();
        }  
    }
    
    public function setupCamera():Void {
        if (!FlxG.cameras.list.contains(hitboxCamera)) {
            FlxG.cameras.add(hitboxCamera, false);
        }
    }

    override public function destroy():Void {
        super.destroy();
        if (FlxG.cameras.list.contains(hitboxCamera)) {
            FlxG.cameras.remove(hitboxCamera);
        }
    }
}

class HitboxButton extends FlxSprite {
    public var onDown:HitboxCallback = {callback: null};
    public var onUp:HitboxCallback = {callback: null};
    public var onOut:HitboxCallback = {callback: null};

    public var isPressed:Bool = false;
    private var _wasPressed:Bool = false;

    private var _assignedCamera:FlxCamera;
    private var _touchPoint:FlxPoint = new FlxPoint();

    public var isHint:Bool = false;
    public var parentButton:HitboxButton = null;

    public function new(x:Float, y:Float, width:Int, height:Int, color:FlxColor, camera:FlxCamera, isHint:Bool) {
        super(x, y);

        this.isHint = isHint;
        _assignedCamera = camera;

        makeGraphic(width, height, color);
        alpha = 0.00001;
        antialiasing = false;
    }

    override public function update(elapsed:Float) {
        _wasPressed = isPressed;
        isPressed = false;

        checkInputs();

        if (isPressed && !_wasPressed) {
            if (onDown.callback != null) onDown.callback();
        } 
        else if (!isPressed && _wasPressed) {
            if (overlapPointCheck(_touchPoint)) {
                if (onUp.callback != null) onUp.callback();
            } else {
                if (onOut.callback != null) onOut.callback();
            }
        }

        var effectivePressed:Bool = isPressed || (parentButton != null && parentButton.isPressed);

        if (isHint) {
            alpha = effectivePressed ? 0.00001 : Options.hintOpacity;
        } else {
            alpha = effectivePressed ? Options.hitboxOpacity : 0.00001;
        }

        super.update(elapsed);
    }

    private function checkInputs():Void {
        #if FLX_TOUCH
        for (touch in FlxG.touches.list) {
            if (touch.pressed || touch.justPressed) {
                touch.getWorldPosition(_assignedCamera, _touchPoint);
                if (overlapPointCheck(_touchPoint)) {
                    isPressed = true;
                    return;
                }
            }
        }
        #end

        #if FLX_MOUSE
        if (FlxG.mouse.pressed) {
            FlxG.mouse.getWorldPosition(_assignedCamera, _touchPoint);
            if (overlapPointCheck(_touchPoint)) {
                isPressed = true;
            }
        }
        #end
    }

    private function overlapPointCheck(point:FlxPoint):Bool {
        return (point.x >= x && point.x < x + width && point.y >= y && point.y < y + height);
    }

    override public function destroy():Void {
        _touchPoint = null;
        super.destroy();
    }
}
