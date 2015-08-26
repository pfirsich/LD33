
do
	local function renderFun(obj, x, y)
		tileDamageShader:send("damageMap", obj.damageMap)
		tileDamageShader:send("damage", obj.damage)

		love.graphics.setColor(obj.shade, obj.shade, obj.shade, 255)
		love.graphics.draw(obj.drawable, x, y, 0, tileWidth / obj.drawable:getWidth(), tileHeight / obj.drawable:getHeight())
		love.graphics.setColor(255, 255, 255, 255)
	end

	function createSprite(drawable, type, shade)
		return {
			drawable = drawable,
			type = type,
			shade = shade,
			render = renderFun,
			damageMap = damageMaps[love.math.random(1, #damageMaps)],
			damage = 0.0 -- max: ~0.3
		}
	end	
end