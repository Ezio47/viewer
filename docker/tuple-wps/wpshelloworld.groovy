title = 'HelloWorld'
description = 'a simple test script'

inputs = [
    alpha: [name: 'Alpha', description: 'the input string', type: String.class],
]

outputs = [
	omega: [name: 'Omega', description: 'the output string', type: String.class],
]

def run(input) {
    def r = input.alpha.reverse();

    [
      omega: r
    ]
}
