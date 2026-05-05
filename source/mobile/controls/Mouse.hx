package mobile.controls;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.ui.FlxButton;
import flixel.math.FlxPoint;

#if mobile
import funkin.backend.system.Controls;
#end

class Call {
    public static var virtualMouse:VirtualMouse;

    public static function Mouse():Void {
        if (virtualMouse == null) {
            virtualMouse = new VirtualMouse(
                FlxG.width / 2,
                FlxG.height / 2
            );

            FlxG.state.add(virtualMouse);
        }
    }
}

class VirtualMouse extends FlxSprite {
    var lastTouch:FlxPoint;

    public var sensitivity:Float = 1.6;

    var isHovering:Bool = false;

    public function new(x:Float, y:Float) {
        super(x, y);

        loadGraphic(
            "assets/images/menus/cursor/mouse.png",
            false,
            32,
            32
        );

        scrollFactor.set();

        lastTouch = new FlxPoint();

        #if mobile
        FlxG.mouse.visible = false;
        #end
    }

    override function update(elapsed:Float):Void {
        super.update(elapsed);

        updateMovement();
        checkButtons();
    }

    function updateMovement():Void {
        for (touch in FlxG.touches.list) {

            var touchingPad:Bool = false;

            #if mobile
            if (Controls.virtualPad != null) {

                Controls.virtualPad.forEachAlive(function(btn:FlxSprite) {

                    if (touch.overlaps(btn))
                        touchingPad = true;
                });
            }
            #end

            if (touchingPad)
                continue;

            if (touch.justPressed) {

                lastTouch.set(
                    touch.screenX,
                    touch.screenY
                );
            }

            if (touch.pressed) {

                var deltaX = touch.screenX - lastTouch.x;
                var deltaY = touch.screenY - lastTouch.y;

                x += deltaX * sensitivity;
                y += deltaY * sensitivity;

                if (x < 0)
                    x = 0;

                if (y < 0)
                    y = 0;

                if (x > FlxG.width - width)
                    x = FlxG.width - width;

                if (y > FlxG.height - height)
                    y = FlxG.height - height;

                lastTouch.set(
                    touch.screenX,
                    touch.screenY
                );
            }
        }
    }

    function checkButtons():Void {

        var hovering:Bool = false;

        FlxG.state.forEachAlive(function(obj) {

            if (obj == null)
                return;

            if (Std.isOfType(obj, FlxButton)) {

                var btn:FlxButton = cast obj;

                if (overlaps(btn)) {

                    hovering = true;

                    for (touch in FlxG.touches.list) {

                        if (touch.justPressed) {

                            if (btn.onUp != null)
                                btn.onUp.callback();
                        }
                    }
                }
            }
        });

        if (hovering && !isHovering) {

            loadGraphic(
                "assets/images/menus/cursor/hover.png",
                false,
                32,
                32
            );

            isHovering = true;
        }
        else if (!hovering && isHovering) {

            loadGraphic(
                "assets/images/menus/cursor/mouse.png",
                false,
                32,
                32
            );

            isHovering = false;
        }
    }

    override function destroy():Void {

        lastTouch.put();

        super.destroy();
    }
}
