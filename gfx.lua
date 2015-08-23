function initGFX()
	simpleWall = love.graphics.newImage("gfx/simplewall.png")
	simpleWindow = love.graphics.newImage("gfx/simplewindow.png")
	simpleDoor = love.graphics.newImage("gfx/simpledoor.png")

	buildingTileSets = {

		{
			lb = love.graphics.newImage("gfx/building_b/lb.png"),
			lm = love.graphics.newImage("gfx/building_b/lm.png"),
			lt = love.graphics.newImage("gfx/building_b/lt.png"),
			mb = love.graphics.newImage("gfx/building_b/mb.png"),
			mm = love.graphics.newImage("gfx/building_b/mm.png"),
			mt = love.graphics.newImage("gfx/building_b/mt.png"),
			rb = love.graphics.newImage("gfx/building_b/rb.png"),
			rm = love.graphics.newImage("gfx/building_b/rm.png"),
			rt = love.graphics.newImage("gfx/building_b/rt.png"),
			door = love.graphics.newImage("gfx/building_b/door.png")
		},

		{
			lb = love.graphics.newImage("gfx/building_c/lb.png"),
			lm = love.graphics.newImage("gfx/building_c/lm.png"),
			lt = love.graphics.newImage("gfx/building_c/lt.png"),
			mb = love.graphics.newImage("gfx/building_c/mb.png"),
			mm = love.graphics.newImage("gfx/building_c/mm.png"),
			mt = love.graphics.newImage("gfx/building_c/mt.png"),
			rb = love.graphics.newImage("gfx/building_c/rb.png"),
			rm = love.graphics.newImage("gfx/building_c/rm.png"),
			rt = love.graphics.newImage("gfx/building_c/rt.png"),
			door = love.graphics.newImage("gfx/building_c/door.png")
		}	
	}

end 

function drawGame() 

end