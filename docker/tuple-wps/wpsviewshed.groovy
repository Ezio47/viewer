title = 'GeoScriptViewshed'
description = 'Compute a viewshed via Ossim'

inputs = [
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
        
    def env = System.getenv()

    // required: value is used as a prefix to the "input dem" filename
    //   example: /tomcat/webapps/ROOT/ossim_data
    String tupleInputPath = env['TUPLE_INPUT_PATH']

    // required: value is used as a prefix to the "output image file" filename
    //   example: /tomcat/webapps/ROOT/ossim_data
    String tupleOutputPath = env['TUPLE_OUTPUT_PATH']
   
    // required: value is used as the root URL where data files are stored
    //   example: http://192.168.59.103:12345/ossim_data/
    String tupleOutputUrl = env['TUPLE_OUTPUT_URL']
   
    def inputFile = tupleInputPath + '/' + (input.inputDem as String)
    def outputFile = tupleOutputPath + '/' + millis + ".tif"
    def outputFile2 = tupleOutputPath + '/' + millis + "-3.tif"
    def outputFile3 = tupleOutputPath + '/' + millis + "-tiles"
    def outputUrl = tupleOutputUrl + '/' + millis + "-tiles"
    
    def myStdout = ""
    def myStderr = ""

    //
    // DEBUG
    //
    def cmd0 = ['ls', tupleInputPath]
    def proc0 = cmd0.execute()
    
    proc0.waitFor()
    
    myStdout += "\n\n==== DEBUG0 stdout ====\n\n" + proc0.in.text
    myStderr += "\n\n==== DEBUG0 stderr ====\n\n" + proc0.err.text
    
    if (proc0.exitValue() != 0) {
        return [
            outputUrl: "",
            stdoutText: myStdout,
            stderrText: myStderr
        ]
    }

    //
    // VIEWSHED
    //
    def cmd1 = [
        "ossim-viewshed", 
        "--dem", inputFile,
        "--fov", (input.fovStart as String), (input.fovEnd as String),
        "--hgt-of-eye", (input.eyeHeight as String),
        "--radius", (input.radius as String),
        (input.obsLat as String), (input.obsLon as String),
        outputFile  
    ]
    def proc1 = cmd1.execute()

    myStdout += "==== VIEWSHED stdout ====\n\n" + proc1.in.text
    myStderr += "==== VIEWSHED stderr ====\n\n" + proc1.err.text
    
    if (proc1.exitValue() != 0) {
        return [
            outputUrl: "",
            stdoutText: myStdout,
            stderrText: myStderr
        ]
    }

    //
    // GDAL_TRANSLATE
    //
    // gdal2tiles seems to only like 3-band images, so convert the tif
    //
    def cmd2 = [
        "gdal_translate", "-b", "1", "-b", "1", "-b", "1",
        outputFile, outputFile2
    ]

    def proc2 = cmd2.execute()
    proc2.waitFor()
    
    myStdout += "\n\n==== GDAL_TRANSLATE stdout ====\n\n" + proc2.in.text
    myStderr += "\n\n==== GDAL_TRANSLATE stderr ====\n\n" + proc2.err.text

    if (proc2.exitValue() != 0) {
        return [
            outputUrl: "",
            stdoutText: myStdout,
            stderrText: myStderr
        ]
    }

    //
    // GDAL2TILES
    //
    def cmd3 = [
        "gdal2tiles.py", "-z", "5-12", "--webviewer=none",
        outputFile2, outputFile3
    ]

    def proc3 = cmd3.execute()
    proc3.waitFor()
    
    myStdout += "\n\n==== GDAL2TILES stdout ====\n\n" + proc3.in.text
    myStderr += "\n\n==== GDAL2TILES stderr ====\n\n" + proc3.err.text

    if (proc3.exitValue() != 0) {
        return [
            outputUrl: "",
            stdoutText: myStdout,
            stderrText: myStderr
        ]
    }

    //
    // RESULT
    //
    [
      outputUrl: outputUrl,
      stdoutText: myStdout,
      stderrText: myStderr
    ]
}
