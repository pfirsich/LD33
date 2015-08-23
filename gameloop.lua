require "world"
require "city"
require "inputs"


do
	gameloop = {}

	local upController = watchBinaryInput(keyboardCallback("up"))
	local downController = watchBinaryInput(keyboardCallback("down"))
	local leftController = watchBinaryInput(keyboardCallback("left"))
	local rightController = watchBinaryInput(keyboardCallback("right"))

	function gameloop.enter()
		
		city.setBuildingGenerationProperties("simple", {
			probability = 1.0,
			minWidth = 320, maxWidth = 640,
			minHeight = 640, maxHeight = 2048
		})
		world.addGameObjects(city.generateNextCell(1))
		world.addGameObjects(city.generateNextCell(1))
		world.addGameObjects(city.generateNextCell(1))
		world.addGameObjects(city.generateNextCell(-1))
		world.addGameObjects(city.generateNextCell(-1))
		world.addGameObjects(city.generateNextCell(-1))

		camera.targetY = -400	
	end 

	function gameloop.update()
		camera.update()

		if(upController().down) then camera.targetY = camera.y - 109 end
		if(downController().down) then camera.targetY = camera.y + 100 end
		if(leftController().down) then camera.targetX = camera.x - 100 end
		if(rightController().down) then camera.targetX = camera.x + 100 end
	end 

	function gameloop.draw()
		camera.push()
		world.render()
		camera.pop()
	end 
end