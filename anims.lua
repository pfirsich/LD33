local uwotanim8 = {}

do 
	require "math_vec"

	-- This generates a class with an optional base.
	-- The generated class can be instanced by calling it, which calls the class:init() method of it.
	local function class(base)
	    local cls = {}
	    cls.__index = cls
	    cls.static = base and copyObject(base.static) or {}

	    return setmetatable(cls, {
	        __index = base,

	        __call = function(c, ...)
	            local self = setmetatable({}, c)
	            if self.init then self:init(...) end
	            return self
	        end
	    })
	end

	local function copyObject(tbl)
		if type(tbl) == "table" then
			local temp = {}
			for k,v in pairs(tbl) do
				temp[k] = copyObject(tbl[k])
			end
			return temp
		else
			return tbl
		end
	end

	local Stack = class()
	function Stack:init() self.stack = {} end
	function Stack:push(v) self.stack[#self.stack+1] = v end
	function Stack:top() return self.stack[#self.stack] end
	function Stack:size() return #self.stack end
	function Stack:pop()
	    local temp = self.stack[#self.stack]
	    self.stack[#self.stack] = nil
	    return temp
	end

	local transformStack = Stack()
	transformStack:push({{1,0,0},{0,1,0},{0,0,1}})

	--[[
	T = {{1,0,dx},{0,1,dy},{0,0,1}}
	R = {{p,-t,0},{t,p,0},{0,0,1}}
	I = {{1,0,0},{0,1,0},{0,0,1}}
	with p = cos(angle), t = sin(angle)

	general Matrix:
	M = {{a,b,c},{d,e,f},{g,h,i}}

	M*T = {{a,b, a*dx+b*dy+c}, {d,e, d*dx+e*dy+f}, {g,h, g*dx+h*dy+i}}
	M*R = {{p*a+t*b, -t*a+p*b, c}, {p*d+t*e, -t*d+p*e, f}, {p*g+t*h, -t*g+p*h, i}}
	with {g,h,i} = {0,0,1}:
	M*T = {{a,b, a*dx+b*dy+c}, {d,e, d*dx+e*dy+f}, {0,0,1}}
	M*R = {{p*a+t*b, -t*a+p*b, c}, {p*d+t*e, -t*d+p*e, f}, {0,0,1}}
	Since these products have {g,h,i} = {0,0,1} it's valid to use only these

	M*{0,0,1} = {c,f,1}
	--]]

	local function transformIdentity()
		transformStack.stack[transformStack:size()] = {{1,0,0},{0,1,0},{0,0,1}}
	end

	local function matrixMul(a,b)
		local c = {{0,0,0},{0,0,0},{0,0,0}}
		for i = 1, 3 do
			for j = 1,3 do
				for k = 1, 3 do
					c[i][j] = c[i][j] + a[i][k] * b[k][j]
				end
			end
		end
		return c
	end

	local function transformPush()
		transformStack:push(copyObject(transformStack:top()))
	end

	local function transformPop()
		transformStack:pop()
	end

	local function transformTranslate(dx,dy)
		transformStack.stack[transformStack:size()] = matrixMul(transformStack:top(), {{1,0,dx},{0,1,dy},{0,0,1}})
		--currentTransform[1][3] = currentTransform[1][1] * dx + currentTransform[1][2] * dy + currentTransform[1][3]
		--currentTransform[2][3] = currentTransform[2][1] * dx + currentTransform[2][2] * dy + currentTransform[2][3]
	end

	local function transformRotate(angle)
		local s = math.sin(angle)
		local c = math.cos(angle)
		transformStack.stack[transformStack:size()] = matrixMul(transformStack:top(), {{c,-s,0},{s,c,0},{0,0,1}})
		
		--currentTransform[1][1] =  c*currentTransform[1][1] + s*currentTransform[1][2] 
		--currentTransform[1][2] = -s*currentTransform[1][1] + c*currentTransform[1][2] 
		
		--currentTransform[2][1] =  c*currentTransform[2][1] + s*currentTransform[2][2] 
		--currentTransform[2][2] = -s*currentTransform[2][1] + c*currentTransform[2][2] 
	end

	function transformedOrigin(p)
		-- {c,f}, because: currentTransform * {0,0,1} = {c,f,1}
		return {transformStack:top()[1][3], transformStack:top()[2][3]}
	end

	local imageMap = {}
	local function getImage(str)
		if not imageMap[str] then
			imageMap[str] = love.graphics.newImage(str)
			return imageMap[str]
		else
			return imageMap[str]
		end
	end

	------------------------------------------------------------------------------------------------------------------
	------------------------------------------------------------------------------------------------------------------
	------------------------------------------------------------------------------------------------------------------

	local pi = math.pi
	-- into range 0-2pi
	local function normalizeAngle(a)
		while a < 0 do a = a + 2*pi end
		while a > 2*pi do a = a - 2*pi end
		return a
	end

	-- so that a = delta + b, only with normalized angles in [0,2pi]
	local function deltaAngle(a, b) 
		local rel = a - b
		if rel > pi then rel = rel - 2*pi end 
		if rel < -pi then rel = rel + 2*pi end
		return rel
	end

	local function drawImages(images)
		for i, image in ipairs(images) do
			local w = image.loveImage:getWidth() / 2
			local h = image.loveImage:getHeight() / 2
			if image.bone == nil then
				love.graphics.draw(image.loveImage, image.position[1], image.position[2], image.angle, 1, 1, w, h)
			else
				local dir = vnormed(vsub(image.bone.tipPosition, image.bone.rootPosition))
				local pos = vadd(image.bone.rootPosition, vtoStd(image.position, dir))
				love.graphics.draw(image.loveImage, pos[1], pos[2], image.angle + vangle(dir), 1, 1, w, h)
			end
		end
	end

	local function updateBoneTree(bone)
		if bone == nil then return end	
		transformPush()
			transformTranslate(unpack(bone.position))
			vcopy(bone.rootPosition, transformedOrigin())
			
			transformRotate(bone.initAngle)
			for i, child in ipairs(bone.rootChildren) do updateBoneTree(child) end
			
			transformRotate(bone.angle)
			for i, child in ipairs(bone.tipChildren) do updateBoneTree(child) end
			
			transformTranslate(bone.length, 0)
			vcopy(bone.tipPosition, transformedOrigin())
		transformPop()
	end

	local function traverseAngles(bone, func, counter)
		counter = counter or 1
		func(bone, counter)
		for i, child in ipairs(bone.rootChildren) do
			counter = traverseAngles(child, func, counter + 1)
		end
		for i, child in ipairs(bone.tipChildren) do
			counter = traverseAngles(child, func, counter + 1)
		end
		return counter
	end 

	local function applyAngles(bone, angles)
		traverseAngles(bone, function(bone, counter) 
			bone.angle = angles[counter] 
		end)
	end 

	local function applyDeltaAngles(bone, deltaAngles, factor)
		traverseAngles(bone, function(bone, counter)
			bone.angle = bone.angle + deltaAngles[counter] * factor
		end)
	end 

	local function getDeltaAngles(bone, targetAngles)
		deltaAngles = {}
		traverseAngles(bone, function(bone, counter) 
			deltaAngles[#deltaAngles+1] = deltaAngle(targetAngles[counter], bone.angle)
		end)
		return deltaAngles
	end 

	local function drawSkeleton(skeleton, x, y, angle, scalex, scaley, offsetx, offsety)
		love.graphics.push()
		love.graphics.translate(x, y)
		love.graphics.rotate(angle or 0)
		love.graphics.translate(offsetx or 0, offsety or 0)
		love.graphics.scale((scalex or 1) * (skeleton.flipped and -1 or 1), scaley or 1)

		transformIdentity()
		updateBoneTree(skeleton.root)
		drawImages(skeleton.images)

		love.graphics.pop()
	end

	local function advanceSkeleton(skeleton, dt)
		assert(skeleton.deltaAngles, "Animation can not be advaned if no starting animation was set")
		local keyframes = skeleton.animations[skeleton.targetAnimation].keyframes

		local oldDeltaAngles = getDeltaAngles(skeleton.root, keyframes[skeleton.targetKeyframe].angles)
		applyDeltaAngles(skeleton.root, skeleton.deltaAngles, skeleton.speed * dt)
		skeleton.root.position = vadd(skeleton.root.position, vmul(skeleton.deltaRoot, skeleton.speed * dt))
		local deltaAngles = getDeltaAngles(skeleton.root, keyframes[skeleton.targetKeyframe].angles)

		local passedKeyframe = false
		for i = 1, #deltaAngles do 
			if deltaAngles[i] * oldDeltaAngles[i] < 0.0 then 
				passedKeyframe = true
				break
			end 
		end

		if passedKeyframe then 
			applyAngles(skeleton.root, keyframes[skeleton.targetKeyframe].angles)
			skeleton.root.position = keyframes[skeleton.targetKeyframe].rootPosition
			local fromKeyFrameTime = keyframes[skeleton.targetKeyframe].time
			skeleton.targetKeyframe = skeleton.targetKeyframe % #keyframes + 1

			skeleton.deltaAngles = getDeltaAngles(skeleton.root, keyframes[skeleton.targetKeyframe].angles)
			skeleton.deltaRoot = vsub(keyframes[skeleton.targetKeyframe].rootPosition, skeleton.root.position)
			local deltaTime = keyframes[skeleton.targetKeyframe].time - fromKeyFrameTime
			if deltaTime < 0.0 then -- wrap around last keyframe to first keyframe
				deltaTime = skeleton.animations[skeleton.targetAnimation].length - fromKeyFrameTime + keyframes[skeleton.targetKeyframe].time
			end
			skeleton.speed = 1.0/deltaTime * skeleton.animations[skeleton.targetAnimation].speed
		end 
	end 

	local function blendInto(skeleton, lerptime, animation, keyframe)
		keyframe = keyframe or 1

		if lerptime == 0 then 
			local keyframes = skeleton.animations[animation].keyframes

			applyAngles(skeleton.root, keyframes[keyframe].angles)
			skeleton.root.position = keyframes[keyframe].rootPosition

			skeleton.targetAnimation = animation
			skeleton.targetKeyframe = keyframe % #keyframes + 1  -- unreadable, im sorry
			lerptime = (keyframes[skeleton.targetKeyframe].time - keyframes[keyframe].time) / skeleton.animations[animation].speed
		else
			skeleton.targetAnimation = animation
			skeleton.targetKeyframe = keyframe
		end

		skeleton.deltaAngles = getDeltaAngles(skeleton.root, skeleton.animations[skeleton.targetAnimation].keyframes[skeleton.targetKeyframe].angles)
		skeleton.deltaRoot = vsub(skeleton.animations[skeleton.targetAnimation].keyframes[skeleton.targetKeyframe].rootPosition, skeleton.root.position)
		skeleton.speed = 1.0 / lerptime
	end 

	local function split(line, delim) -- the delimiter should be escaped, since it is used in a pattern match
		local res = {}
		for str in line:gmatch("[^" .. delim .. "]+") do
			table.insert(res, str)
		end
		return res
	end

	local function toNumberArray(tbl)
		for i in ipairs(tbl) do
			tbl[i] = tonumber(tbl[i])
		end
		return tbl
	end

	local function boneFromLine(line)
		local csv = split(line, ",")
		local start = 1
		if #csv > 4 then start = 2 end
		local bone = {
			position = {tonumber(csv[start]), tonumber(csv[start+1])},
			length = tonumber(csv[start+2]),
			initAngle = normalizeAngle(tonumber(csv[start+3])),
			angle = 0,
			rootChildren = {},
			tipChildren = {},
			tipPosition = {0,0},
			rootPosition = {0,0}
		}
		if #csv > 4 then
			return bone, csv[1]
		else 
			return bone, nil
		end
	end

	local function getIndentation(line)
		local chompTab = function(str)
			if str:sub(1,1) == "\t" then return true, str:sub(2) end
			return false, str
		end
		
		local indentation = 0
		local hadTab, newLine
		hadTab, newLine = chompTab(line)
		while(hadTab) do
			indentation = indentation + 1
			hadTab, newLine = chompTab(newLine)
		end
		
		return indentation, newLine
	end

	local function stackPush(tbl, elem)
		table.insert(tbl, elem)
	end

	local function stackTop(tbl)
		return tbl[#tbl]
	end

	local function stackPop(tbl)
		return table.remove(tbl)
	end

	local function stackDepth(tbl)
		return #tbl
	end

	local function stackIsEmpty(tbl)
		return #tbl == 0
	end

	local function makeChildrenRelative(bone, parent)
		for i, child in ipairs(bone.rootChildren) do makeChildrenRelative(child, bone) end
		for i, child in ipairs(bone.tipChildren) do makeChildrenRelative(child, bone) end
		
		if parent ~= nil then
			bone.initAngle = deltaAngle(bone.initAngle, parent.initAngle)
			bone.position = vfromStd(vsub(bone.position, parent.position), vpolar(parent.initAngle, 1))
		end
	end

    -- TODO: Understand this again and fix it potentially (compare with old_load_skeleton.lua)
	local function loadSkeletonFile(filename, skel)
		skel.images = {}
        
        lineIterator = love.filesystem.lines(filename)
        local line = lineIterator()
        
        local parentStack = {}
		local boneIndexMap = {}
		repeat
			local indent
			indent, line = getIndentation(line)
			while not stackIsEmpty(parentStack) and stackTop(parentStack)[2] >= indent do
				stackPop(parentStack)
			end
			local parent = stackTop(parentStack)
			
			if parent ~= nil or skel.root == nil then
				local csv = split(line, ",")
				local bone, insertAt = boneFromLine(line)
				
				if parent == nil then 
					skel.root = bone
				else 
					if insertAt == "start" then
						table.insert(parent[1].rootChildren, bone)
					else
						table.insert(parent[1].tipChildren, bone)
					end
				end
				
				table.insert(boneIndexMap, bone)
				stackPush(parentStack, {bone, indent})
			end
			
			if not stackIsEmpty(parentStack) then line = lineIterator() end
		until stackIsEmpty(parentStack) or line == nil
		
		makeChildrenRelative(skel.root, nil)
		
		-- read images
		if line ~= nil then
			repeat
				local csv = split(line, ":")
				local image = {}
				image.loveImage = love.graphics.newImage(csv[1])
				image.position = {tonumber(csv[3]), tonumber(csv[4])}
				image.angle = tonumber(csv[5])
				image.bone = boneIndexMap[tonumber(csv[2])]
				table.insert(skel.images, image)
				
				line = lineIterator()
			until line == nil
        end
	end

	local function loadAnimationFile(filename, anim)
		anim.keyframes = {}
        
        local lineCounter = 1
        for line in love.filesystem.lines(filename) do
            if lineCounter == 1 then
                anim.length = tonumber(line)
            else
                local keyframe = {}
                local csv = toNumberArray(split(line, ","))
                
                keyframe.time = csv[1]
                keyframe.rootPosition = {csv[2], csv[3]}
                keyframe.angles = {}
                for i = 4, #csv do table.insert(keyframe.angles, csv[i]) end
                
                table.insert(anim.keyframes, keyframe)
            end
            lineCounter = lineCounter + 1
        end
                
		table.sort(anim.keyframes, function(a, b) return a.time < b.time end)
	end

	------------------------------------------------------------------------------------------------------------------------------
	------------------------------------------------------------------------------------------------------------------------------
	------------------------------------------------------------------------------------------------------------------------------

	function uwotanim8.newSkeleton(filename)
		local skel = {}
		skel.flipped = false
		skel.animations = {}
		skel.draw = function(...) drawSkeleton(skel, ...) end
		skel.blendInto = function(...) blendInto(skel, ...) end
		skel.advance = function(...) advanceSkeleton(skel, ...) end
		loadSkeletonFile(filename, skel)
		return skel
	end

	function uwotanim8.newAnimation(filename, speed)
		local anim = {}
		anim.speed = speed or 1.0
		loadAnimationFile(filename, anim)
		return anim 
	end
end

return uwotanim8