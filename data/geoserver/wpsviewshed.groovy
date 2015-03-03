import geoscript.geom.Geometry

title = 'GeoScriptViewshed'
description = 'Buffer a Geometry using GeoScript'

inputs = [
	pt1lon: [name: 'pt1Lon', description: 'point 1 longitude', type: Double.class],
    pt1lat: [name: 'pt1Lat', description: 'point 1 latitude', type: Double.class],
    pt2lon: [name: 'pt2Lon', description: 'point 2 longitude', type: Double.class],
    pt2lat: [name: 'pt2Lat', description: 'point 2 latitude', type: Double.class],
]

outputs = [
	resultlon: [name: 'resultLon', description: '(p2 - pt1) longitude', type: Double.class] 
    //resultlat: [name: 'resultLat', description: '(p2 - pt1) latitude', type: Double.class] 
]

def run(input) {
    Thread.sleep(5 * 1000)
    [resultlon: input.pt2lon - input.pt1lon]
}
