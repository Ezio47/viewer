// Copyright (c) 2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


// OGC 06-121r3, sec 7.4

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


    static OgcDocument parse(Xml.XmlDocument document) {
        for (var node in document.children) {
            if (node is Xml.XmlElement) {
                switch (node.name.local) {
                    case "Capabilities":
                        return new Ogc_Capabilities(node);
                    case "ExceptionReport":
                        return new Ogc_ExceptionReport(node);
                    case "ProcessDescriptions":
                        return new Ogc_ProcessDescriptions(node);
                    case "ExecuteResponse":
                        return new Ogc_ExecuteResponse(node);
                    default:
                        _unsupported(node);
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
                OgcDocument._unsupported(name);
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
                OgcDocument._unsupported(attr);
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
        log("element not yet unhandled: $e");
        assert(false);
    }

    @override
    String toString() {
        return "[$type]";
    }


    static void _unsupported(var v) {
        if (v is Xml.XmlElement) {
            log("Element type ${v.name.local} not supported");
        } else if (v is Xml.XmlAttribute) {
            log("Attribute type ${v.name.local} not supported");
        }
        log(v);
        assert(false);
    }
}


// table 7
class Ogc_Capabilities extends OgcDocument {

    String service;
    String request;
    String version;
    Ogc_ProcessOfferings processOfferings;

    Ogc_Capabilities(Xml.XmlElement element)
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
            "ProcessOfferings": (e) => processOfferings = new Ogc_ProcessOfferings(e),
            "Languages": _ignoreElement,
        });
    }

    @override String toString() {
        return "[RequestBase]" +
                "Service: $service\n" +
                "Request: $request\n" +
                "Version: $version\n" +
                processOfferings.toString();
    }
}


// table 8
class Ogc_ProcessOfferings extends OgcDocument {

    List<Ogc_ProcessBrief> processes = new List<Ogc_ProcessBrief>();

    Ogc_ProcessOfferings(Xml.XmlElement element)
            : super(element) {

        // table 16
        _registerElements({
            "Process": (e) => processes.add(new Ogc_ProcessBrief(e))
        });
    }

    @override String toString() {
        return "[ProcessOfferings]" + processes.map((p) => p.toString()).join();
    }
}


// table 2
class Ogc_ProcessBrief extends OgcDocument {

    String identifier;
    String title;
    String abstract;

    Ogc_ProcessBrief(Xml.XmlElement element)
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


    @override String toString() {
        return "[Process]\n" + "  Identifier: $identifier\n" + "  Title: $title\n";
    }
}


// table 15
class Ogc_ProcessDescriptions extends OgcDocument {
    List<Ogc_ProcessDescription> descriptions = new List<Ogc_ProcessDescription>();

    Ogc_ProcessDescriptions(Xml.XmlElement element)
            : super(element) {

        _registerElements({
            "ProcessDescription": (e) => descriptions.add(new Ogc_ProcessDescription(e))
        });

        _registerAttributes({
            "service": _ignoreAttribute,
            "version": _ignoreAttribute,
            "lang": _ignoreAttribute
        });
    }

    @override String toString() {
        return "[ProcessDescriptions]\n" + descriptions.map((i) => i.toString()).join();
    }
}


// table 16
class Ogc_ProcessDescription extends OgcDocument {

    String identifier;
    String title;
    String abstract;
    Ogc_Input dataInput;
    Ogc_ProcessOutputs processOutputs;

    Ogc_ProcessDescription(Xml.XmlElement element)
            : super(element) {

        _registerElements({
            "Identifier": (e) => identifier = e.text,
            "Title": (e) => title = e.text,
            "Abstract": (e) => abstract = e.text,
            "Metadata": _ignoreElement,
            "Profile": _errorElement,
            "WSDL": _errorElement,
            "DataInputs": (e) => new Ogc_Input(e),
            "ProcessOutputs": (e) => new Ogc_ProcessOutputs(e),
        });

        _registerAttributes({
            "processVersion": _ignoreAttribute,
            "storeSupported": _ignoreAttribute,
            "statusSupported": _ignoreAttribute
        });
    }


    @override String toString() {
        return "[ProcessDescription]" +
                "Identifier: $identifier\n" +
                "Title: $title\n" +
                processOutputs.toString();
    }
}


// table 19
class Ogc_Input extends OgcDocument {
    List<Ogc_InputDescription> dataInputs = new List<Ogc_InputDescription>();


    Ogc_Input(Xml.XmlElement element) : super(element) {

        // table 19
        _registerElements({
            "Input": (e) => dataInputs.add(new Ogc_InputDescription(e))
        });
    }


    @override String toString() {
        return "[Input]\n";
    }
}

// table 19
class Ogc_InputDescription extends OgcDocument {
    String identifier;
    String title;
    String abstract;
    int minOccurs;
    int maxOccurs;

    Ogc_LiteralInput literalData;

    Ogc_InputDescription(Xml.XmlElement element) : super(element) {

        // table 19
        _registerElements({
            "Identifier": (e) => identifier = e.text,
            "Title": (e) => title = e.text,
            "Abstract": (e) => abstract = e.text,
            "Metadata": _errorElement,

            // InputFormChoice, table 20
            "ComplexData": _ignoreElement,
            "LiteralData": (e) => new Ogc_LiteralInput(e),
            "BoundingBoxData": _errorElement
        });

        _registerAttributes({
            "minOccurs": (attr) => minOccurs = int.parse(attr.value),
            "maxOccurs": (attr) => maxOccurs = int.parse(attr.value),
        });
    }


    @override String toString() {
        return "[InputDescription]\n" + "Identifier: $identifier\n" + "Title: $title\n";
    }
}


// table 25
class Ogc_LiteralInput extends OgcDocument {
    String datatype;
    String defaultValue;
    String allowedValues;
    String anyValue;
    String valuesReference;

    Ogc_LiteralInput(Xml.XmlElement element) : super(element) {

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


    @override String toString() {
        return "[LiteralInput]\n" + "Datatype: $datatype\n" + "DefaultValue: $defaultValue";
    }
}



// table 25
class Ogc_OutputDescription extends OgcDocument {
    String identifier;
    String title;
    String abstract;

    Ogc_OutputDescription(Xml.XmlElement element) : super(element) {

        _registerElements({
            "Identifier": (e) => identifier = e.text,
            "Title": (e) => title = e.text,
            "Abstract": (e) => abstract = e.text,
            "Metadata": _errorElement,

            // OutputFormChoice, table 36
            "ComplexData": _errorElement,
            "LiteralOutput": (e) => new Ogc_LiteralOutput(e),
            "BoundingBoxOutput": _errorElement
        });
    }


    @override String toString() {
        return "[OutputDescription]\n" + "Identifier: $identifier\n" + "Title: $title\n";
    }
}


// table 37
class Ogc_LiteralOutput extends OgcDocument {
    String datatype;

    Ogc_LiteralOutput(Xml.XmlElement element) : super(element) {

        _registerElements({
            "DataType": (e) => datatype = e.text,
            "UOMs": _errorElement,
        });
    }


    @override String toString() {
        return "[LiteralOutput]\n" + "Datatype: $datatype\n";
    }
}


// table 54
class Ogc_ExecuteResponse extends OgcDocument {
    String service;
    String version;
    String statusLocation;
    String serviceInstance;
    Ogc_ProcessBrief process;
    Ogc_Status status;
    Ogc_ProcessOutputs processOutputs;

    List<Ogc_InputDescription> dataInputs = new List<Ogc_InputDescription>();

    Ogc_ExecuteResponse(Xml.XmlElement element)
            : super(element) {

        _registerElements({
            "Process": (e) => process = new Ogc_ProcessBrief(e),
            "Status": (e) => status = new Ogc_Status(e),
            "DataInputs": (e) => dataInputs.add(new Ogc_InputDescription(e)),
            "OutputDefinitions": _errorElement,
            "ProcessOutputs": (e) => processOutputs = new Ogc_ProcessOutputs(e)
        });

        _registerAttributes({
            "service": (attr) => service = attr.value,
            "version": (attr) => version = attr.value,
            "lang": _errorAttribute,
            "statusLocation": (attr) => statusLocation = attr.value,
            "serviceInstance": (attr) => serviceInstance = attr.value,
        });

    }


    @override String toString() {
        return "[ExecuteResponse]\n";
    }
}



// table 55
class Ogc_Status extends OgcDocument {
    String creationTime;
    String processAccepted;
    String processStarted;
    String processPaused;
    String processSucceeded;
    Ogc_ExceptionReport processFailed;

    Ogc_Status(Xml.XmlElement element)
            : super(element) {

        _registerElements({
            "ProcessAccepted": (e) => processAccepted = e.text,
            "ProcessStarted": (e) => processStarted = e.text, // TODO: percent completed
            "ProcessPaused": (e) => processPaused = e.text,
            "ProcessSucceeded": (e) => processSucceeded = e.text,
            "ProcessFailed": (e) => processFailed = new Ogc_ExceptionReport(e)
        });

        _registerAttributes({
            "creationTime": (attr) => creationTime = attr.value,
        });

    }


    @override String toString() {
        return "[Status]\n";
    }
}


// table 59
class Ogc_ProcessOutputs extends OgcDocument {
    List<Ogc_OutputData> outputData = new List<Ogc_OutputData>();

    Ogc_ProcessOutputs(Xml.XmlElement element)
            : super(element) {

        _registerElements({
            "Output": (e) => outputData.add(new Ogc_OutputData(e))
        });
    }


    @override String toString() {
        return "[ProcessOutputs]\n";
    }
}


// table 60
class Ogc_OutputData extends OgcDocument {
    String identifier;
    String title;
    String abstract;
    Ogc_OutputReference outputReference;
    String data;

    Ogc_OutputData(Xml.XmlElement element)
            : super(element) {

        _registerElements({
            "Identifier": (e) => identifier = e.text,
            "Title": (e) => title = e.text,
            "Abstract": (e) => abstract = e.text,
            "Reference": (e) => outputReference = new Ogc_OutputReference(e),
            "Data": _errorElement,
            "ComplexOutput": _ignoreElement,
            "LiteralOutput": _ignoreElement
        });
    }

    @override String toString() {
        return "[OutputData]\n";
    }
}


// table 61
class Ogc_OutputReference extends OgcDocument {
    String format;
    String encoding;
    String schema;
    String href;

    Ogc_OutputReference(Xml.XmlElement element)
            : super(element) {

        _registerAttributes({
            "format": (attr) => format = attr.value,
            "encoding": (attr) => encoding = attr.value,
            "schema": (attr) => schema = attr.value,
            "href": (attr) => href = attr.value
        });
    }


    @override String toString() {
        return "[OutputReference]\n";
    }
}


class Ogc_Exception extends OgcDocument {
    String text;

    Ogc_Exception(Xml.XmlElement element) : super(element) {
        _registerElements({
            "ExceptionText": (e) => text = e.text
        });
    }

    @override String toString() {
        return "[Exception]\n";
    }
}




class Ogc_ExceptionReport extends OgcDocument {

    List<Ogc_Exception> exceptions = new List<Ogc_Exception>();

    Ogc_ExceptionReport(Xml.XmlElement element)
            : super(element) {
        _registerElements({
            "Exception": (e) => exceptions.add(new Ogc_Exception(e))
        });
    }

    @override String toString() {
        return "[ExceptionReport]\n" + exceptions.map((i) => i.toString()).join();
    }
}
