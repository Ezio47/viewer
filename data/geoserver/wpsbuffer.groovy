import geoscript.geom.Geometry

title = 'GeoScriptBuffer'
description = 'Buffer a Geometry using GeoScript'

inputs = [
	geom: [name: 'geom', description: 'Geometry to buffer', type: Geometry.class],
	distance: [name: 'distance', description: 'The buffer distance', type: Double.class]
]

outputs = [
	result: [name: 'result', description: 'The buffered geometry', type: Geometry.class] 
]

def run(input) {
	[result: input.geom.buffer(input.distance as double)]
}