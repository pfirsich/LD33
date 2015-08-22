require "gameobject"

do
	local buildingGenerators = {}

	local function createBuildingTile(img, x, y)
		return createGameObject(img, x, y, "building")
	end

	buildingGenerators["simple"] = function(buildingX, width, height)
		local buildingObjects = {}

		-- Allowed size in tiles
		w = math.floor(width / simpleWall:getWidth())
		h = math.floor(height / simpleWall:getHeight())

		for y = 0, h-1 do
			for x = 0, w-1 do
				-- Let every other column on every other row be a window, but only inside the
				-- outer border of the building
				if (x > 0) and (x < (w-1)) and (y > 0) and (y < (h-1)) and ((y - 1) % 2 == 0) and ((x - 1) % 2 == 0) then
					img = simpleWindow

				-- Let the center cell in the bottom row be a door
				elseif (y == 0) and ((x == math.ceil((w - 1) / 2)) or (x == math.floor((w - 1) / 2))) then
					img = simpleDoor

				-- All other tiles are walls
				else
					img = simpleWall
				end

				table.insert(buildingObjects, createBuildingTile(img, img:getWidth() * x + buildingX, -img:getHeight() * (y + 1)))
			end
		end

		return buildingObjects
	end

	-- Generates a list of building-type GameObjects
	-- x denotes the left edge of the building
	-- width and height denote the maximal allowed dimensions in pixels
	function generateBuilding(type, x, width, height)
		return buildingGenerators[type](x, width, height)
	end

end