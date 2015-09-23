-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- Hide the status bar and get the screen size
display.setStatusBar( display.HiddenStatusBar )
WIDTH = display.contentWidth
HEIGHT = display.contentHeight

-- Draw background
bg_name = "stars.jpg"
bg_width = 1920
bg_height = 1080
bg = display.newImageRect(bg_name, (WIDTH/HEIGHT) * bg_height, HEIGHT)
bg.x = WIDTH/2
bg.y = HEIGHT/2


-- display reset button
reset = display.newImageRect("reset.png", 100, 50)
reset.x = 260
reset.y = 450

-- Create ball which is the collision detecter under the character
radius = 20
ball = display.newCircle(50, 50, radius)

-- make the character a little bigger than the ball
character = display.newImageRect("meatwad.png", radius*2.5, radius*2.5)

-- create array of targets and make them random colors and starting locations
target = {} 
target_radius = 10
for i = 1, 3 do
	target[i] = display.newCircle(WIDTH, math.random(0, HEIGHT), target_radius)
	target[i]:setFillColor( math.random(), math.random(), math.random() )
end

-- Define the ball's motion variables
dyBall = 0     -- The ball's speed in the y direction (in pixels per frame)
ddyBall = 0.5  -- The ball's acceleration (gravity) in the y direction
bounce = 0.7   -- The ball's bounce ratio (fraction of speed retained)
target_speed = -5 -- How fast the target is moving (negative because its goind left)

hits = 0
misses = 0
accuracy = 0

reset_target = false -- flag that goes true if the charager hit the target

-- Create score text object
score_text = display.newText("Hits: " .. hits .. " Misses: " .. misses .. " " ..
				accuracy .. "% hit", 
				10, 20, native.systemFontBold, 24 )
score_text.anchorX = 0  -- Align and anchor text by left edge not center 

-- Change the position of things for the next frame and detect hits/misses
function newFrame()
	--calc accuracy
	if (hits+misses) > 0 then -- make sure we don't divide by 0 
		accuracy = math.round(hits / (hits + misses) * 100)
	end

	--update score text
	score_text.text = "Hits: " .. hits .. "  Misses: " .. misses .. "  " ..
		accuracy .. "%" 

	-- Move the ball according to its current velocity
	ball.y = ball.y + dyBall
	for i = 1, 3 do
		target[i].x = target[i].x + target_speed 
	end
	-- If the ball passed the bottom during this frame, make it bounce
	if (ball.y > HEIGHT - radius) then
		ball.y = ball.y - dyBall    -- Undo the downward movement that went past the bottom
		dyBall = -dyBall * bounce   -- Reverse the downward speed and apply bounce factor
	end

	-- detect collision if the ditance between circles is <= radius of both
	-- do this for each target
	for i = 1, 3 do
		distance = math.sqrt( 
			math.pow(ball.x - target[i].x, 2) + math.pow(ball.y - target[i].y, 2) )

		-- if hit then increment hit score and reset target
		if distance < (radius + target_radius) then
			hits = hits + 1
			reset_target = true
		end

		-- if target goes off screen then inc miss and reset target
		if target[i].x < (0 - target_radius) then
			misses = misses + 1
			reset_target = true
		end

		-- if we need to reset target give it a random location off the right side of screen
		if reset_target then
			target[i].x = WIDTH + target_radius
			target[i].y = math.random( 1, HEIGHT )
			reset_target = false
		end
	end

	-- Change the current velocity over time by applying the acceleration (gravity)
	dyBall = dyBall + ddyBall

	-- give the character a little upward motion when touched and clear touched
	-- flag for this frame
	if touched then
		dyBall = -10
		touched = false
	end

	-- make sure character stays on top of his collision ball
	character.x = ball.x
	character.y = ball.y
end

-- detect a touch event and set a floag so that only one touch event registers
-- per frame
function onTouch(event)
	if ( event.phase == "began" ) then
        touched = true 
    end
    return true
end

-- reset the score
function resetTapped(event)
	hits = 0
	misses = 0
	accuracy = 0
end

-- make sure reset touch cancels all other touch listeners
function resetTouched(event)
	return true
end

-- Install the animation event listener
Runtime:addEventListener( "enterFrame", newFrame )

-- Install tap/touch listeners
Runtime:addEventListener( "touch", onTouch )
reset:addEventListener("tap", resetTapped)
reset:addEventListener("touch", resetTouched)