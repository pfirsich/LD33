require "world"
require "city"
require "inputs"


do
	gameloop = {}

	function gameloop.enter()
		city.setBuildingGenerationProperties("simple", {
			probability = 1.0,
			minWidth = 5, maxWidth = 10,
			minHeight = 8, maxHeight = 15
		})

		city.generateNextCell(-1)
		city.generateNextCell(1)

		-- change this later
		--newPlayer("Test", newKeyboardController("up", "down", "left", "right", "a"))
		if love.joystick.getJoystickCount() > 0 then 
			newPlayer("Test", newGamepadController(love.joystick.getJoysticks()[1]))
		else 
			newPlayer("Test", newKeyboardController("up", "down", "left", "right", "a", "s", "w"))
		end

		camera.targetY = -400	
	end 

	function gameloop.update()
		for i = 1, #players do 
			players[i].update()
		end 

		-- Automatically generate new cells if there is no cell yet next to the current player's cell
		local playerTilePosX = world.pixelToTileCoordinates(players[1].position[1], 0)
		for i = -1, 1, 2 do
			if not world.cellExists(playerTilePosX, i) then
				city.generateNextCell(i)
			end
		end

		local velocityCameraTranslationX = 0.6
		local velocityCameraTranslationYPositive = 0.6
		local velocityCameraTranslationYNegative = 0.4
		local velocityCameraTranslationY = players[1].velocity[2] > 0 and velocityCameraTranslationYPositive or velocityCameraTranslationYNegative
		camera.targetX = players[1].position[1] + players[1].width/2 + players[1].velocity[1] * velocityCameraTranslationX
		camera.targetY = players[1].position[2] + players[1].height/2 + players[1].velocity[2] * velocityCameraTranslationY

		local standingZoom = 1.5
		local minZoom = 0.8
		local zoomVelFactor = 0.005
		camera.targetZoom = minZoom + math.exp(-zoomVelFactor * vnorm(players[1].velocity)) * (standingZoom - minZoom)

		local maxTargetY = players[1].height/2 - love.window.getHeight()/2 / camera.scale
		camera.targetY = math.min(maxTargetY, camera.targetY)
		camera.update()
	end 

	function gameloop.draw()
		love.graphics.setShader()
		love.graphics.setCanvas(postProcessCanvas)
		love.graphics.setColor(255, 255, 255, 255)
		love.graphics.draw(bgImage, 0, 0, 0, love.window.getWidth() / bgImage:getWidth(), love.window.getHeight() / bgImage:getHeight())

		camera.push()
		local leftBorderInWorld = -love.window.getWidth()/2/camera.scale + camera.x -- (screen) x = 0
		
		for layer = 1, 3 do 
			local invLayer = 4 - layer
			local c = 255 * (invLayer * 0.2 + 0.2)
			love.graphics.setColor(c, c, c - invLayer*20, 255)

			local parallaxX = camera.x * (0.4 + invLayer*0.15)
			local parallaxY = 0.0 -- camera.y * (0.2 + (3-layer)*0.1)
			local scale = 0.8 / invLayer
			local scalex, scaley = scale * 0.5, scale*invLayer
			local imgW = parallaxBackgrounds[1]:getWidth() * scalex
			
			local startI = math.floor((leftBorderInWorld - parallaxX) / imgW)
			for i = startI, startI + math.ceil(love.window.getWidth() / (imgW * camera.scale)) + 1 do
				local img = parallaxBackgrounds[cheapNoise(i + layer * 10) % #parallaxBackgrounds + 1]
				local x, y = i*imgW + parallaxX, parallaxY -- -(invLayer-1)*80
				love.graphics.draw(img, x, y - img:getHeight()*scaley, 0, scalex, scaley)
			end
		end 
		
		love.graphics.setColor(200, 200, 190, 255)
		for i = 1, math.ceil(love.window.getWidth()/camera.scale / streetTile:getWidth()) + 1 do -- dont know why i need the +1 
			love.graphics.draw(streetTile, math.floor(leftBorderInWorld / streetTile:getWidth() + i - 1) * streetTile:getWidth(), - 15)
		end

		love.graphics.setShader(tileDamageShader)
		world.render()
		love.graphics.setShader()

		for i = 1, #players do 
			players[i].draw()
		end 
		camera.pop()

		love.graphics.setCanvas(godRayCanvas)
		godRayCanvas:clear(255, 255, 255, 255)
		love.graphics.setShader(singleColorShader)
		singleColorShader:send("uColor", {0, 0, 0, 255})
		camera.push()
		world.render()
		camera.pop()
		
		love.graphics.setColor(255, 255, 255, 255)
		love.graphics.setShader(postProcess)
		love.graphics.setCanvas()
		postProcess:send("noiseMap", filmGrainImage)
		postProcess:send("noiseOffset", {love.math.random(), love.math.random()})
		postProcess:send("godrayMap", godRayCanvas)
		love.graphics.draw(postProcessCanvas)
	end 
end