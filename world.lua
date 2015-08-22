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

	-- x can be any x-coordinate in world space
	function world.getCell(x)
		local idx = math.floor(x / cellWidth)
		local cell = world.cells[idx]
		if cell == nil then
			cell = createCell(idx)
			world.cells[idx] = cell
		end

		return cell
	end
end
