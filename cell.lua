do
	tileWidth = 64
	tileHeight = 64
	cellWidth = 60

	local function setTileAtFun(cell, x, y, obj)

		row = cell.tileMap[y]
		if(row == nil) then
			cell.tileMap[y] = {}
			row = cell.tileMap[y]
		end

		row[x] = obj		
	end

	local function getTileAtFun(cell, x, y)

		if cell.tileMap[y] == nil then
			return nil
		end

		return cell.tileMap[y][x]
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
			render = renderFun,
			getTileAt = getTileAtFun,
			setTileAt = setTileAtFun
		}
	end

end

