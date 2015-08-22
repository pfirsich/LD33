
do
	local function renderFun(obj)
		love.graphics.draw(obj.drawable, obj.x, obj.y)
	end

	function createGameObject(drawable, x, y, type)
		return {
			drawable = drawable,
			x = x,
			y = y,
			type = type,
			render = renderFun
		}
	end	
end