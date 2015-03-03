title = 'SleepTest'
description = 'Sleep test with GeoScript'

inputs = [
    alpha: [name: 'alpha', description: 'first value', type: Double.class],
	beta: [name: 'beta', description: 'second value', type: Double.class],
	duration: [name: 'duration', description: 'seconds to sleep', type: Double.class]
]

outputs = [
	gamma: [name: 'gamma', description: 'output value', type: Double.class]
]

def run(input) {

    Thread.sleep((input.duration as int) * 1000)
    
	[gamma: input.alpha + input.beta + input.duration]
}
