
do
	local function renderFun(obj, x, y)
		love.graphics.draw(obj.drawable, x, y, 0, tileWidth / obj.drawable:getWidth(), tileHeight / obj.drawable:getHeight())
	end

	function createSprite(drawable, type)
		return {
			drawable = drawable,
			type = type,
			render = renderFun
		}
	end	
end