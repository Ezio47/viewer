title = 'SummationTest'
description = 'Summation test with GeoScript'

inputs = [
    alpha: [name: 'alpha', description: 'first value', type: Double.class],
	beta: [name: 'beta', description: 'second value', type: Double.class]
]

outputs = [
	gamma: [name: 'gamma', description: 'output value', type: Double.class] 
]

def run(input) {
    
	[gamma: input.alpha + input.beta]
}
