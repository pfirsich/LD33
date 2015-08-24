function initGFX()
	bgImage = love.graphics.newImage("gfx/bg.png")
	streetTile = love.graphics.newImage("gfx/street_tile.png")

	tileDamageShader = love.graphics.newShader([[
	uniform Image damageMap;
	uniform float damage = 0.0;

	vec4 effect(vec4 color, Image texture, vec2 texCoords, vec2 screenCoords) {
		vec4 c = color * Texel(texture, texCoords);
		c.a = mix(1.0, Texel(damageMap, texCoords).r, damage);
		return c;
	}
	]])

	damageMaps = {}
	for i = 1, 5 do 
		damageMaps[i] = love.graphics.newImage("gfx/dmg_map" .. tostring(i) .. ".png")
		print(damageMaps[i])
	end

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
