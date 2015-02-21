// Copyright (c) 2014-2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

#ifndef PDALBRIDGE_HPP
#define PDALBRIDGE_HPP

#include <pdal/PipelineManager.hpp>

class PdalBridge
{
public:
    PdalBridge(bool debug=false, boost::uint32_t verbosity=0);

    ~PdalBridge();

    void open(const std::string& fname, bool doReproj);

    void close();

    int getMetadataCount();
    std::vector<char*> getMetadataKeys();
    std::vector<char*> getMetadataValues();
    
    boost::uint64_t getNumPoints() const;

    const pdal::Dimension::IdList& getDimIds() const;
    pdal::Dimension::Type::Enum getDimType(pdal::Dimension::Id::Enum) const;

    void getStats(pdal::Dimension::Id::Enum id, double& min, double& mean, double& max) const;

    std::string getWkt() const;

    const pdal::PointBufferSet& buffers() const;
   
    void getRect(double& west, double& south, double& east, double& north) const;
   
private:
    std::vector<char*> m_keys;
    std::vector<char*> m_values;

    bool m_doReproj;
    bool m_debug;
    boost::uint32_t m_verbosity;
    pdal::PipelineManager* m_manager;
    pdal::Reader* m_reader;
    pdal::Filter* m_reprojFilter;
    pdal::Filter* m_statsFilter;
    pdal::Writer* m_writer;
    boost::uint64_t m_numPoints;

    pdal::Dimension::IdList m_dimensionIds;
};

#endif
