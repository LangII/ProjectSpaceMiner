

"""
--------------
BEHAVIOR NOTES
--------------

- MOTION STATES
	- on wall
		- walking
		- turning
			- concave
			- convex
	- floating
	- landing (transition from floating to on wall (transition from on wall to floating is instant))
- ATTACK STATES
	- can shoot (based on cool down)
	- is looking at ship (turret is pointed at ship)
	- is targeting ship (turret is turning towards ship)
	- ship is in range
	- ready
	- 

- To code the turning mechanics, have the sprite of the enemy be identical to the smallest piece of
terrain.  Then code the turning behavior as if the body of the enemy was a ball, where the center of
the ball is the "peak" of the pyramid (the smallest piece of terrain).
"""


extends KinematicBody2D


####################################################################################################





####################################################################################################


func _ready():
	pass

