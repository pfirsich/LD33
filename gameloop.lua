require "world"
require "city"
require "inputs"


do
	gameloop = {}

	function gameloop.enter()
		
		city.setBuildingGenerationProperties("simple", {
			probability = 1.0,
			minWidth = 192, maxWidth = 512,
			minHeight = 256, maxHeight = 512 * 3
		})
		world.addGameObjects(city.generateNextCell(1))
		world.addGameObjects(city.generateNextCell(1))
		world.addGameObjects(city.generateNextCell(1))
		world.addGameObjects(city.generateNextCell(-1))
		world.addGameObjects(city.generateNextCell(-1))
		world.addGameObjects(city.generateNextCell(-1))

		
		-- change this later
		--newPlayer("Test", newKeyboardController("up", "down", "left", "right", "a"))
		newPlayer("Test", newGamepadController(love.joystick.getJoysticks()[1]))

		camera.targetY = -400	
	end 

	function gameloop.update()
		for i = 1, #players do 
			players[i].update()
		end 

		camera.targetX = players[1].position[1] + players[1].width/2
		camera.targetY = players[1].position[2] + players[1].height/2
		camera.update()
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