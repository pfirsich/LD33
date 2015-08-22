require "building_gen"

do
	local avgDistance = 352

	-- Below this threshold in distance between buildings the distance is reduced to 0
	-- and the buildings are snapped together
	local lowDistanceThreshold = 64

	city = { 
		leftBorder = 0, 
		rightBorder = 0,
		buildingGenerationProperties = {}
			-- ["buildingname"] = 
			-- {
			-- probability (sum of all probabilities has to be 1)
			-- minWidth, maxWidth
			-- minHeight, maxHeight
			--}
	}

	local function chooseRandomBuilding()
		local rnd = love.math.random()
		local probabilitySum = 0
		for k,v in pairs(city.buildingGenerationProperties) do
			probabilitySum = probabilitySum + v.probability
			if rnd <= probabilitySum then
				return k
			end
		end

		-- The result should be found in the loop, otherwise the probabilities
		-- don't add up to 1 or there are no building properties
		assert(false)
	end

	-- x denotes the left edge of the cell
	function city.generateCellBuildings(x)	

		local generatedBuildings = {}

		local buildingX = x

		while buildingX < (x + cellWidth) do
			local buildingType = chooseRandomBuilding()
			local generationProperties = city.buildingGenerationProperties[buildingType]
			local w = love.math.random(generationProperties.minWidth, generationProperties.maxWidth)
			local h = love.math.random(generationProperties.minHeight, generationProperties.maxHeight)
			local newBuilding = generateBuilding(buildingType, buildingX, w, h)

			-- Break prematurely if new building crosses over cell boundary
			if (buildingX + w) > (x + cellWidth) then
				break
			end

			-- Merge new building game objects into generatedBuildings
			for k,v in ipairs(newBuilding) do
				table.insert(generatedBuildings, v)
			end

			-- Advance to the position next to the new building and insert 
			-- randomly chosen amount of space next to it
			local space = math.log(1 - love.math.random()) * (-avgDistance)
			if(space < lowDistanceThreshold) then space = 0 end
			buildingX = buildingX + w + space
		end

		return generatedBuildings
	end

	function city.setBuildingGenerationProperties(buildingType, generationProperties)
		city.buildingGenerationProperties[buildingType] = generationProperties
	end

	function city.generateNextCell(direction)
		if direction < 0 then
			city.leftBorder = city.leftBorder - cellWidth
			return city.generateCellBuildings(city.leftBorder)
		else
			local buildings = city.generateCellBuildings(city.rightBorder)
			city.rightBorder = city.rightBorder + cellWidth
			return buildings
		end
	end


end