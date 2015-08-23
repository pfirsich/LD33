do
	players = {}

	local function sign(x, thresh)
		if math.abs(x) < (thresh or 1e-2) then 
			return 0 
		else 
			return x/math.abs(x)
		end
	end

	function newPlayer(name, controller)
		local player = {
			name = name,
			controller = controller,
			position = {0, 0},
			velocity = {0, 0},
			width = 70,
			height = 100,
			canJump = true,
			jumpStarted = -1000.0,
			climbing = false
		}

		player.position[2] = -player.height

		function player.draw()
			love.graphics.setColor(255, 0, 0, 255)
			love.graphics.rectangle("fill", player.position[1], player.position[2], player.width, player.height)
			love.graphics.setColor(255, 255, 255, 255)
		end

		function player.update()
			local accel = 1000.0
			local maxVelX = 400.0
			player.velocity[1] = player.velocity[1] + player.controller.moveX() * accel * simulationDt
			if math.abs(player.velocity[1]) > maxVelX then player.velocity[1] = maxVelX * sign(player.velocity[1]) end

			local targetVelX = maxVelX * player.controller.moveX()
			if math.abs(targetVelX/maxVelX) < 0.2 then targetVelX = 0 end
			player.velocity[1] = player.velocity[1] + sign(targetVelX - player.velocity[1]) * accel * simulationDt
			if math.abs(targetVelX - player.velocity[1]) < accel * simulationDt then player.velocity[1] = targetVelX end

			local climbCollision = false
			local playerTilePos = {world.pixelToTileCoordinates(unpack(player.position))}
			local xrange = math.ceil(tileWidth/player.width)
			local yrange = math.ceil(tileHeight/player.height)
			for ty = playerTilePos[2] - yrange, playerTilePos[2] + yrange do 
				for tx = playerTilePos[1] - xrange, playerTilePos[1] + xrange do 
					local tile = world.getTileAt(tx, ty)

					local tileHitBoxX = (tx + (tile ~= nil and tile.type:sub(-3, -2) == '_r' and 0.5 or 0.0)) * tileWidth
					local tileHitBox = {{tileHitBoxX, ty * tileHeight}, {tileWidth/2, tileHeight}}

					if aabbCollision({player.position, {player.width, player.height}}, tileHitBox) then 
						--if tile ~= nil then print(tile.type) end

						 -- climbing
						if tile ~= nil and inSet(tile.type, {"building_lb", "building_lm", "building_lt", "building_rb", "building_rm", "building_rt"}) then
							climbCollision = true
						end 
					end 
				end 
			end 

			if climbCollision and player.controller.grab().pressed then 
				player.climbing = true
				player.jumpStarted = -1000.0
				player.velocity[2] = 0
			end 

			if not climbCollision then player.climbing = false end

			if (player.canJump or player.climbing) and player.controller.jump().pressed then 
				player.jumpStarted = simulationTime
				player.canJump = false
				player.climbing = false
			end 

			local jumpDelay = 0.0
			local jumpDuration = 0.3
			if simulationTime - player.jumpStarted > jumpDelay and simulationTime - player.jumpStarted < jumpDelay + jumpDuration then 
				local jumpAccell = 4500.0
				player.velocity[2] = player.velocity[2] - jumpAccell * simulationDt
			end

			if player.climbing then 
				player.velocity[2] = player.controller.moveY() * 200.0
			else 
				local gravity = 1000.0
				player.velocity[2] = player.velocity[2] + gravity * simulationDt
			end 

			player.position = vadd(player.position, vmul(player.velocity, simulationDt))

			if player.position[2] + player.height > 0 and simulationTime - player.jumpStarted > jumpDelay + jumpDuration then 
				player.position[2] = -player.height
				player.velocity[2] = 0
				player.canJump = true
				player.climbing = false
			end 
		end 

		players[#players+1] = player
	end
end