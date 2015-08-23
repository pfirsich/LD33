require "gameobject"
require "utility"

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

		local verticalWindowSizes = shuffleList({1, 2, 3})
		local horizontalWindowSizes = shuffleList({1, 2, 3})

		local innerMarginX = (w - outerMargin * 2) % 2 == 0 and 2 or 1
		local innerMarginY = (h - outerMargin * 2) % 2 == 0 and 2 or 1
		
		local windowWidth = 0
		local windowHeight = 0

		-- Find a fitting window size
		for k,v in ipairs(horizontalWindowSizes) do
			local n = ((w - outerMargin * 2) + innerMarginX) / (v + innerMarginX)
			if math.abs(n - math.floor(n + 0.5)) < 1e-3 then
				windowWidth = v
			end
		end
		for k,v in ipairs(verticalWindowSizes) do
			local n = ((h - outerMargin * 2) + innerMarginY) / (v + innerMarginY)
			if math.abs(n - math.floor(n + 0.5)) < 1e-3 then
				windowHeight = v
			end
		end

		assert(windowWidth > 0, "w=" .. (w - 2) .. ", innerMarginX=" .. innerMarginX)
		assert(windowWidth > 0, "h=" .. (h - 2) .. ", innerMarginY=" .. innerMarginY)

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