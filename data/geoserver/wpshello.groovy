import geoscript.geom.Geometry
import java.util.timer.*  

title = 'GeoScriptHello'
description = 'Hello World using GeoScript'

inputs = [
    alpha: [name: 'alpha', description: 'first value', type: Double.class],
	beta: [name: 'beta', description: 'second value', type: Double.class]
]

outputs = [
	gamma: [name: 'gamma', description: 'output value', type: Double.class] 
]

def run(input) {

    //Thread.sleep(1 * 1000)
    
	[gamma: input.alpha + input.beta]
}
