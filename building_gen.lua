require "gameobject"

do
	local buildingGenerators = {}

	local function createBuildingTile(img, x, y)
		return createGameObject(img, x, y, "building")
	end

	buildingGenerators["simple"] = function(posX, width, height)
		local buildingObjects = {}
		for y = 0, height-1 do
			for x = 0, width-1 do
				-- Let every other column on every other row be a window
				if (x > 0) and (x < (width-1)) and (y > 0) and (y < (height-1)) and ((y - 1) % 2 == 0) and ((x - 1) % 2 == 0) then
					img = simpleWindow

				-- Let the center cell in the bottom row be a door
				elseif (y == (height-1)) and ((x == math.ceil((width - 1) / 2)) or (x == math.floor((width - 1) / 2))) then
					img = simpleDoor

				-- All other tiles are walls
				else
					img = simpleWall
				end

				table.insert(buildingObjects, createBuildingTile(img, img:getWidth() * (posX + x), img:getHeight() * y))
			end
		end

		return buildingObjects
	end

	-- Generates a list of building-type GameObjects
	-- x denotes the left edge of the building
	function generateBuilding(type, x, width, height)
		return buildingGenerators[type](x, width, height)
	end

end