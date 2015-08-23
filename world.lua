require "cell"

do
	world = { 
		cells = {} 
	}

	function world.addGameObject(obj)
		local cell = world.getCell(obj.x)
		cell:addGameObject(obj)
	end

	function world.addGameObjects(objs)
		for k,v in pairs(objs) do
			world.addGameObject(v)
		end
	end

	function world.render()
		for k,v in pairs(world.cells) do
			v:render()
		end
	end

	function world.setTileAt(x, y, obj)
		local cell = world.getCell(x)
		cell:setTileAt(x, y, obj)		
	end

	-- 
	function world.getTileAt(x, y)
		local cell = world.getCell(math.floor(x / tileWidth))
		return cell:getTileAt(x, y)
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
