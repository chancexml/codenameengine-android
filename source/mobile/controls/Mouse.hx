package mobile.controls;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.ui.FlxButton;
import flixel.group.FlxGroup;
import flixel.FlxObject;
#if mobile
import funkin.backend.system.Controls;
import funkin.options.keybinds.KeybindsOptions;
import mobile.controls.VirtualPad;
import mobile.controls.FlxButton;
import mobile.utils.ButtonHelper;
#end

class Call {
    public static var virtualMouse:VirtualMouse;

    public static function Mouse():Void {
        if (virtualMouse == null) {
            virtualMouse = new VirtualMouse(FlxG.width / 2, FlxG.height / 2);
            FlxG.state.add(virtualMouse);
        } else {
            FlxG.state.remove(virtualMouse);
            FlxG.state.add(virtualMouse);
        }
    }
}

class VirtualMouse extends FlxSprite {
    var lastTouch:FlxPoint;
    var isHovering:Bool = false;
    public var sensitivity:Float = 1.6; 

    public function new(x:Float, y:Float) {
        super(x, y);
        loadGraphic("assets/images/menus/cursor/mouse.png", false, 32, 32);
        scrollFactor.set(0, 0); 
        lastTouch = new FlxPoint();
        
        #if mobile
        FlxG.mouse.visible = false; 
        #end
    }

    override public function update(elapsed:Float):Void {
        updateMovement();
        
        #if mobile
        FlxG.mouse.x = this.x;
        FlxG.mouse.y = this.y;
        #end

        autoDetectHover();
        super.update(elapsed);
    }

    private function updateMovement():Void {
        for (touch in FlxG.touches.list) {
            var touchingPad:Bool = false;
            
            if (Controls.virtualPad != null) {
                Controls.virtualPad.forEachAlive(function(btn:FlxSprite) {
                    if (touch.overlaps(btn)) touchingPad = true;
                });
            }

            if (touchingPad) continue;

            if (touch.justPressed) {
                lastTouch.set(touch.screenX, touch.screenY);
            } 
            else if (touch.pressed) {
                var deltaX = touch.screenX - lastTouch.x;
                var deltaY = touch.screenY - lastTouch.y;

                this.x += deltaX * sensitivity;
                this.y += deltaY * sensitivity;

                if (this.x < 0) this.x = 0;
                if (this.x > FlxG.width - width) this.x = FlxG.width - width;
                if (this.y < 0) this.y = 0;
                if (this.y > FlxG.height - height) this.y = FlxG.height - height;

                lastTouch.set(touch.screenX, touch.screenY);
                break; 
            }
        }
    }

    private function autoDetectHover():Void {
        var foundClickable:Bool = false;

        function checkMember(member:flixel.FlxBasic) {
            if (foundClickable || member == this) return; 

            if (Std.isOfType(member, FlxGroup)) {
                cast(member, FlxGroup).forEachAlive(checkMember);
            } 
            else if (Std.isOfType(member, FlxObject)) {
                var obj:FlxObject = cast member;
                var isPadButton:Bool = false;
                
                if (Controls.virtualPad != null) {
                    Controls.virtualPad.forEachAlive(function(btn:FlxSprite) {
                        if (obj == btn) isPadButton = true;
                    });
                }

                if (!isPadButton) {
                    var isActuallyClickable = Std.isOfType(obj, FlxButton) || (Reflect.hasField(obj, "inputEnabled") && Reflect.field(obj, "inputEnabled") == true);
                    if (isActuallyClickable && FlxG.mouse.overlaps(obj)) {
                        foundClickable = true;
                    }
                }
            }
        }

        FlxG.state.forEachAlive(checkMember);

        if (foundClickable && !isHovering) {
            loadGraphic("assets/images/menus/cursor/hover.png", false, 32, 32);
            isHovering = true;
        } else if (!foundClickable && isHovering) {
            loadGraphic("assets/images/menus/cursor/mouse.png", false, 32, 32);
            isHovering = false;
        }
    }
}
