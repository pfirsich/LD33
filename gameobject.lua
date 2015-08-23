
do
	local function renderFun(obj, x, y)
		love.graphics.draw(obj.drawable, x, y)
	end

	function createSprite(drawable, type)
		return {
			drawable = drawable,
			type = type,
			render = renderFun
		}
	end	
end