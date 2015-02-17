import geoscript.geom.Geometry

title = 'GeoScriptHello'
description = 'Hello World using GeoScript'

inputs = [
    alpha: [name: 'alpha', description: 'first value', type: Double.class],
	beta: [name: 'beta', description: 'second value', type: Double.class]
]

outputs = [
	result: [name: 'result', description: 'output value', type: Double.class] 
]

def run(input) {
	[result: input.alpha + input.beta]
}
