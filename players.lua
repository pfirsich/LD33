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
			climbing = false,
			buildingCollision = false,
			marker = {}
		}

		player.position[2] = -player.height

		function player.draw()
			love.graphics.setColor(255, 0, 0, 255)
			love.graphics.rectangle("fill", player.position[1], player.position[2], player.width, player.height)
			love.graphics.setColor(255, 255, 255, 255)
		end

		function player.update()
			-- accelerate in x direction towards a target velocity (0 if no buttons pressed)
			local accel = 1000.0
			local maxVelX = 400.0
			
			local targetVelX = maxVelX * player.controller.moveX()
			if math.abs(targetVelX/maxVelX) < 0.2 then targetVelX = 0 end
			player.velocity[1] = player.velocity[1] + sign(targetVelX - player.velocity[1]) * accel * simulationDt
			-- snap to the right velocity if close enough
			if math.abs(targetVelX - player.velocity[1]) < accel * simulationDt then player.velocity[1] = targetVelX end
			
			-- cap velocity
			if math.abs(player.velocity[1]) > maxVelX then player.velocity[1] = maxVelX * sign(player.velocity[1]) end

			-- moving up/down if climbing. otherwise gravity
			if player.climbing then 
				player.velocity[2] = player.controller.moveY() * 200.0
			else 
				local gravity = 1000.0
				player.velocity[2] = player.velocity[2] + gravity * simulationDt
			end 

			-- jumping logic
			if (player.canJump or player.climbing) and player.controller.jump().pressed then 
				player.jumpStarted = simulationTime
				player.canJump = false
				player.climbing = false
			end 

			-- jumping acceleration
			local jumpDelay = 0.0
			local jumpDuration = 0.2
			if simulationTime - player.jumpStarted > jumpDelay and simulationTime - player.jumpStarted < jumpDelay + jumpDuration and player.controller.jump().down then 
				local jumpAccell = 5000.0
				player.velocity[2] = player.velocity[2] - jumpAccell * simulationDt
			end

			-- integration
			player.position = vadd(player.position, vmul(player.velocity, simulationDt))

			-- floor collision
			if player.position[2] + player.height > 0 and simulationTime - player.jumpStarted > jumpDelay + jumpDuration then 
				player.position[2] = -player.height
				player.velocity[2] = 0
				player.canJump = true
				player.climbing = false
			end 

			-- other collision
			local climbCollision = false
			local lastBuildingCollision = player.buildingCollision
			player.buildingCollision = false

			local playerTilePos = {world.pixelToTileCoordinates(unpack(player.position))}

			local xrange = math.ceil(tileWidth/player.width)
			local yrange = math.ceil(tileHeight/player.height)
			for ty = playerTilePos[2] - yrange, playerTilePos[2] + yrange + 1 do 
				for tx = playerTilePos[1] - xrange, playerTilePos[1] + xrange + 1 do 
					local tile = world.getTileAt(tx, ty)

					local tileHitBoxX = (tx + (tile ~= nil and tile.type == 'building_rm' and 0.5 or 0.0)) * tileWidth
					local tileHitBox = {{tileHitBoxX, ty * tileHeight}, {tileWidth/2, tileHeight}}

					local mtv = aabbCollision({player.position, {player.width, player.height}}, tileHitBox)
					if mtv ~= nil then 
						 -- climbing
						if tile ~= nil and inSet(tile.type, {"building_lb", "building_lm", "building_lt", "building_rb", "building_rm", "building_rt"}) then
							climbCollision = true
						end 

						if tile ~= nil and inSet(tile.type, {"building_rt", "building_mt", "building_lt"}) then 
							if player.position[2] < ty * tileHeight and player.velocity[2] >= 0.0 then 
								player.position = vadd(player.position, mtv)
								player.buildingCollision = true
								player.velocity[2] = 0
							end
						end
					end 
				end 
			end 

			-- Set climbing to true if climb collision and grab button pressed
			if climbCollision and player.controller.grab().pressed then 
				player.climbing = true
				player.jumpStarted = -1000.0
				player.velocity[2] = 0
			end 

			-- not climbing if there is not climb collision
			if not climbCollision then player.climbing = false end

			-- building collision -> resolve collision, v = 0, 
			if player.buildingCollision and not lastBuildingCollision then 
				player.position[2] = math.floor((player.position[2] + player.height) / tileHeight) * tileHeight - player.height
				player.velocity[2] = 0
				player.canJump = true
				player.climbing = false
			end 
		end 

		players[#players+1] = player
	end
end