package funkin.options.categories;

import flixel.FlxG;
import funkin.options.Options;
import funkin.options.type.Checkbox;
import funkin.options.type.SliderOption;
/**
public static var hitboxOpacity:Float = 0.15;
public static var hitboxHints:Float = 0.25;
public static var pauseButton:Bool = true;
public static var hitboxStyle:String = "Simple";
public static var hintStyle:String = "Simple";
**/
class AndroidOptions extends TreeMenuScreen {

    public function new() {
        super('optionsTree.android-name', 'optionsTree.android-desc', '');

        add(new Checkbox(
            getNameID('pauseButton'),
            getDescID('pauseButton'),
            'pauseButton'
        ));

        add(new ArrayOption(
            getNameID('hintStyle'),
            getDescID('hintStyle'),
            ['Simple', 'Gradient'],
            ['Simple', 'Gradient'],
            'hinrStyle'
        ));

        add(new ArrayOption(
            getNameID('hitboxStyle'),
            getDescID('hitboxStyle'),
            ['Simple', 'Gradient'],
            ['Simple', 'Gradient'],
            'hitboxStyle'
        ));

        add(new SliderOption(
            getNameID('hintOpacity'),
            getDescID('hintOpacity'),
            0,
            1,
            0.05,
            2,
            'hintOpacity'
        ));

        add(new SliderOption(
            getNameID('hitboxOpacity'),
            getDescID('hitboxOpacity'),
            0,
            1,
            0.05,
            2,
            'hitboxOpacity'
        ));
    }
}
