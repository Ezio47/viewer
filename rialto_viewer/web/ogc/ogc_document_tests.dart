// Copyright (c) 2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


class OgcDocumentTests {


// http://beta.sedac.ciesin.columbia.edu/wps/WebProcessingService?Request=GetCapabilities&Service=WPS
// http://beta.sedac.ciesin.columbia.edu/wps/WebProcessingService?Request=DescribeProcess&Service=WPS&identifier=org.ciesin.gis.wps.algorithms.PopStats
// http://beta.sedac.ciesin.columbia.edu/wps/WebProcessingService?Request=DescribeProcess&Service=WPS&identifier=badfunctionname

static String generalException =
r'''
<?xml version="1.0" encoding="UTF-8"?>
<ns:ExceptionReport xmlns:ns="http://www.opengis.net/ows/1.1">
    <ns:Exception exceptionCode="InvalidParameterValue" locator="parameter: identifier | value: badfunctionname">
        <ns:ExceptionText>Algorithm does not exist: badfunctionname</ns:ExceptionText>
    </ns:Exception>
    <ns:Exception exceptionCode="JAVA_StackTrace">
        <ns:ExceptionText>org.n52.wps.server.request.DescribeProcessRequest.call:103
            org.n52.wps.server.handler.RequestHandler.handle:340
            org.n52.wps.server.WebProcessingService.doGet:205
            javax.servlet.http.HttpServlet.service:617
            org.n52.wps.server.WebProcessingService.service:273
            javax.servlet.http.HttpServlet.service:717
            org.apache.catalina.core.ApplicationFilterChain.internalDoFilter:290
            org.apache.catalina.core.ApplicationFilterChain.doFilter:206
            com.planetj.servlet.filter.compression.CompressingFilter.doFilter:217
            org.apache.catalina.core.ApplicationFilterChain.internalDoFilter:235
            org.apache.catalina.core.ApplicationFilterChain.doFilter:206
            org.n52.wps.server.CommunicationSizeLogFilter.doFilter:206
            org.apache.catalina.core.ApplicationFilterChain.internalDoFilter:235
            org.apache.catalina.core.ApplicationFilterChain.doFilter:206
            org.apache.catalina.core.StandardWrapperValve.invoke:233
            org.apache.catalina.core.StandardContextValve.invoke:191
            org.apache.catalina.core.StandardHostValve.invoke:127
            org.apache.catalina.valves.ErrorReportValve.invoke:102
            org.apache.catalina.core.StandardEngineValve.invoke:109
            org.apache.catalina.connector.CoyoteAdapter.service:293
            org.apache.jk.server.JkCoyoteHandler.invoke:190
            org.apache.jk.common.HandlerRequest.invoke:291
            org.apache.jk.common.ChannelSocket.invoke:776
            org.apache.jk.common.ChannelSocket.processConnection:705
            org.apache.jk.common.ChannelSocket$SocketConnection.runIt:898
            org.apache.tomcat.util.threads.ThreadPool$ControlRunnable.run:690
            java.lang.Thread.run:662
        </ns:ExceptionText>
    </ns:Exception>
    <ns:Exception exceptionCode="JAVA_RootCause"/>
</ns:ExceptionReport>''';

static String  describeProcess =
'''
<?xml version="1.0" encoding="UTF-8"?>
<ns:ProcessDescriptions xmlns:ns="http://www.opengis.net/wps/1.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.opengis.net/wps/1.0.0 http://geoserver:8080/wps/schemas/wps/1.0.0/wpsDescribeProcess_response.xsd" xml:lang="en-US" service="WPS" version="1.0.0"><ProcessDescription xmlns:wps="http://www.opengis.net/wps/1.0.0" xmlns:ows="http://www.opengis.net/ows/1.1" xmlns:xlink="http://www.w3.org/1999/xlink" wps:processVersion="2" statusSupported="true" storeSupported="true">
        <ows:Identifier>org.ciesin.gis.wps.algorithms.PopStats</ows:Identifier>
        <ows:Title>Get population statistics for a certain area or set of areas.</ows:Title>
        <ows:Abstract>Accepts a polygon or set of polygons and returns a result set containing population statistics.</ows:Abstract>
        <ows:Metadata xlink:title="spatial"/>
        <ows:Metadata xlink:title="geometry"/>
        <ows:Metadata xlink:title="buffer"/>
        <ows:Metadata xlink:title="GML"/>
        <DataInputs>
            <Input minOccurs="1" maxOccurs="1">
                <ows:Identifier>data</ows:Identifier>
                <ows:Title>Features representing areas.</ows:Title>
                <ows:Abstract>The Areas to Analyze</ows:Abstract>
                <ComplexData>
                <Default>
                    <Format>
                        <MimeType>text/XML</MimeType>
                        <Schema>http://geoserver.itc.nl:8080/wps/schemas/gml/2.1.2/gmlpacket.xsd</Schema>
                    </Format>
                </Default>
                <Supported>
                <Format>
                    <MimeType>text/XML</MimeType>
                    <Schema>http://schemas.opengis.net/gml/2.1.2/feature.xsd</Schema>
                </Format>
                
                </Supported>
                </ComplexData>
            </Input>
        </DataInputs>
        <ProcessOutputs>
            <Output>
                <ows:Identifier>result</ows:Identifier>
                <ows:Title>Buffered Features</ows:Title>
                <ows:Abstract>GML stream describing the buffered features.</ows:Abstract>
                <!--ComplexOutput defaultFormat="text/XML" defaultSchema="http://geoserver.itc.nl:8080/wps/schemas/gml/2.1.2/gmlpacket.xsd"-->
                <ComplexOutput>
                <Default>
                    <Format>
                        <MimeType>text/XML</MimeType>
                        <Schema>http://schemas.opengis.net/gml/2.1.2/feature.xsd</Schema>
                    </Format>
                </Default>
                <Supported>
                    <Format>
                        <MimeType>text/XML</MimeType>
                        <Schema>http://beta.sedac.ciesin.columbia.edu/wps/PopStatsResponse.xsd</Schema>
                    </Format>
                    <Format>
                        <MimeType>text/XML</MimeType>
                        <Schema>http://schemas.opengis.net/gml/2.1.2/feature.xsd</Schema>
                    </Format>
                </Supported>
                </ComplexOutput>
            </Output>
        </ProcessOutputs>
    </ProcessDescription></ns:ProcessDescriptions>''';

static String  describeProcessError =
r'''<?xml version="1.0" encoding="UTF-8"?>
<ns:ExceptionReport xmlns:ns="http://www.opengis.net/ows/1.1"><ns:Exception exceptionCode="MissingParameterValue"><ns:ExceptionText>Parameter &lt;identifier> is not specified</ns:ExceptionText></ns:Exception><ns:Exception exceptionCode="JAVA_StackTrace"><ns:ExceptionText>org.n52.wps.server.request.Request.getMapValue:108
org.n52.wps.server.request.Request.getMapValue:136
org.n52.wps.server.request.DescribeProcessRequest.validate:74
org.n52.wps.server.request.DescribeProcessRequest.call:88
org.n52.wps.server.handler.RequestHandler.handle:340
org.n52.wps.server.WebProcessingService.doGet:205
javax.servlet.http.HttpServlet.service:617
org.n52.wps.server.WebProcessingService.service:273
javax.servlet.http.HttpServlet.service:717
org.apache.catalina.core.ApplicationFilterChain.internalDoFilter:290
org.apache.catalina.core.ApplicationFilterChain.doFilter:206
com.planetj.servlet.filter.compression.CompressingFilter.doFilter:217
org.apache.catalina.core.ApplicationFilterChain.internalDoFilter:235
org.apache.catalina.core.ApplicationFilterChain.doFilter:206
org.n52.wps.server.CommunicationSizeLogFilter.doFilter:206
org.apache.catalina.core.ApplicationFilterChain.internalDoFilter:235
org.apache.catalina.core.ApplicationFilterChain.doFilter:206
org.apache.catalina.core.StandardWrapperValve.invoke:233
org.apache.catalina.core.StandardContextValve.invoke:191
org.apache.catalina.core.StandardHostValve.invoke:127
org.apache.catalina.valves.ErrorReportValve.invoke:102
org.apache.catalina.core.StandardEngineValve.invoke:109
org.apache.catalina.connector.CoyoteAdapter.service:293
org.apache.jk.server.JkCoyoteHandler.invoke:190
org.apache.jk.common.HandlerRequest.invoke:291
org.apache.jk.common.ChannelSocket.invoke:776
org.apache.jk.common.ChannelSocket.processConnection:705
org.apache.jk.common.ChannelSocket$SocketConnection.runIt:898
org.apache.tomcat.util.threads.ThreadPool$ControlRunnable.run:690
java.lang.Thread.run:662
</ns:ExceptionText></ns:Exception><ns:Exception exceptionCode="JAVA_RootCause"/></ns:ExceptionReport>''';

static String capabilities =
'''<?xml version="1.0" encoding="UTF-8"?>
<wps:Capabilities service="WPS" version="1.0.0" xml:lang="en-US" xsi:schemaLocation="http://www.opengis.net/wps/1.0.0 http://geoserver.itc.nl:8080/wps/schemas/wps/1.0.0/wpsGetCapabilities_response.xsd" updateSequence="1" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:wps="http://www.opengis.net/wps/1.0.0" xmlns:ows="http://www.opengis.net/ows/1.1" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
    <ows:ServiceIdentification>
        <ows:Title>CIESIN Population Statistics WPS</ows:Title>
        <ows:Abstract>Estimates population counts (persons, 2005) within provided polygon features.  Uses Gridded Population of the World, version 3, population estimates, land areas (square km), and mean administrative unit area (square km) to generate a table containing the population estimate(s) and summary statistics.  For more detail see: http://beta.sedac.ciesin.columbia.edu/mapservices/arcgis/server/proxyoutput/sedac_GPW/PopStatsFeatures.htm</ows:Abstract>
        <ows:Keywords>
            <ows:Keyword>WPS</ows:Keyword>
            <ows:Keyword>Population</ows:Keyword>
            <ows:Keyword>GPW</ows:Keyword>
            <ows:Keyword>geoprocessing</ows:Keyword>
        </ows:Keywords>
        <ows:ServiceType>WPS</ows:ServiceType>
        <ows:ServiceTypeVersion>1.0.0</ows:ServiceTypeVersion>
        <ows:ServiceTypeVersion>0.4.0</ows:ServiceTypeVersion>
        <ows:Fees>NONE</ows:Fees>
        <ows:AccessConstraints>NONE</ows:AccessConstraints>
    </ows:ServiceIdentification>
    <ows:ServiceProvider>
        <ows:ProviderName>SEDAC</ows:ProviderName>
        <ows:ServiceContact>
            <ows:IndividualName>SEDAC User Services</ows:IndividualName>
            <ows:ContactInfo>
                <ows:Phone>
                    <ows:Voice/>
                    <ows:Facsimile/>
                </ows:Phone>
                <ows:Address>
                    <ows:DeliveryPoint/>
                    <ows:City/>
                    <ows:AdministrativeArea/>
                    <ows:PostalCode/>
                    <ows:Country/>
                    <ows:ElectronicMailAddress>ciesin.info@ciesin.columbia.edu</ows:ElectronicMailAddress>
                </ows:Address>
            </ows:ContactInfo>
        </ows:ServiceContact>
    </ows:ServiceProvider>
    <ows:OperationsMetadata>
        <ows:Operation name="GetCapabilities">
            <ows:DCP>
                <ows:HTTP>
                    <ows:Get xlink:href="http://beta.sedac.ciesin.columbia.edu:80/wps/WebProcessingService"/>
                </ows:HTTP>
            </ows:DCP>
        </ows:Operation>
        <ows:Operation name="DescribeProcess">
            <ows:DCP>
                <ows:HTTP>
                    <ows:Get xlink:href="http://beta.sedac.ciesin.columbia.edu:80/wps/WebProcessingService"/>
                    
                </ows:HTTP>
            </ows:DCP>
        </ows:Operation>
        <ows:Operation name="Execute">
            <ows:DCP>
                <ows:HTTP>
                    <ows:Get xlink:href="http://beta.sedac.ciesin.columbia.edu:80/wps/WebProcessingService"/>
                    <ows:Post xlink:href="http://beta.sedac.ciesin.columbia.edu:80/wps/WebProcessingService"/>
                </ows:HTTP>
            </ows:DCP>
        </ows:Operation>
    </ows:OperationsMetadata>
    
    <wps:ProcessOfferings><wps:Process wps:processVersion="2"><ows:Identifier>org.ciesin.gis.wps.algorithms.PopStats</ows:Identifier><ows:Title>Get population statistics for a certain area or set of areas.</ows:Title></wps:Process></wps:ProcessOfferings><wps:Languages>
        <wps:Default>
            <ows:Language>en-US</ows:Language>
        </wps:Default>
        <wps:Supported>
            <ows:Language>en-US</ows:Language>
        </wps:Supported>
    </wps:Languages> 

</wps:Capabilities>''';

}
