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

		-- world.addGameObjects(city.generateNextCell(1))
		-- world.addGameObjects(city.generateNextCell(1))
		-- world.addGameObjects(city.generateNextCell(1))
		-- world.addGameObjects(city.generateNextCell(-1))
		-- world.addGameObjects(city.generateNextCell(-1))
		-- world.addGameObjects(city.generateNextCell(-1))


		for y = -1,-10,-1 do
			for x = 0,120 do
				if x % 2 == 0 and y % 2 == 0 then
					world.setTileAt(x, y, createSprite(simpleWindow, "building"))
				else
					world.setTileAt(x, y, createSprite(simpleWall, "building"))
				end
			end
		end

		-- change this later
		--newPlayer("Test", newKeyboardController("up", "down", "left", "right", "a"))
		if love.joystick.getJoystickCount() > 0 then 
			newPlayer("Test", newGamepadController(love.joystick.getJoysticks()[1]))
		else 
			newPlayer("Test", newKeyboardController("up", "down", "left", "right", "a"))
		end

		camera.targetY = -400	
	end 

	function gameloop.update()
		for i = 1, #players do 
			players[i].update()
		end 

		camera.targetX = players[1].position[1] + players[1].width/2
		camera.targetY = players[1].position[2] + players[1].height/2
		camera.update()

		local tile = world.getTileAt(players[1].position[1], players[1].position[2] - 300)
		if tile ~= nil then
			--print("Tile above player: " .. tile.type)
		else
			--print("No tile above player")
		end
	end 

	function gameloop.draw()
		camera.push()
		
		world.render()

		for i = 1, #players do 
			players[i].draw()
		end 

		camera.pop()
	end 
end