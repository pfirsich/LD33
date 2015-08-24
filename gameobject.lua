
do
	local function renderFun(obj, x, y)
		love.graphics.getShader():send("damageMap", obj.damageMap)
		love.graphics.getShader():send("damage", obj.damage)

		love.graphics.setColor(obj.shade, obj.shade, obj.shade)
		love.graphics.draw(obj.drawable, x, y, 0, tileWidth / obj.drawable:getWidth(), tileHeight / obj.drawable:getHeight())
		love.graphics.setColor(255, 255, 255)
	end

	function createSprite(drawable, type, shade)
		return {
			drawable = drawable,
			type = type,
			shade = shade,
			render = renderFun,
			damageMap = damageMaps[love.math.random(1, 5)],
			damage = 0.0
		}
	end	
end