do
	-- Controllers

	function newKeyboardController(up, down, left, right, jump)
		local ctrl = {}
		ctrl.moveX = getFloatInputFromTwoBinaryInputs(keyboardCallback(right), keyboardCallback(left))
		ctrl.moveY = getFloatInputFromTwoBinaryInputs(keyboardCallback(down), keyboardCallback(up))
		ctrl.jump = watchBinaryInput(keyboardCallback(jump))
		return ctrl 
	end 

	function newGamepadController(joystick)
		local ctrl = {}
		ctrl.moveX = getJoystickAxisCallback(joystick, "leftx")
		ctrl.moveY = getJoystickAxisCallback(joystick, "lefty")
		ctrl.jump = watchBinaryInput(joystickButtonCallback(joystick, "a"))
		return ctrl
	end 

	----------------------------------------------------------------------------------
	----------------------------------------------------------------------------------

	local inputs = {}
	
	function keyboardCallback(key)
		return function() return love.keyboard.isDown(key) end
	end
	
	function mouseButtonCallback(button)
		return function() return love.mouse.isDown(button) end
	end

	function joystickButtonCallback(joystick, button)
		return function() return joystick:isGamepadDown(button) end
	end

	function getFloatInputFromTwoBinaryInputs(funA_plus, funB_minus, factor)
		if factor == nil then factor = 1.0 end
		return function() return ((funA_plus() and 1.0 or 0.0) - (funB_minus() and 1.0 or 0.0)) * factor end
	end

	function getJoystickAxisCallback(joystick, axisID, factor)
		if factor == nil then factor = 1.0 end
		return function() return joystick:getGamepadAxis(axisID) * factor end
	end

	function combineCallbacks(A, B)
		return function() return A() and B() end
	end

	function combineCallbacksOR(A, B)
		return function() return A() or B() end
	end

	function watchBinaryInput(fun) 
		table.insert(inputs, {func = fun, pressed = false, down = false, released = false, lastdown = false})
		local index = #inputs
		return function() return inputs[index] end
	end

	function updateWatchedInputs()
		for i = 1, #inputs do
			inputs[i].lastdown = inputs[i].down
			inputs[i].down = inputs[i].func()
			
			inputs[i].pressed = false
			inputs[i].released = false
			if inputs[i].down then
				if not inputs[i].lastdown then inputs[i].pressed = true end
			else
				if inputs[i].lastdown then inputs[i].released = true end
			end
		end
	end
end