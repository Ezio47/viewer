// Copyright (c) 2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


class RiaDimension {
    // thesse are taken from PDAL
    static const int None = 0;
    static const int Unsigned8 = 0x201;
    static const int Signed8 = 0x101;
    static const int Unsigned16 = 0x202;
    static const int Signed16 = 0x102;
    static const int Unsigned32 = 0x204;
    static const int Signed32 = 0x104;
    static const int Unsigned64 = 0x208;
    static const int Signed64 = 0x108;
    static const int Float = 0x404;
    static const int Double = 0x408;

    static Map<String, int> typemap = {
        "uint8_t": Unsigned8,
        "int8_t": Signed8,
        "uint16_t": Unsigned16,
        "int16_t": Signed16,
        "uint32_t": Unsigned32,
        "int32_t": Signed32,
        "uint64_t": Unsigned64,
        "int64_t": Signed64,
        "float": Float,
        "double": Double
    };

    final int type;
    final String name;
    final double min;
    final double max;

    int byteOffset;

    List<List> lists = new List<List>();
    List get list => lists.last;
    Function setter;
    Function getter;
    Function reset;

    RiaDimension(int this.type, String this.name, double this.min, double this.max) {
        Function e;
        Function f;
        Function g;
        const endian = Endianness.LITTLE_ENDIAN;

        switch (type) {
            case Unsigned8:
                e = (numPoints) => lists.add(new Uint8List(numPoints));
                f = (ByteData buf, int bufIndex, int index) => list[index] = buf.getUint8(bufIndex);
                g = (ByteData buf, int bufIndex) => buf.getUint8(bufIndex);
                break;
            case Signed8:
                e = (numPoints) => lists.add(new Int8List(numPoints));
                f = (ByteData buf, int bufIndex, int index) => list[index] = buf.getUint8(bufIndex);
                g = (ByteData buf, int bufIndex) => buf.getUint8(bufIndex);
                break;
            case Unsigned16:
                e = (numPoints) => lists.add(new Uint16List(numPoints));
                f = (ByteData buf, int bufIndex, int index) => list[index] = buf.getUint16(bufIndex, endian);
                g = (ByteData buf, int bufIndex) => buf.getUint16(bufIndex, endian);
                break;
            case Signed16:
                e = (numPoints) => lists.add(new Int16List(numPoints));
                f = (ByteData buf, int bufIndex, int index) => list[index] = buf.getInt16(bufIndex, endian);
                g = (ByteData buf, int bufIndex) => buf.getInt16(bufIndex, endian);
                break;
            case Unsigned32:
                e = (numPoints) => lists.add(new Uint32List(numPoints));
                f = (ByteData buf, int bufIndex, int index) => list[index] = buf.getUint32(bufIndex, endian);
                g = (ByteData buf, int bufIndex) => buf.getUint32(bufIndex, endian);
                break;
            case Signed32:
                e = (numPoints) => lists.add(new Int32List(numPoints));
                f = (ByteData buf, int bufIndex, int index) => list[index] = buf.getInt32(bufIndex, endian);
                g = (ByteData buf, int bufIndex) => buf.getInt32(bufIndex, endian);
                break;
            case Unsigned64:
            case Signed64:
                throw new ArgumentError("64-bit ints not supported under dart2js");
            case Float:
                e = (numPoints) => lists.add(new Float32List(numPoints));
                f = (ByteData buf, int bufIndex, int index) => list[index] = buf.getFloat32(bufIndex, endian);
                g = (ByteData buf, int bufIndex) => buf.getFloat32(bufIndex, endian);
                break;
            case Double:
                e = (numPoints) => lists.add(new Float64List(numPoints));
                f = (ByteData buf, int bufIndex, int index) => list[index] = buf.getFloat64(bufIndex, endian);
                g = (ByteData buf, int bufIndex) => buf.getFloat64(bufIndex, endian);
                break;
            default:
                throw new ArgumentError("invalid datatype: $type");
        }

        reset = e;
        setter = f;
        getter = g;
    }

    void add(int index, dynamic v) {
        list[index] = v;
    }

    int get sizeInBytes => (type & 0xff);

    @override
    String toString() {
        return "dim=$name($sizeInBytes)";
    }
}

class RiaFormat {
    List<RiaDimension> dimensions;
    Map<String, RiaDimension> dimensionMap;
    Map<String, double> minimums;
    Map<String, double> maximums;
    int numTilesXAt0, numTilesYAt0;
    double dataBboxWest, dataBboxSouth, dataBboxEast, dataBboxNorth;
    double tileBboxWest, tileBboxSouth, tileBboxEast, tileBboxNorth;

    int numPoints;

    RiaFormat();

    readHeaderJson(String json) {
        Map mydata = JSON.decode(json);

        int version = mydata["version"];
        assert(version == 3);

        numPoints = mydata["numPoints"];

        numTilesXAt0 = mydata["numTilesX"];
        numTilesYAt0 = mydata["numTilesY"];

        dataBboxWest = mydata["databbox"][0];
        dataBboxSouth = mydata["databbox"][1];
        dataBboxEast = mydata["databbox"][2];
        dataBboxNorth = mydata["databbox"][3];

        tileBboxWest = mydata["tilebbox"][0];
        tileBboxSouth = mydata["tilebbox"][1];
        tileBboxEast = mydata["tilebbox"][2];
        tileBboxNorth = mydata["tilebbox"][3];

        int numDims = mydata["dimensions"].length;

        dimensions = new List<RiaDimension>();
        dimensionMap = new Map<String, RiaDimension>();
        minimums = new Map<String, double>();
        maximums = new Map<String, double>();

        int byteOffset = 0;
        List mydimlist = mydata["dimensions"];
        for (int dimidx = 0; dimidx < numDims; dimidx++) {
            Map mydim = mydimlist[dimidx];

            int dimType = RiaDimension.typemap[mydim["datatype"]];
            String name = mydim["name"];
            double min = mydim["min"];
            double max = mydim["max"];

            var riadim = new RiaDimension(dimType, name, min, max);
            dimensions.add(riadim);
            dimensionMap[name] = riadim;
            minimums[name] = min;
            maximums[name] = max;

            riadim.byteOffset = byteOffset;
            byteOffset += riadim.sizeInBytes;
        }
    }

    int get pointSizeInBytes {
        int sum = 0;
        dimensions.forEach((dim) => sum += dim.sizeInBytes);
        return sum;
    }

    @override
    String toString() {
        return "numPoints=$numPoints, $dimensions";
    }
}
