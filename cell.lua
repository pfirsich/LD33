do
	tileWidth = 64
	tileHeight = 64
	cellWidth = 30

	local function addGameObjectFun(cell, obj)
		
		local tileX, tileY = cell:pixelToTileCoordinates(obj.x, obj.y)

		--print("Adding tile at " .. tileX,tileY)

		row = cell.tileMap[tileY]
		if(row == nil) then
			cell.tileMap[tileY] = {}
			row = cell.tileMap[tileY]
		end

		row[tileX] = obj
	end

	local function addGameObjectsFun(cell, objs)
		for k,v in pairs(objs) do
			cell:addGameObject(v)
		end
	end

	local function pixelToTileCoordinatesFun(cell, x, y)
		local tileX = math.floor((x - cell.x) / tileWidth)
		local tileY = math.floor(y / tileWidth)

		return tileX, tileY
	end

	local function setTileAtFun(cell, x, y, obj)

		row = cell.tileMap[y]
		if(row == nil) then
			cell.tileMap[y] = {}
			row = cell.tileMap[y]
		end

		row[x] = obj		
	end

	local function getTileAtFun(cell, x, y)

		local tileX, tileY = cell:pixelToTileCoordinates(x, y)

		if cell.tileMap[tileY] == nil then
			return nil
		end

		return cell.tileMap[tileY][tileX]
	end

	local function renderFun(cell)
		--print("Rendering cell at " .. cell.x)
		for k1,v1 in ipairs(cell.tileMap) do
			for k2,v2 in ipairs(v1) do
				local x = ((cell.x + k2) * tileWidth)
				local y = k1 * tileHeight
				v2:render(x, y)
			end
		end
	end

	-- posX denotes the left edge of the cell in world space
	function createCell(posX)
		return 
		{
			x = posX,
			tileMap = {},
			addGameObject = addGameObjectFun,
			addGameObjects = addGameObjectsFun,
			render = renderFun,
			getTileAt = getTileAtFun,
			pixelToTileCoordinates = pixelToTileCoordinatesFun,
			setTileAt = setTileAtFun
		}
	end

end

