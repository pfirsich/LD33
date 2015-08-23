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
			print(player.controller.moveX(), targetVelX)
			player.velocity[1] = player.velocity[1] + sign(targetVelX - player.velocity[1]) * accel * simulationDt
			if math.abs(targetVelX - player.velocity[1]) < accel * simulationDt then player.velocity[1] = targetVelX end

			if player.canJump and player.controller.jump().pressed then 
				player.jumpStarted = simulationTime
				player.canJump = false
			end 

			local jumpDelay = 0.0
			local jumpDuration = 0.3
			if simulationTime - player.jumpStarted > jumpDelay and simulationTime - player.jumpStarted < jumpDelay + jumpDuration then 
				local jumpAccell = 4500.0
				player.velocity[2] = player.velocity[2] - jumpAccell * simulationDt
			end
			local gravity = 1000.0
			player.velocity[2] = player.velocity[2] + gravity * simulationDt

			player.position = vadd(player.position, vmul(player.velocity, simulationDt))

			if player.position[2] + player.height > 0 then 
				player.position[2] = -player.height
				player.velocity[2] = 0
				player.canJump = true
			end 
		end 

		players[#players+1] = player
	end
end