require "gameobject"

do
	local buildingGenerators = {}

	local function createBuildingTile(img, x, y)
		return createSprite(img, x, y, "building")
	end

	buildingGenerators["simple"] = function(buildingX, width, height)
		local buildingObjects = {}

		-- Allowed size in tiles
		w = math.floor(width / simpleWall:getWidth())
		h = math.floor(height / simpleWall:getHeight())

		local outerMargin = 1
		local windowWidth = math.min(math.floor(math.sqrt(w - 2 * outerMargin) * 0.8), 3)
		local windowHeight = math.min(math.floor(math.sqrt(h - 2 * outerMargin) * 0.8), 4)
		local numWindowsX = math.floor((w - 2 * outerMargin) / (1.5 * windowWidth)) 
		local numWindowsY = math.floor((h - 2 * outerMargin) / (1.5 * windowHeight))
		local innerMarginX = numWindowsX >= 1 and math.floor((w - 2 * outerMargin - windowWidth * numWindowsX) / (numWindowsX - 1)) or 0
		local innerMarginY = numWindowsY >= 1 and math.floor((h - 2 * outerMargin - windowHeight * numWindowsY) / (numWindowsY - 1)) or 0

		for y = 0, h-1 do
			for x = 0, w-1 do
				-- Let every other column on every other row be a window, but only inside the
				-- outer border of the building
				if (x >= outerMargin) and (x < (w - outerMargin)) and (y >= outerMargin) and (y < (h - outerMargin)) and
					((x - outerMargin) % (windowWidth + innerMarginX) < windowWidth) and ((y - outerMargin) % (windowHeight + innerMarginY) < windowHeight) then
					img = simpleWindow

				-- Let the center cell in the bottom row be a door
				elseif (y == 0) and ((x == math.ceil((w - 1) / 2)) or (x == math.floor((w - 1) / 2))) then
					img = simpleDoor

				-- All other tiles are walls
				else
					img = simpleWall
				end

				table.insert(buildingObjects, createBuildingTile(img, simpleWall:getWidth() * x + buildingX, -simpleWall:getHeight() * (y + 1)))
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