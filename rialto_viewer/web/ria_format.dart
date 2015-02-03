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

    final int type;
    final String name;
    final double min;
    final double max;
    final int numPoints;

    List list;
    Function getter;

    RiaDimension(int this.type, String this.name, double this.min, double this.max, int this.numPoints) {
        Function f;
        switch (type) {
            case Unsigned8:
                list = new Uint8List(numPoints);
                f = (ByteData buf, int index) => buf.getUint8(index);
                break;
            case Signed8:
                list = new Int8List(numPoints);
                f = (ByteData buf, int index) => buf.getInt8(index);
                break;
            case Unsigned16:
                list = new Uint16List(numPoints);
                f = (ByteData buf, int index) => buf.getUint16(index, Endianness.LITTLE_ENDIAN);
                break;
            case Signed16:
                list = new Int16List(numPoints);
                f = (ByteData buf, int index) => buf.getInt16(index, Endianness.LITTLE_ENDIAN);
                break;
            case Unsigned32:
                list = new Uint32List(numPoints);
                f = (ByteData buf, int index) => buf.getUint32(index, Endianness.LITTLE_ENDIAN);
                break;
            case Signed32:
                list = new Int32List(numPoints);
                f = (ByteData buf, int index) => buf.getInt32(index, Endianness.LITTLE_ENDIAN);
                break;
            case Unsigned64:
                list = new Uint64List(numPoints);
                f = (ByteData buf, int index) => buf.getUint64(index, Endianness.LITTLE_ENDIAN);
                break;
            case Signed64:
                list = new Int64List(numPoints);
                f = (ByteData buf, int index) => buf.getInt64(index, Endianness.LITTLE_ENDIAN);
                break;
            case Float:
                list = new Float32List(numPoints);
                f = (ByteData buf, int index) => buf.getFloat32(index, Endianness.LITTLE_ENDIAN);
                break;
            case Double:
                list = new Float64List(numPoints);
                f = ((ByteData buf, int index) {
                    var v = buf.getFloat64(index, Endianness.LITTLE_ENDIAN);
                    return v;
                    });
                break;
            default:
                assert(false);
                break;
        }

        getter = f;
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
    int numPoints;

    RiaFormat();

    void readHeader(ByteData buf) {
        int index = 0;

        int version = buf.getUint8(index);
        index += 1;

        numPoints = buf.getUint64(index, Endianness.LITTLE_ENDIAN);
        index += 8;

        int numDims = buf.getUint8(index);
        index += 1;

        dimensions = new List<RiaDimension>();

        for (int dim = 0; dim < numDims; dim++) {
            int dimType = buf.getUint16(index, Endianness.LITTLE_ENDIAN);
            index += 2;

            int nameLen = buf.getUint8(index);
            index += 1;

            var chars = new List<int>();
            for (int i = 0; i < nameLen; i++) {
                int c = buf.getUint8(index);
                index += 1;
                chars.add(c);
            }
            String name = UTF8.decode(chars);

            double min = buf.getFloat64(index, Endianness.LITTLE_ENDIAN);
            index += 8;

            double max = buf.getFloat64(index, Endianness.LITTLE_ENDIAN);
            index += 8;

            var dim = new RiaDimension(dimType, name, min, max, numPoints);
            dimensions.add(dim);
        }

        //assert(index == buf.lengthInBytes);
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
