// Copyright (c) 2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


// OGC 06-121r3, sec 7.4
// class names are from the spec document and have their table number from the spec appended

// TODO: we should respect namespace prefixes on element names

typedef void _ParseElementFunction(Xml.XmlElement e);
typedef void _ParseAttributeFunction(Xml.XmlAttribute v);


class OgcDocument {

    Xml.XmlElement element;
    String type;
    Map<String, _ParseElementFunction> elementsMap = new Map<String, _ParseElementFunction>();
    Map<String, _ParseAttributeFunction> attributesMap = new Map<String, _ParseAttributeFunction>();

    OgcDocument(Xml.XmlElement this.element) {
        type = element.name.local;
    }

    static OgcDocument parseString(String text) {
        var xmlDoc = Xml.parse(text);
        var ogcDoc = parseXml(xmlDoc);
        return ogcDoc;
    }

    static OgcDocument parseXml(Xml.XmlDocument document) {
        for (var elem in document.children) {
            if (elem is Xml.XmlElement) {
                switch (elem.name.local) {
                    case "Capabilities":
                        return new OgcCapabilities_7(elem);
                    case "ExceptionReport":
                        return new OgcExceptionReportDocument(elem);
                    case "ProcessDescriptions":
                        return new OgcProcessDescriptions_15(elem);
                    case "ExecuteResponse":
                        return new OgcExecuteResponseDocument_54(elem);
                    default:
                        log("Unhandled top-level doc type: ${elem.name.local}");
                        assert(false);
                        break;
                }
            }
        }
        return null;
    }


    static Xml.XmlElement _getElement(List<Xml.XmlNode> nodes, String name) {
        var element = nodes.firstWhere((node) => _nameIs(node, name));
        return element;
    }


    static bool _nameIs(Xml.XmlNode node, String name) => (node is Xml.XmlElement && node.name.local == name);


    void _registerElements(Map<String, _ParseElementFunction> map) {
        for (var k in map.keys) {
            elementsMap[k] = map[k];
        }

        _parseElements();
    }

    void _registerAttributes(Map<String, _ParseAttributeFunction> map) {
        for (var k in map.keys) {
            attributesMap[k] = map[k];
        }

        _parseAttributes();
    }

    void _parseElements() {

        for (var elem in element.children) {
            if (elem is! Xml.XmlElement) continue;

            var name = elem.name.local;

            if (!elementsMap.containsKey(name)) {
                _errorElement(elem);
            }

            var f = elementsMap[name];
            assert(f != null);

            f(elem);
        }
    }

    void _parseAttributes() {

        for (var attr in element.attributes) {
            if (attr is! Xml.XmlAttribute) continue;

            if (attr.name.prefix == "xmlns") continue;
            if (attr.name.prefix == "xsi") continue;

            var name = attr.name.local;
            var value = attr.value;

            if (!attributesMap.containsKey(name)) {
                _errorAttribute(attr);
            }

            var f = attributesMap[name];
            assert(f != null);

            f(attr);
        }
    }

    void _ignoreAttribute(Xml.XmlAttribute t) {}
    void _ignoreElement(Xml.XmlElement e) {}

    void _errorAttribute(Xml.XmlAttribute t) {
        log("attribute not yet handled: $t");
        assert(false);
    }

    void _errorElement(Xml.XmlElement e) {
        log("element not yet handled: $e");
        assert(false);
    }

    String dump(int indent) {
        return pad(indent) + "[$type]";
    }

    String pad(int indent) => "    " * indent;
}


class OgcProcessBrief_2 extends OgcDocument {

    String identifier;
    String title;
    String abstract;

    OgcProcessBrief_2(Xml.XmlElement element)
            : super(element) {

        _registerElements({
            "Identifier": (e) => identifier = e.text,
            "Title": (e) => title = e.text,
            "Abstract": (e) => abstract = e.text,
            "Metadata": _errorElement,
            "Profile": _errorElement,
            "WSDL": _errorElement,
            "ProcessVersion": _errorElement,
        });
    }


    @override String dump(int indent) {
        String s = "";
        s += pad(indent) + "[ProcessBrief]\n";
        s += pad(indent + 1) + "Identifier: $identifier\n";
        s += pad(indent + 1) + "Title: $title\n";
        return s;
    }
}


class OgcCapabilities_7 extends OgcDocument {

    String service;
    String version;
    OgcProcessOfferings_8 processOfferings;

    OgcCapabilities_7(Xml.XmlElement element)
            : super(element) {

        var a = element.attributes[0];

        _registerAttributes({
            "service": (attr) => service = attr.value,
            "version": (attr) => version = attr.value,
            "updateSequence": _ignoreAttribute,
            "lang": _ignoreAttribute,
        });

        _registerElements({
            "ServiceIdentification": _ignoreElement,
            "ServiceProvider": _ignoreElement,
            "OperationsMetadata": _ignoreElement,
            "ProcessOfferings": (e) => processOfferings = new OgcProcessOfferings_8(e),
            "Languages": _ignoreElement,
        });
    }

    @override String dump(int indent) {
        return pad(indent) +
                "[RequestBase]" +
                "Service: $service\n" +
                "Version: $version\n" +
                processOfferings.dump(indent + 1);
    }
}


class OgcProcessOfferings_8 extends OgcDocument {

    List<OgcProcessBrief_2> processes = new List<OgcProcessBrief_2>();

    OgcProcessOfferings_8(Xml.XmlElement element)
            : super(element) {

        // table 16
        _registerElements({
            "Process": (e) => processes.add(new OgcProcessBrief_2(e))
        });
    }

    @override String dump(int indent) {
        String s = "";
        s += pad(indent) + "[ProcessOfferings]\n";
        processes.forEach((p) => s += p.dump(indent + 1));
        return s;
    }
}


class OgcProcessDescriptions_15 extends OgcDocument {
    List<OgcProcessDescription_16> descriptions = new List<OgcProcessDescription_16>();

    OgcProcessDescriptions_15(Xml.XmlElement element)
            : super(element) {

        _registerElements({
            "ProcessDescription": (e) => descriptions.add(new OgcProcessDescription_16(e))
        });

        _registerAttributes({
            "service": _ignoreAttribute,
            "version": _ignoreAttribute,
            "lang": _ignoreAttribute
        });
    }

    @override String dump(int indent) {
        return pad(indent) + "[ProcessDescriptions]\n" + descriptions.map((i) => i.dump(indent + 1)).join();
    }
}


class OgcProcessDescription_16 extends OgcDocument {

    String identifier;
    String title;
    String abstract;
    OgcInput_18 dataInput;
    OgcProcessOutputs_34 processOutputs;

    OgcProcessDescription_16(Xml.XmlElement element)
            : super(element) {

        _registerElements({
            "Identifier": (e) => identifier = e.text,
            "Title": (e) => title = e.text,
            "Abstract": (e) => abstract = e.text,
            "Metadata": _ignoreElement,
            "Profile": _errorElement,
            "WSDL": _errorElement,
            "DataInputs": (e) => dataInput = new OgcInput_18(e),
            "ProcessOutputs": (e) => processOutputs = new OgcProcessOutputs_34(e),
        });

        _registerAttributes({
            "processVersion": _ignoreAttribute,
            "storeSupported": _ignoreAttribute,
            "statusSupported": _ignoreAttribute
        });
    }


    @override String dump(int indent) {
        String s = "";
        s += pad(indent) + "[ProcessDescription]\n";
        s += pad(indent + 1) + "Identifier: $identifier\n";
        s += pad(indent + 1) + "Title: $title\n";
        s += dataInput.dump(indent + 1);
        s += processOutputs.dump(indent + 1);
        return s;
    }
}


class OgcInput_18 extends OgcDocument {
    List<OgcInputDescription_19> dataInputs = new List<OgcInputDescription_19>();


    OgcInput_18(Xml.XmlElement element) : super(element) {

        // table 19
        _registerElements({
            "Input": (e) => dataInputs.add(new OgcInputDescription_19(e))
        });
    }


    @override String dump(int indent) {
        String s = "";
        s += pad(indent) + "[Input]\n";
        dataInputs.forEach((i) => s += i.dump(indent + 1));
        return s;
    }
}


class OgcInputDescription_19 extends OgcDocument {
    String identifier;
    String title;
    String abstract;
    int minOccurs;
    int maxOccurs;

    OgcLiteralInput_25 literalData;

    OgcInputDescription_19(Xml.XmlElement element) : super(element) {

        // table 19
        _registerElements({
            "Identifier": (e) => identifier = e.text,
            "Title": (e) => title = e.text,
            "Abstract": (e) => abstract = e.text,
            "Metadata": _errorElement,

            // InputFormChoice, table 20
            "ComplexData": _ignoreElement,
            "LiteralData": (e) => new OgcLiteralInput_25(e),
            "BoundingBoxData": _errorElement
        });

        _registerAttributes({
            "minOccurs": (attr) => minOccurs = int.parse(attr.value),
            "maxOccurs": (attr) => maxOccurs = int.parse(attr.value),
        });
    }


    @override String dump(int indent) {
        String s = "";
        s += pad(indent) + "[InputDescription]\n";
        s += pad(indent + 1) + "Identifier: $identifier\n";
        return s;
    }
}


class OgcLiteralInput_25 extends OgcDocument {
    String datatype;
    String defaultValue;
    String allowedValues;
    String anyValue;
    String valuesReference;

    OgcLiteralInput_25(Xml.XmlElement element) : super(element) {

        _registerElements({
            "DataType": (e) => datatype = e.text,
            "UOMs": _errorElement,
            "DefaultValue": (e) => defaultValue = e.text,

            // LiteralValuesChoice, table 29
            "AllowedValues": (e) => allowedValues = e.text,
            "AnyValue": (e) => anyValue = e.text,
            "ValuesReference": (e) => e.text
        });
    }


    @override String dump(int indent) {
        return pad(indent) + "[LiteralInput]\n" + "Datatype: $datatype\n" + "DefaultValue: $defaultValue";
    }
}


class OgcProcessOutputs_34 extends OgcDocument {
    List<OgcOutputDescription_35> outputData = new List<OgcOutputDescription_35>();

    OgcProcessOutputs_34(Xml.XmlElement element)
            : super(element) {

        _registerElements({
            "Output": (e) => outputData.add(new OgcOutputDescription_35(e))
        });
    }


    @override String dump(int indent) {
        String s = "";
        s += pad(indent) + "[ProcessOutputs34]\n";
        outputData.forEach((i) => s += i.dump(indent + 1));
        return s;
    }
}


class OgcOutputDescription_35 extends OgcDocument {
    String identifier;
    String title;
    String abstract;
    OgcLiteralOutput_37 literalOutput;

    OgcOutputDescription_35(Xml.XmlElement element) : super(element) {

        _registerElements({
            "Identifier": (e) => identifier = e.text,
            "Title": (e) => title = e.text,
            "Abstract": (e) => abstract = e.text,
            "Metadata": _errorElement,

            // OutputFormChoice, table 36
            "ComplexOutput": _ignoreElement,
            "LiteralOutput": (e) => new OgcLiteralOutput_37(e),
            "BoundingBoxOutput": _errorElement
        });
    }


    @override String dump(int indent) {
        String s = "";
        s += pad(indent) + "[OutputDescription35]\n";
        s += pad(indent + 1) + "Identifier: $identifier\n";
        return s;
    }
}


class OgcLiteralOutput_37 extends OgcDocument {
    String datatype;

    OgcLiteralOutput_37(Xml.XmlElement element) : super(element) {

        _registerElements({
            "DataType": (e) => datatype = e.text,
            "UOMs": _errorElement,
        });
    }


    @override String dump(int indent) {
        return pad(indent) + "[LiteralOutput37]\n" + "Datatype: $datatype\n";
    }
}


class OgcDataInputs_40 extends OgcDocument {
    OgcInputType_41 inputType;

    OgcDataInputs_40(Xml.XmlElement element) : super(element) {

        _registerElements({
            "Input": (e) => inputType = new OgcInputType_41(e)
        });

        _registerAttributes({});
    }

    @override String dump(int indent) {
        String s = "";
        s += pad(indent) + "[DataInputs40]\n";
        s += inputType.dump(indent + 1);
        return s;
    }
}


class OgcInputType_41 extends OgcDocument {
    String identifier;
    String title;
    String abstract;
    OgcDataType_46 dataType;

    OgcInputType_41(Xml.XmlElement element) : super(element) {

        _registerElements({
            "Identifier": (e) => identifier = e.text,
            "Title": (e) => title = e.text,
            "Abstract": (e) => abstract = e.text,

            // InputDataFormChoice, table 42
            "Reference": _errorElement,
            "Data": (e) => dataType = new OgcDataType_46(e)
        });

        _registerAttributes({});
    }

    @override String dump(int indent) {
        String s = "";
        s += pad(indent) + "[InputType41]\n";
        return s;
    }
}


class OgcDataType_46 extends OgcDocument {
    OgcLiteralData_48 literalData;

    OgcDataType_46(Xml.XmlElement element)
            : super(element) {

        _registerElements({
            "ComplexData": _ignoreElement,
            "LiteralData": (e) => literalData = new OgcLiteralData_48(e),
            "BoundingBoxData": _ignoreElement,
        });
    }


    @override String dump(int indent) {
        String s = "";
        s += pad(indent) + "[DataType]\n";

        if (literalData == null) {
            s += pad(indent + 1) + "<<unparsed data payload>>\n";
        } else {
            s += literalData.dump(indent + 1);
        }
        return s;
    }
}


class OgcLiteralData_48 extends OgcDocument {
    String value;

    OgcLiteralData_48(Xml.XmlElement element) : super(element) {

        _registerAttributes({
            "datatype": _errorAttribute,
            "uom": _errorAttribute,
        });

        value = element.text;
    }


    @override String dump(int indent) {
        String s = "";
        s += pad(indent) + "[LiteralData48]\n";
        s += pad(indent + 1) + "Value: $value\n";
        return s;
    }
}


class OgcOutput_51 extends OgcDocument {
    String mimeType;
    String encoding;
    String schema;
    String uom;
    bool asReference;
    String identifier;
    String title;
    String abstract;

    OgcOutput_51(Xml.XmlElement element)
            : super(element) {

        _registerElements({
            "mimeType": (e) => mimeType = e.text,
            "encoding": (e) => encoding = e.text,
            "schema": (e) => schema = e.text,
            "uom": (e) => uom = e.text,
            "identifier": (e) => identifier = e.text,
            "title": (e) => title = e.text,
            "abstract": (e) => abstract = e.text

        });

        _registerAttributes({
            "asReference": (e) => asReference = Utils.boolParse(e.value)
        });
    }

    @override String dump(int indent) {
        String s = "";
        s += pad(indent) + "[Output_51]\n";
        s += pad(indent + 1) + "MimeType: $mimeType\n";
        s += pad(indent + 1) + "Encoding: encoding\n";
        s += pad(indent + 1) + "Schema: $schema\n";
        s += pad(indent + 1) + "Uom: uom\n";
        s += pad(indent + 1) + "AsReference: $asReference\n";
        s += pad(indent + 1) + "Identifier: identifier\n";
        s += pad(indent + 1) + "Title: title\n";
        s += pad(indent + 1) + "Abstract: abstract\n";
        return s;
    }
}



class OgcExecuteResponseDocument_54 extends OgcDocument {
    String service;
    String version;
    String statusLocation;
    String serviceInstance;
    OgcProcessBrief_2 processBrief;
    OgcStatus_55 status;
    List<OgcOutputDefinitions_58> outputDefintions = new List<OgcOutputDefinitions_58>();
    OgcProcessOutputs_59 processOutputs;

    List<OgcDataInputs_40> dataInputs = new List<OgcDataInputs_40>();

    OgcExecuteResponseDocument_54(Xml.XmlElement element)
            : super(element) {

        _registerElements({
            "Process": (e) => processBrief = new OgcProcessBrief_2(e),
            "Status": (e) => status = new OgcStatus_55(e),
            "DataInputs": (e) => dataInputs.add(new OgcDataInputs_40(e)),
            "OutputDefinitions": (e) => outputDefintions.add(new OgcOutputDefinitions_58(e)),
            "ProcessOutputs": (e) => processOutputs = new OgcProcessOutputs_59(e)
        });

        _registerAttributes({
            "service": (attr) => service = attr.value,
            "version": (attr) => version = attr.value,
            "lang": _ignoreAttribute,
            "statusLocation": (attr) => statusLocation = attr.value,
            "serviceInstance": (attr) => serviceInstance = attr.value,
        });

    }


    @override String dump(int indent) {
        String s = "";
        s += pad(indent) + "[ExecuteResponse]\n";
        s += pad(indent + 1) + "StatusLocation: $statusLocation\n";
        s += status.dump(indent + 1);
        s += processBrief.dump(indent + 1);
        if (processOutputs != null) {
            s += processOutputs.dump(indent + 1);
        }
        return s;
    }
}


class OgcStatus_55 extends OgcDocument {
    static const int STATUS_INVALID = 0;
    static const int STATUS_ACCEPTED = 1;
    static const int STATUS_STARTED = 2;
    static const int STATUS_PAUSED = 3;
    static const int STATUS_SUCCEEDED = 4;
    static const int STATUS_FAILED = 5;

    String creationTime;
    String processAccepted;
    String processStarted;
    String processPaused;
    String processSucceeded;
    OgcProcessFailed_57 processFailed;

    OgcStatus_55(Xml.XmlElement element)
            : super(element) {

        _registerElements({
            "ProcessAccepted": (e) => processAccepted = e.text,
            "ProcessStarted": (e) => processStarted = e.text, // TODO: percent completed
            "ProcessPaused": (e) => processPaused = e.text,
            "ProcessSucceeded": (e) => processSucceeded = e.text,
            "ProcessFailed": (e) => processFailed = new OgcProcessFailed_57(e)
        });

        _registerAttributes({
            "creationTime": (attr) => creationTime = attr.value,
        });
    }

    int get code {
        if (processAccepted != null) return STATUS_ACCEPTED;
        if (processStarted != null) return STATUS_STARTED;
        if (processPaused != null) return STATUS_PAUSED;
        if (processSucceeded != null) return STATUS_SUCCEEDED;
        if (processFailed != null) return STATUS_FAILED;
        return STATUS_INVALID;
    }

    @override String dump(int indent) {
        String s = "";
        s += pad(indent) + "[Status]\n";
        s += pad(indent + 1) + "creationTime: $creationTime\n";
        s += pad(indent + 1) + "processAccepted: $processAccepted\n";
        s += pad(indent + 1) + "processStarted: $processStarted\n";
        s += pad(indent + 1) + "processPaused: $processPaused\n";
        s += pad(indent + 1) + "processSucceeded: $processSucceeded\n";
        if (processFailed != null) {
            s += processFailed.dump(indent + 1);
        }
        return s;
    }
}


class OgcProcessFailed_57 extends OgcDocument {
    OgcExceptionReportDocument exceptionReport;

    OgcProcessFailed_57(Xml.XmlElement element)
            : super(element) {

        _registerElements({
            "ExceptionReport": (e) => exceptionReport = new OgcExceptionReportDocument(e)
        });

        _registerAttributes({});
    }

    @override String dump(int indent) {
        String s = "";
        s += pad(indent) + "[ProcessFailed]\n";
        s += exceptionReport.dump(indent + 1);
        return s;
    }
}


class OgcOutputDefinitions_58 extends OgcDocument {
    OgcOutput_51 output;

    OgcOutputDefinitions_58(Xml.XmlElement element)
            : super(element) {

        _registerElements({
            "Output": (e) => output = new OgcOutput_51(e)
        });

        _registerAttributes({});
    }

    @override String dump(int indent) {
        String s = "";
        s += pad(indent) + "[ProcessFailed]\n";
        s += output.dump(indent + 1);
        return s;
    }
}


class OgcProcessOutputs_59 extends OgcDocument {
    List<OgcOutputData_60> outputData = new List<OgcOutputData_60>();

    OgcProcessOutputs_59(Xml.XmlElement element)
            : super(element) {

        _registerElements({
            "Output": (e) => outputData.add(new OgcOutputData_60(e))
        });
    }


    @override String dump(int indent) {
        String s = "";
        s += pad(indent) + "[ProcessOutputs59]\n";
        outputData.forEach((i) => s += i.dump(indent + 1));
        return s;
    }
}


class OgcOutputData_60 extends OgcDocument {
    String identifier;
    String title;
    String abstract;
    OgcOutputReference_61 outputReference;
    OgcDataType_46 data;

    OgcOutputData_60(Xml.XmlElement element)
            : super(element) {

        _registerElements({
            "Identifier": (e) => identifier = e.text,
            "Title": (e) => title = e.text,
            "Abstract": (e) => abstract = e.text,

            "Reference": (e) => outputReference = new OgcOutputReference_61(e),

            "Data": (e) => data = new OgcDataType_46(e),
        });
    }

    @override String dump(int indent) {
        String s = "";
        s += pad(indent) + "[OutputData60]\n";
        s += pad(indent + 1) + "Title: $title\n";
        s += data.dump(indent + 1);
        return s;
    }
}


class OgcOutputReference_61 extends OgcDocument {
    String format;
    String encoding;
    String schema;
    String href;

    OgcOutputReference_61(Xml.XmlElement element)
            : super(element) {

        _registerAttributes({
            "format": (attr) => format = attr.value,
            "encoding": (attr) => encoding = attr.value,
            "schema": (attr) => schema = attr.value,
            "href": (attr) => href = attr.value
        });
    }


    @override String dump(int indent) {
        return pad(indent) + "[OutputReference]\n";
    }
}


class Ogc_Exception extends OgcDocument {
    String text;

    Ogc_Exception(Xml.XmlElement element) : super(element) {
        _registerElements({
            "ExceptionText": (e) => text = e.text
        });
    }

    @override String dump(int indent) {
        String s = "";
        s += pad(indent) + "[Exception]\n";
        s += pad(indent + 1) + "Text: $text\n";
        return s;
    }
}




class OgcExceptionReportDocument extends OgcDocument {

    List<Ogc_Exception> exceptions = new List<Ogc_Exception>();

    OgcExceptionReportDocument(Xml.XmlElement element)
            : super(element) {
        _registerElements({
            "Exception": (e) => exceptions.add(new Ogc_Exception(e))
        });
    }

    @override String dump(int indent) {
        String s = "";
        s += pad(indent) + "[ExceptionReport]\n";
        exceptions.forEach((i) => s += i.dump(indent + 1));
        return s;
    }
}


// ProcessDescription
//   DataInputs
//     Input
//       ComplexData
//         Default
//         Supported
//   ProcessOutputs - 34
//     Output
//       ComplexOutput
//         Default
//         Supported

// <wps:Output>
//   <wps:Data>
//     <wps:LiteralData>
