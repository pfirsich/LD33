require "world"
require "city"
require "inputs"


do
	gameloop = {}

	function gameloop.enter()
		
		city.setBuildingGenerationProperties("simple", {
			probability = 1.0,
			minWidth = 5, maxWidth = 10,
			minHeight = 8, maxHeight = 15
		})

		city.generateNextCell(-1)
		city.generateNextCell(1)

		-- change this later
		--newPlayer("Test", newKeyboardController("up", "down", "left", "right", "a"))
		if love.joystick.getJoystickCount() > 0 then 
			newPlayer("Test", newGamepadController(love.joystick.getJoysticks()[1]))
		else 
			newPlayer("Test", newKeyboardController("up", "down", "left", "right", "a", "s"))
		end

		camera.targetY = -400	
	end 

	function gameloop.update()
		for i = 1, #players do 
			players[i].update()
		end 

		-- Automatically generate new cells if there is no cell yet next to the current player's cell
		local playerTilePosX = world.pixelToTileCoordinates(players[1].position[1], 0)
		for i = -1, 1, 2 do
			if not world.cellExists(playerTilePosX, i) then
				city.generateNextCell(i)
			end
		end

		local velocityCameraTranslationX = 0.6
		local velocityCameraTranslationY = 0.3
		camera.targetX = players[1].position[1] + players[1].width/2 + players[1].velocity[1] * velocityCameraTranslationX
		camera.targetY = players[1].position[2] + players[1].height/2 + players[1].velocity[2] * velocityCameraTranslationY

		local standingZoom = 1.5
		local minZoom = 1.0
		local zoomVelFactor = 0.005
		camera.targetZoom = minZoom + math.exp(-zoomVelFactor * vnorm(players[1].velocity)) * (standingZoom - minZoom)

		local maxTargetY = players[1].height/2 - love.window.getHeight()/2 / camera.scale
		camera.targetY = math.min(maxTargetY, camera.targetY)
		camera.update()
	end 

	function gameloop.draw()
		love.graphics.setColor(255, 255, 255, 255)
		love.graphics.draw(bgImage, 0, 0, 0, love.window.getWidth() / bgImage:getWidth(), love.window.getHeight() / bgImage:getHeight())
		
		camera.push()
		
		world.render()

		for i = 1, #players do 
			players[i].draw()
		end 

		camera.pop()

		love.graphics.setColor(100, 100, 100, 255)
		-- second param: y = 0 in screen space
		love.graphics.rectangle("fill", 0, love.window.getHeight()/2 - math.floor(camera.y * camera.scale), love.window.getWidth(), love.window.getHeight())
	end 
end