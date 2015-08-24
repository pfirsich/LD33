uwot = require "anims"

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
			width = 50,
			height = 110,
			canJump = true,
			jumpStarted = -1000.0,
			climbing = false,
			buildingCollision = false,
			facingRight = true,
			skeleton = uwot.newSkeleton("gfx/monstar/monstar.skel"),
		}

		player.skeleton.animations["idle"] = uwot.newAnimation("gfx/monstar/monstar_idle.anim", 2.0)
		player.skeleton.animations["run"] = uwot.newAnimation("gfx/monstar/monstar_run.anim")
		player.skeleton.animations["climb"] = uwot.newAnimation("gfx/monstar/monstar_climb.anim", 2.5)
		player.skeleton.animations["jump"] = uwot.newAnimation("gfx/monstar/monstar_jump.anim")
		player.skeleton.animations["fall"] = uwot.newAnimation("gfx/monstar/monstar_fall.anim")
		player.skeleton.animations["scream"] = uwot.newAnimation("gfx/monstar/monstar_scream.anim")

		player.skeleton.blendInto(0, "idle")

		player.position[2] = -player.height

		function player.draw()
			love.graphics.setColor(255, 0, 0, 255)
			-- hitbox
			--love.graphics.rectangle("fill", player.position[1], player.position[2], player.width, player.height)
			love.graphics.setColor(255, 255, 255, 255)

			player.skeleton.flipped = not player.facingRight
			local xOffset = player.width * (0.5 + 0.15 * (player.skeleton.flipped and 1 or -1))
			player.skeleton.draw(player.position[1] + xOffset, player.position[2] + player.height, 0, 0.05, 0.05)
		end

		function player.update()
			-- accelerate in x direction towards a target velocity (0 if no buttons pressed)
			local accel = 1000.0
			local maxVelX = player.climbing and 50 or 400.0
			
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
						if tile ~= nil and inSet(tile.type, {"building_lb", "building_lm", "building_rb", "building_rm"}) then
							climbCollision = true
							player.facingRight = (tile.type:sub(10, 10) == 'l')
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

			-- update animation
			if player.climbing then 
				if player.skeleton.targetAnimation ~= "climb" then 
					player.skeleton.blendInto(0.1, "climb")
					player.skeleton.inClimbAnimation = false
				else
				    if player.skeleton.targetKeyframe == 2 then 
				    	player.skeleton.inClimbAnimation = true
				    end 
				end

			    if math.abs(player.velocity[2]) > 1.0 or not player.skeleton.inClimbAnimation then     	
					player.skeleton.advance(simulationDt)
				end
			else 
				if math.abs(player.velocity[1]/maxVelX) > 0.2 then 
					player.facingRight = player.velocity[1] > 0.0
				end

				if player.velocity[2] > 1.0 then 
					if player.skeleton.targetAnimation ~= "fall" then player.skeleton.blendInto(0.3, "fall") end
				elseif player.velocity[2] < -1.0 then 
					if player.skeleton.targetAnimation ~= "jump" then player.skeleton.blendInto(0.3, "jump") end
				else 
					if math.abs(player.velocity[1]/maxVelX) > 0.2 then 
						player.facingRight = player.velocity[1] > 0.0
						if player.skeleton.targetAnimation ~= "run" then 
							player.skeleton.blendInto(0.2, "run", 4)
						end 
						player.skeleton.animations["run"].speed = math.abs(player.velocity[1]) / 30.0
					else
						if player.controller.scream().down then 
							if player.skeleton.targetAnimation ~= "scream" then 
								player.skeleton.blendInto(0.5, "scream")
							end 
						else 
							if player.skeleton.targetAnimation ~= "idle" then 
						    	player.skeleton.blendInto(0.3, "idle")
						    end
						end
					end 
				end
				player.skeleton.advance(simulationDt)
			end
		end 

		players[#players+1] = player
	end
end