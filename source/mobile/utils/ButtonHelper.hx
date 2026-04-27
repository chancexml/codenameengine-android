package mobile.utils;

#if mobile
import mobile.controls.VirtualPad;
import funkin.options.Options;
#end

/**
 * Helper class for creating and configuring virtual pads on mobile.
 * Provides utilities for binding controls and managing button mappings.
 */
class ButtonHelper
{
	#if mobile
	/**
	 * Create a new VirtualPad with specified D-pad and action button modes.
	 * 
	 * @param parent The parent object to add the virtual pad to (e.g., a FlxState or FlxGroup)
	 * @param dpad The D-pad mode (FlxDPadMode enum value like FULL, UP_DOWN, etc.)
	 * @param action The action button mode (FlxActionMode enum value like A_B, A_B_C, etc.)
	 * @return The created VirtualPad instance
	 * 
	 * Example: var pad = ButtonHelper.create(this, FULL, A_B);
	 */
	public static function create(parent:Dynamic, dpad:Dynamic, action:Dynamic):VirtualPad
	{
		var vpad = new VirtualPad(dpad, action);
		if (parent != null)
			parent.add(vpad);
		return vpad;
	}

	/**
	 * Bind virtual pad buttons to control actions.
	 * Maps D-pad and action buttons to named controls that the input system recognizes.
	 * 
	 * @param vpad The VirtualPad instance to configure
	 * @param dpadBindings Array of 4 direction control names: [up, down, left, right]
	 *                      Example: ['ui_up', 'ui_down', 'ui_left', 'ui_right']
	 * @param actionBindings Array of action button control names: [first, second, third, fourth, fifth]
	 *                        Example: ['accept', 'back', 'pause', 'reset', 'switchmod']
	 * @return The VirtualPad instance (for chaining)
	 * 
	 * Example: 
	 * ```
	 * ButtonHelper.bind(vpad,
	 *     ['ui_up', 'ui_down', 'ui_left', 'ui_right'],
	 *     ['accept', 'back']
	 * );
	 * ```
	 */
	public static function bind(vpad:VirtualPad, dpadBindings:Array<String>, actionBindings:Array<String>):VirtualPad
	{
		if (vpad == null)
			return vpad;

		Options.controlButtons.clear();

		// ---- D-PAD BINDING ----
		bindDPadButtons(vpad, dpadBindings);

		// ---- ACTION BUTTONS BINDING ----
		bindActionButtons(vpad, actionBindings);

		return vpad;
	}

	/**
	 * Internal helper to bind D-pad buttons to named controls.
	 * Handles mapping and validation of direction controls.
	 * 
	 * @param vpad The VirtualPad instance
	 * @param dpadBindings Array of control names for [up, down, left, right]
	 */
	private static function bindDPadButtons(vpad:VirtualPad, dpadBindings:Array<String>):Void
	{
		if (dpadBindings == null || dpadBindings.length == 0)
			return;

		var upBinding = dpadBindings.length > 0 ? dpadBindings[0] : null;
		var downBinding = dpadBindings.length > 1 ? dpadBindings[1] : null;
		var leftBinding = dpadBindings.length > 2 ? dpadBindings[2] : null;
		var rightBinding = dpadBindings.length > 3 ? dpadBindings[3] : null;

		// Register buttons in the options system
		if (upBinding != null && vpad.buttonUp != null)
			Options.controlButtons.set(upBinding.toUpperCase(), vpad.buttonUp);
		if (downBinding != null && vpad.buttonDown != null)
			Options.controlButtons.set(downBinding.toUpperCase(), vpad.buttonDown);
		if (leftBinding != null && vpad.buttonLeft != null)
			Options.controlButtons.set(leftBinding.toUpperCase(), vpad.buttonLeft);
		if (rightBinding != null && vpad.buttonRight != null)
			Options.controlButtons.set(rightBinding.toUpperCase(), vpad.buttonRight);

		// Bind the virtual pad D-pad
		vpad.bindDPad(upBinding, downBinding, leftBinding, rightBinding);
	}

	/**
	 * Internal helper to bind action buttons to named controls.
	 * Handles mapping and validation of action buttons (A, B, X, Y, C).
	 * 
	 * @param vpad The VirtualPad instance
	 * @param actionBindings Array of control names for action buttons
	 */
	private static function bindActionButtons(vpad:VirtualPad, actionBindings:Array<String>):Void
	{
		if (actionBindings == null || actionBindings.length == 0)
			return;

		// Register buttons in the options system
		if (actionBindings.length > 0 && actionBindings[0] != null && vpad.buttonA != null)
			Options.controlButtons.set(actionBindings[0].toUpperCase(), vpad.buttonA);
		if (actionBindings.length > 1 && actionBindings[1] != null && vpad.buttonB != null)
			Options.controlButtons.set(actionBindings[1].toUpperCase(), vpad.buttonB);
		if (actionBindings.length > 2 && actionBindings[2] != null && vpad.buttonX != null)
			Options.controlButtons.set(actionBindings[2].toUpperCase(), vpad.buttonX);
		if (actionBindings.length > 3 && actionBindings[3] != null && vpad.buttonY != null)
			Options.controlButtons.set(actionBindings[3].toUpperCase(), vpad.buttonY);
		if (actionBindings.length > 4 && actionBindings[4] != null && vpad.buttonC != null)
			Options.controlButtons.set(actionBindings[4].toUpperCase(), vpad.buttonC);

		// Bind action buttons based on how many bindings were provided
		switch (actionBindings.length)
		{
			case 1:
				vpad.bindActionGroup(actionBindings[0]);
			case 2:
				vpad.bindActionGroup(actionBindings[0], actionBindings[1]);
			case 3:
				vpad.bindActionGroup(actionBindings[0], actionBindings[1], actionBindings[2]);
			case 4:
				vpad.bindActionGroup(actionBindings[0], actionBindings[1], actionBindings[2], actionBindings[3]);
			case 5:
				vpad.bindActionGroup(actionBindings[0], actionBindings[1], actionBindings[2], actionBindings[3],
					actionBindings[4]);
			default:
				// If more than 5 bindings provided, bind the first 5
				vpad.bindActionGroup(actionBindings[0], actionBindings[1], actionBindings[2], actionBindings[3],
					actionBindings[4]);
		}
	}

	/**
	 * Rebind specific D-pad direction at runtime.
	 * Useful for allowing players to customize controls.
	 * 
	 * @param vpad The VirtualPad instance
	 * @param direction The direction to rebind ('up', 'down', 'left', 'right')
	 * @param controlName The new control name to bind to
	 * @return The VirtualPad instance (for chaining)
	 */
	public static function rebindDPadDirection(vpad:VirtualPad, direction:String, controlName:String):VirtualPad
	{
		if (vpad == null || controlName == null)
			return vpad;

		switch (direction.toLowerCase())
		{
			case 'up':
				if (vpad.buttonUp != null)
					Options.controlButtons.set(controlName.toUpperCase(), vpad.buttonUp);
			case 'down':
				if (vpad.buttonDown != null)
					Options.controlButtons.set(controlName.toUpperCase(), vpad.buttonDown);
			case 'left':
				if (vpad.buttonLeft != null)
					Options.controlButtons.set(controlName.toUpperCase(), vpad.buttonLeft);
			case 'right':
				if (vpad.buttonRight != null)
					Options.controlButtons.set(controlName.toUpperCase(), vpad.buttonRight);
		}

		return vpad;
	}

	/**
	 * Rebind specific action button at runtime.
	 * Useful for allowing players to customize controls.
	 * 
	 * @param vpad The VirtualPad instance
	 * @param buttonIndex The button index (0=A, 1=B, 2=X, 3=Y, 4=C)
	 * @param controlName The new control name to bind to
	 * @return The VirtualPad instance (for chaining)
	 */
	public static function rebindActionButton(vpad:VirtualPad, buttonIndex:Int, controlName:String):VirtualPad
	{
		if (vpad == null || controlName == null)
			return vpad;

		var button = switch (buttonIndex)
		{
			case 0: vpad.buttonA;
			case 1: vpad.buttonB;
			case 2: vpad.buttonX;
			case 3: vpad.buttonY;
			case 4: vpad.buttonC;
			default: null;
		};

		if (button != null)
			Options.controlButtons.set(controlName.toUpperCase(), button);

		return vpad;
	}

	/**
	 * Get the button currently bound to a control name.
	 * 
	 * @param controlName The control name to look up
	 * @return The button object, or null if not found
	 */
	public static function getButtonByControlName(controlName:String):Dynamic
	{
		if (controlName == null)
			return null;
		return Options.controlButtons.get(controlName.toUpperCase());
	}

	/**
	 * Clear all button bindings and reset the options.
	 * 
	 * @param vpad The VirtualPad instance to reset
	 * @return The VirtualPad instance (for chaining)
	 */
	public static function clearBindings(vpad:VirtualPad):VirtualPad
	{
		if (vpad == null)
			return vpad;
		Options.controlButtons.clear();
		return vpad;
	}
	#end
}
