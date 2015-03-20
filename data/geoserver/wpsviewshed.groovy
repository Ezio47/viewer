title = 'GeoScriptViewshed'
description = 'Compute the Viewshed a la Oscar'

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
    
    // required: value is used as a prefix to the "input dem" filename
    //   example: /user/alice/data
    String inputPathPrefix = env['TUPLE_INPUT_PREFIX']

    // required: value is used as a prefix to the "output image file" filename
    //   example: /opt/geoserver/www/wps/datadir/wps-outputs
    String outputPathPrefix = env['TUPLE_OUTPUT_PREFIX']
    
    // required: value is used as the root URL where data files are stored
    //   example: http://rialto.dev.ossim.org/files
    String outputUrl = env['TUPLE_URL_PREFIX']
    
    // required: value is used as the prefix to the "ossim-viewshed" filename
    //   example: /user/alice/dev/ossim/build/ossim
    String binDir = env['OSSIM_INSTALL_PREFIX']
    
    def inputFile = inputPathPrefix + '/' + (input.inputDem as String)
    def outputFile = outputPathPrefix + '/' + millis + ".tif"
    def outputFile2 = outputPathPrefix + '/' + millis + "-3.tif"
    def outputFile3 = outputPathPrefix + '/' + millis + "-tiles"
    def outputUrl = outputUrl + '/' + millis + "-tiles"
    
    def myStdout = ""
    def myStderr = ""

    //
    // DEBUG
    //
    def cmd0 = ['printenv'];
    def proc0 = cmd0.execute()
    proc0.waitFor()
    
    myStdout += "==== DEBUG stdout ====\n\n" + proc0.in.text
    myStderr += "==== DEBUG stderr ====\n\n" + proc0.err.text
    
    myStdout += "inputFile: " + inputFile + "\n"
    myStdout += "outputFile: " + outputFile + "\n"
    myStdout += "outputFile2: " + outputFile2 + "\n"
    myStdout += "outputFile3: " + outputFile3 + "\n"
    myStdout += "outputUrl: " + outputUrl + "\n"
    
    //
    // VIEWSHED
    //
    def cmd1 = [
        binDir + "/" + "ossim-viewshed", 
        "--dem", inputFile,
        "--fov", (input.fovStart as String), (input.fovEnd as String),
        "--hgt-of-eye", (input.eyeHeight as String),
        "--radius", (input.radius as String),
        (input.obsLat as String), (input.obsLon as String),
        outputFile  
    ]

    def proc1 = cmd1.execute()
    proc1.waitFor()
    
    myStdout += "==== VIEWSHED stdout ====\n\n" + proc1.in.text
    myStderr += "==== VIEWSHED stderr ====\n\n" + proc1.err.text
    
    //
    // GDAL_TRANSLATE
    //
    // gdal2tiles seems to only like 3-band images, so convert the tif
    //
    def cmd2 = [
        "./data_dir/scripts/wps/runcmd.sh", 
        "/usr/local/bin/gdal_translate", "-b", "1", "-b", "1", "-b", "1",
        outputFile, outputFile2
    ]

    def proc2 = cmd2.execute()
    proc2.waitFor()
    
    myStdout += "\n\n==== GDAL_TRANSLATE stdout ====\n\n" + proc2.in.text
    myStderr += "\n\n==== GDAL_TRANSLATE stderr ====\n\n" + proc2.err.text
        
    //
    // GDAL2TILES
    //
    def cmd3 = [
        "./data_dir/scripts/wps/runcmd.sh", 
        "/usr/local/bin/gdal2tiles.py", "-z", "5-12", "--webviewer=none",
        outputFile2, outputFile3
    ]

    def proc3 = cmd3.execute()
    proc3.waitFor()
    
    myStdout += "\n\n==== GDAL2TILES stdout ====\n\n" + proc3.in.text
    myStderr += "\n\n==== GDAL2TILES stderr ====\n\n" + proc3.err.text

    //
    // RESULT
    //
    [
      outputUrl: outputUrl,
      stdoutText: myStdout,
      stderrText: myStderr
    ]
}
