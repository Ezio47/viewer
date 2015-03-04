import geoscript.geom.Geometry

title = 'GeoScriptViewshed'
description = 'Buffer a Geometry using GeoScript'

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
    summary: [name: 'summary', description: 'summary text from cmd line', type: String.class] 
]

def run(input) {
    [
      outputUrl: 'abcd'+ input.inputDem + 'xyz',
      summary: 'bbaazz'
    ]
}
