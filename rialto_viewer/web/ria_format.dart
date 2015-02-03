// Copyright (c) 2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


class RiaDimension {
    // thesse are taken from PDAL
    static const int None = 0;
    static const int Unsigned8 = 201;
    static const int Signed8 = 101;
    static const int Unsigned16 = 202;
    static const int Signed16 = 102;
    static const int Unsigned32 = 204;
    static const int Signed32 = 104;
    static const int Unsigned64 = 208;
    static const int Signed64 = 108;
    static const int Float = 0x404;
    static const int Double = 0x408;

    final int type;
    final String name;
    final double min;
    final double max;

    RiaDimension(int this.type, String this.name, double this.min, double this.max);

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

            var dim = new RiaDimension(dimType, name, min, max);
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
