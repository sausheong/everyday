FPS = 6
ROID_SIZE = 6
WORLD = {:xmax => ROID_SIZE * 100, :ymax => ROID_SIZE * 100} # boundary of the world
POPULATION_SIZE = 50
FOOD_COUNT = 30
OBSTACLE_SIZE = 30
MAGIC_NUMBER = 10 # the number of roids it will monitor

SEPARATION_RADIUS = ROID_SIZE * 2 # steer to avoid crowding of flockmates
ALIGNMENT_RADIUS  = ROID_SIZE * 35 # steer towards average heading of flockmates
COHESION_RADIUS   = ROID_SIZE * 35 # steer to move toward average position of flockmates

SEPARATION_ADJUSTMENT = 10 # how far away should roids stay from each other (small further away)
ALIGNMENT_ADJUSTMENT = 8 # how aligned are the roids with each other (smaller more aligned)
COHESION_ADJUSTMENT = 100 # how cohesive the roids are with each other (smaller more cohesive)
CENTER_RADIUS     = ROID_SIZE * 10 # radius of how close to the center it stays
MAX_ROID_SPEED = 20

END_OF_THE_WORLD = 3000
MAX_LIFESPAN = 100
MAX_ENERGY = 100
CHILDBEARING_AGE = 20..50
CHILDBEARING_ENERGY_LEVEL = 15
CHILDBEARING_ENERGY_SAP = 0.8

MAX_METABOLISM = 4.0
MAX_VISION_RANGE = ROID_SIZE * 10.0