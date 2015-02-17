import geoscript.geom.Geometry

title = 'GeoScriptHello'
description = 'Hello World using GeoScript'

inputs = [
    geom: [name: 'geom', description: 'first value', type: Double.class],
	distance: [name: 'distance', description: 'second value', type: Double.class]
]

outputs = [
	result: [name: 'result', description: 'output value', type: Double.class] 
]

def run(input) {
	[result: input.geom + input.distance]
}