title = 'GeoScriptViewshed'
description = 'Compute the Viewshed a la Oscar'

inputs = [
    serverInputPath: [name: 'serverInputPath', description: '(root path for input files)', type: String.class],
    serverOutputPath: [name: 'serverOutputPath', description: '(root path for output files)', type: String.class],
    serverOutputUrl: [name: 'serverOutputUrl', description: '(URL prefix for output files)', type: String.class],
	obsLat: [name: 'obsLat', description: 'observer latitude', type: Double.class],
    obsLon: [name: 'obsLon', description: 'observer longitude', type: Double.class],
    fovStart: [name: 'fovStart', description: 'field of view start (degrees)', type: Double.class],
    fovEnd: [name: 'fovEnd', description: 'field of view end (degrees)', type: Double.class],
    eyeHeight: [name: 'eyeHeight', description: 'eye height (meters)', type: Double.class],
    radius: [name: 'radius', description: 'radius (meters)', type: Double.class],
    inputDem: [name: 'inputDem', description: 'name of DEM source', type: String.class],
]

outputs = [
	outputUrl: [name: 'outputUrl', description: 'URL of output result', type: String.class],
    stdoutText: [name: 'stdoutText', description: 'output from cmd line', type: String.class],
    stderrText: [name: 'stderrText', description: 'error output from cmd line', type: String.class] 
]

def run(input) {
    def millis = System.currentTimeMillis() as String
    
    def inputFile = input.serverInputPath + '/' + (input.inputDem as String)
    def outputFile = input.serverOutputPath + '/' + millis
    def outputUrl = input.serverOutputUrl + '/' + millis
    
    def cmd = [
        "./data_dir/scripts/wps/xyzzy.sh", 
        "--input-dem", inputFile,
        "--fov", (input.fovStart as String), (input.fovEnd as String),
        "--hgt-of-eye", (input.eyeHeight as String),
        "--radius", (input.radius as String),
        (input.obsLat as String), (input.obsLon as String),
        outputFile  
    ]

    def proc = cmd.execute()
    proc.waitFor()
    
    def myStdout = proc.in.text
    def myStderr = proc.err.text
    
    [
      outputUrl: outputUrl,
      stdoutText: myStdout,
      stderrText: myStderr
    ]
}
