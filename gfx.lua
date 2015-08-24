function initGFX()
	bgImage = love.graphics.newImage("gfx/bg.png")
	streetTile = love.graphics.newImage("gfx/street_tile.png")

	tileDamageShader = love.graphics.newShader([[
	uniform Image damageMap;
	uniform float damage = 0.0;

	vec4 effect(vec4 color, Image texture, vec2 texCoords, vec2 screenCoords) {
		vec4 c = color * Texel(texture, texCoords);
		c.a = mix(1.0, Texel(damageMap, texCoords).r, damage);
		return c;
	}
	]])

	damageMaps = {}
	for i = 1, 5 do 
		damageMaps[i] = love.graphics.newImage("gfx/dmg_map" .. tostring(i) .. ".png")
		print(damageMaps[i])
	end

	parallaxBackgrounds = {}
	for i = 1, 3 do 
		parallaxBackgrounds[i] = love.graphics.newImage("gfx/parallax_bg" .. tostring(i) .. ".png")
	end 

	filmGrainScale = 2.0
    local grainData = love.image.newImageData(love.window.getWidth()/filmGrainScale, love.window.getHeight()/filmGrainScale)
    for y = 0, love.window.getHeight()/filmGrainScale - 1 do
        for x = 0, love.window.getWidth()/filmGrainScale - 1 do
            local col = love.math.random(1, 255)
            grainData:setPixel(x, y, col, col, col, 255)
        end
    end
    filmGrainImage = love.graphics.newImage(grainData)
    filmGrainImage:setWrap("repeat", "repeat")

    postProcess = love.graphics.newShader([[
	uniform Image noiseMap;
    uniform vec2 noiseOffset;

    uniform Image godrayMap;
    const int samples = 13;
    const float weights[13] = float[13](0.004571, 0.00723, 0.010989, 0.016048, 0.022521, 0.03037, 0.039354, 0.049003, 0.058632, 0.067411, 0.074476, 0.079066, 0.080657);

    const float filmGrainOpacity = 0.08;

    const float vignetteRadius = 0.8;
    const float vignetteSoftness = 0.4;
    const float vignetteOpacity = 1.0;


    vec4 effect(vec4 color, Image texture, vec2 textureCoords, vec2 screen_coords) {
        vec3 col = mix(Texel(noiseMap, textureCoords + noiseOffset).rgb, Texel(texture, textureCoords).rgb, vec3(1.0 - filmGrainOpacity));
        
        float centerDist = length(textureCoords - vec2(0.5));
        float vignette = smoothstep(vignetteRadius, vignetteRadius - vignetteSoftness, centerDist);

        float brightness = 1.0;
        for(int i = 0; i < samples; ++i) {
    		brightness += Texel(godrayMap, textureCoords).r * weights[samples-i-1];
    		textureCoords += vec2(1.0, -1.0) * 0.005;
    	}
    	col *= min(1.5, brightness * brightness);

        return vec4(mix(col, col * vignette, vignetteOpacity), 1.0);
    }
    ]])

	singleColorShader = love.graphics.newShader([[
		uniform vec4 uColor;
		vec4 effect(vec4 color, Image texture, vec2 textureCoords, vec2 screen_coords) {
			return uColor;
		}
	]])

    postProcessCanvas = love.graphics.newCanvas()
    godRayCanvas = love.graphics.newCanvas()

	buildingTileSets = {

		{
			lb = love.graphics.newImage("gfx/building_b/lb.png"),
			lm = love.graphics.newImage("gfx/building_b/lm.png"),
			lt = love.graphics.newImage("gfx/building_b/lt.png"),
			mb = love.graphics.newImage("gfx/building_b/mb.png"),
			mm = love.graphics.newImage("gfx/building_b/mm.png"),
			mt = love.graphics.newImage("gfx/building_b/mt.png"),
			rb = love.graphics.newImage("gfx/building_b/rb.png"),
			rm = love.graphics.newImage("gfx/building_b/rm.png"),
			rt = love.graphics.newImage("gfx/building_b/rt.png"),
			door = love.graphics.newImage("gfx/building_b/door.png")
		},

		{
			lb = love.graphics.newImage("gfx/building_c/lb.png"),
			lm = love.graphics.newImage("gfx/building_c/lm.png"),
			lt = love.graphics.newImage("gfx/building_c/lt.png"),
			mb = love.graphics.newImage("gfx/building_c/mb.png"),
			mm = love.graphics.newImage("gfx/building_c/mm.png"),
			mt = love.graphics.newImage("gfx/building_c/mt.png"),
			rb = love.graphics.newImage("gfx/building_c/rb.png"),
			rm = love.graphics.newImage("gfx/building_c/rm.png"),
			rt = love.graphics.newImage("gfx/building_c/rt.png"),
			door = love.graphics.newImage("gfx/building_c/door.png")
		}	
	}
end 

function drawGame() 

end
