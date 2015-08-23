require "gameobject"
require "utility"

do
	local buildingGenerators = {}

	buildingGenerators["simple"] = function(buildingX, tileSet, width, height)

		baseShade = love.math.random(150, 240)

		local img = nil
		local type = nil
		for y = 0, -(height-1),-1 do
			for x = 0, width-1 do
				if x == 0 then
					if y == 0 then
						img = tileSet.lb
						type = "building_lb"
					elseif y == -(height-1) then
						img = tileSet.lt
						type = "building_lt"
					else
						img = tileSet.lm
						type = "building_lm"
					end
				elseif x == (width-1) then
					if y == 0 then
						img = tileSet.rb
						type = "building_rb"
					elseif y == -(height-1) then
						img = tileSet.rt
						type = "building_rt"
					else
						img = tileSet.rm
						type = "building_rm"
					end
				else
					if y == 0 then
						if ((x == math.ceil((width - 1) / 2)) or (x == math.floor((width - 1) / 2))) then
							img = tileSet.door
							type = "building_door"
						else
							img = tileSet.mb  
							type = "building_mb"
						end
					elseif y == -(height-1) then
						img = tileSet.mt
						type = "building_mt"
					else
						img = tileSet.mm
						type = "building_mm"
					end
				end

				world.setTileAt(buildingX + x, y - 1, createSprite(img, type, baseShade + love.math.random(0, 10)))
			end
		end
	end

	-- Generates a list of building-type GameObjects
	-- x denotes the left edge of the building
	-- width and height denote the maximal allowed dimensions in pixels
	function generateBuilding(type,tileSet, x, width, height)
		buildingGenerators[type](x, tileSet, width, height)
	end

end