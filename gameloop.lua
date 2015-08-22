require "world"
require "building_gen"


do
	gameloop = {}

	function gameloop.enter()
		building = generateBuilding("simple", 0, 6, 10)
		world.addGameObjects(building)
	end 

	function gameloop.update()

	end 

	function gameloop.draw()
		world.render()
	end 
end