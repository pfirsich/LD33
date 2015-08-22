do
	local addGameObjectTbl = {}

	addGameObjectTbl["building"] = function(cell, obj) 
		table.insert(cell.gameObjects.buildings, obj)
	end

	addGameObjectTbl["npc"] = function(cell, obj)
		table.insert(cell.gameObjects.npcs, obj)
	end

	local function addGameObjectFun(cell, obj)
		addGameObjectTbl[obj.type](cell, obj)
	end

	local function addGameObjectsFun(cell, objs)
		for k,v in pairs(objs) do
			cell:addGameObject(v)
		end
	end

	local function renderFun(cell)
		for k1,v1 in pairs(cell.gameObjects) do
			for k2,v2 in pairs(v1) do
				v2:render()
			end
		end
	end

	-- posX denotes the left edge of the cell in world space
	function createCell(posX)
		return 
		{
			x = posX,
			gameObjects = 
			{
				buildings = {},
				npcs = {}
			},
			addGameObject = addGameObjectFun,
			addGameObjects = addGameObjectsFun,
			render = renderFun
		}
	end

end

