require "cell"

do
	world = { 
		cells = {} 
	}


	function world.render()
		love.graphics.setShader(tileDamageShader)
		for k,v in pairs(world.cells) do
			v:render()
		end
		love.graphics.setShader()
	end

	function world.setTileAt(x, y, obj)
		local cell = world.getCell(x)
		cell:setTileAt(x, y, obj)		
	end

	function world.pixelToTileCoordinates(x, y)
		local tileX = math.floor(x / tileWidth)
		local tileY = math.floor(y / tileHeight)

		return tileX, tileY
	end

	function world.getTileAt(x, y)
		local cell = world.getCell(x)
		return cell:getTileAt(x, y)
	end

	function world.cellExists(x, offset)
		local idx = math.floor(x / cellWidth)
		local cell = world.cells[idx + offset]
		return cell ~= nil
	end

	function world.getCell(x)
		local idx = math.floor(x / cellWidth)
		local cell = world.cells[idx]
		if cell == nil then
			cell = createCell(idx * cellWidth)
			world.cells[idx] = cell
		end

		return cell
	end
end
