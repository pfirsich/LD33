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

	local function pixelToTileCoordinatesFun(x, y)
		local tileX = math.floor(x / tileWidth)
		local tileY = math.floor(y / tileHeight)

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

		local tileX = math.floor(x / tileWidth)
		local tileY = math.floor(y / tileHeight)
	
		if cell.tileMap[tileY] == nil then
			return nil
		end

		return cell.tileMap[tileY][tileX]
	end

	local function renderFun(cell)
 		for k1,v1 in pairs(cell.tileMap) do
			for k2,v2 in pairs(v1) do
				local x = k2 * tileWidth
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
			setTileAt = setTileAtFun
		}
	end

end

