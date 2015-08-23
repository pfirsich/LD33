require "gameobject"
require "utility"

do
	local buildingGenerators = {}

	buildingGenerators["simple"] = function(buildingX, tileSet, width, height)

		local img = nil
		for y = 0, -(height-1),-1 do
			for x = 0, width-1 do
				if x == 0 then
					if y == 0 then
						img = tileSet.lb
					elseif y == -(height-1) then
						img = tileSet.lt
					else
						img = tileSet.lm
					end
				elseif x == (width-1) then
					if y == 0 then
						img = tileSet.rb
					elseif y == -(height-1) then
						img = tileSet.rt
					else
						img = tileSet.rm
					end
				else
					if y == 0 then
						if ((x == math.ceil((width - 1) / 2)) or (x == math.floor((width - 1) / 2))) then
							img = tileSet.door
						else
							img = tileSet.mb  
						end
					elseif y == -(height-1) then
						img = tileSet.mt
					else
						img = tileSet.mm
					end
				end

				world.setTileAt(buildingX + x, y - 1, createSprite(img, "building"))
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