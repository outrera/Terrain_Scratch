extends Object

# This is designed as a height map generation tool
# Internally it can use many techniques, but ultimately 
# should return a simple height per coordinate call

var Perlin = load("res://PerlinRef.gd")

var multiplier_hash
var amp_hash
var island_limiter
var hashes

class ContinentalDome:
	var r
	func _init(radius):
		# Radius is in chunks
		r = radius

	func getHash(x, z):
		var y = 0.0
		var lxz = Vector2(x, z).length()
		if lxz > r:
			return y
		y = cos(PI * lxz / r) + 1.0

		return y / 2.0

func _init(shelf_limit, rseed = 0):
	seed(rseed)
	randi() # Discard first rand as value tends to be low
	var hash_seeds = [randi(), randi(), randi(), randi(), randi(), randi()]
	island_limiter = ContinentalDome.new(shelf_limit)
	multiplier_hash = Perlin.new(15.0 / shelf_limit, hash_seeds[4])
	amp_hash = Perlin.new(7.0 / shelf_limit, hash_seeds[5])
	hashes = [
		Perlin.new(1.0 / 29.0, hash_seeds[0]),
		Perlin.new(1.0 / 17.0, hash_seeds[1]),
		Perlin.new(1.0 / 7.0, hash_seeds[2]),
		Perlin.new(1.0 / 3.0, hash_seeds[3]),
	]

func getHash(x, y):
	var amp_multiplier = multiplier_hash.getHash(x, y)
	var new_height = island_limiter.getHash(x, y)
	var amp = amp_hash.getHash(x, y)
	for p in hashes:
		new_height += p.getHash(x, y) * amp
		amp *= amp_multiplier
	return new_height