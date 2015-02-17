// Copyright (c) 2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


// OGC 06-121r3, sec 7.4

// TODO: we should respect namespace prefixes on element names

typedef void _ParseFunction(Xml.XmlElement e);


class OgcDocument {

    Xml.XmlElement element;
    String type;


    OgcDocument(Xml.XmlElement this.element, String this.type) {
        assert(type != null);
        log(element.name.local);
        log(type);
        assert(element.name.local == type);
    }


    static OgcDocument parse(Xml.XmlDocument document) {
        for (var node in document.children) {
            if (node is Xml.XmlElement) {
                switch (node.name.local) {
                    case "Capabilities":
                        return new OgcDocument_Capabilities(node);
                    case "ExceptionReport":
                        return new OgcDocument_ExceptionReport(node);
                    case "ProcessDescriptions":
                        return new OgcDocument_ProcessDescriptions(node);
                    case "ExecuteResponse":
                        return new OgcDocument_ExecuteResponse(node);
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


    void _parseElements(_ParseFunction parser) {
        for (var node in element.children) {
            if (node is Xml.XmlElement) {
                parser(node);
            }
        }
    }


    @override
    String toString() {
        return "[$type]";
    }


    static void _unsupported(Xml.XmlElement element) {
        log("Element type ${element.name.local} not supported");
    }
}


class OgcDocument_OwsServiceIdentification extends OgcDocument {

    OgcDocument_OwsServiceIdentification(Xml.XmlElement element)
            : super(element, "ServiceIdentification");


    @override String toString() {
        return "[ServiceIdentification]\n";
    }
}


class OgcDocument_OwsServiceProvider extends OgcDocument {

    OgcDocument_OwsServiceProvider(Xml.XmlElement element)
            : super(element, "ServiceProvider");


    @override String toString() {
        return "[ServiceProvider]\n";
    }
}


class OgcDocument_OwsOperationsMetadata extends OgcDocument {

    OgcDocument_OwsOperationsMetadata(Xml.XmlElement element)
            : super(element, "OperationsMetadata");


    @override String toString() {
        return "[OperationsMetadata]\n";
    }
}


class OgcDocument_Process extends OgcDocument {

    String identifier;
    String title;
    String abstract;


    OgcDocument_Process(Xml.XmlElement element)
            : super(element, "Process") {
        _parseElements((element) {
            switch (element.name.local) {
                case "Identifier":
                    identifier = element.text;
                    break;
                case "Title":
                    title = element.text;
                    break;
                case "Abstract":
                    abstract = element.text;
                    break;
                default:
                    OgcDocument._unsupported(element);
                    break;
            }
        });
    }


    @override String toString() {
        return "[Process]\n" + "  Identifier: $identifier\n" + "  Title: $title\n";
    }
}


class OgcDocument_ProcessOfferings extends OgcDocument {

    List<OgcDocument_Process> processes = new List<OgcDocument_Process>();


    OgcDocument_ProcessOfferings(Xml.XmlElement element)
            : super(element, "ProcessOfferings") {
        _parseElements((element) {
            switch (element.name.local) {
                case "Process":
                    processes.add(new OgcDocument_Process(element));
                    break;

                default:
                    OgcDocument._unsupported(element);
                    break;
            }
        });
    }


    @override String toString() {
        String s = "[ProcessOfferings]\n";
        processes.forEach((p) => s += p.toString());
        return s;
    }
}


class OgcDocument_Exception extends OgcDocument {

    OgcDocument_Exception(Xml.XmlElement element) : super(element, "Exception");


    @override String toString() {
        return "[Exception]\n";
    }
}


class OgcDocument_ExecuteResponse extends OgcDocument {

    OgcDocument_ExecuteResponse(Xml.XmlElement element)
            : super(element, "ExecuteResponse") {
        _parseElements((element) {
            switch (element.name.local) {
                default:
                    OgcDocument._unsupported(element);
                    break;
            }
        });
    }


    @override String toString() {
        return "[ExecuteResponse]\n";
    }
}


class OgcDocument_Capabilities extends OgcDocument {

    OgcDocument_OwsServiceIdentification serviceIdentification;
    OgcDocument_OwsServiceProvider serviceProvider;
    OgcDocument_OwsOperationsMetadata operationsMetadata;
    OgcDocument_ProcessOfferings processOfferings;


    OgcDocument_Capabilities(Xml.XmlElement element)
            : super(element, "Capabilities") {
        _parseElements((element) {
            switch (element.name.local) {
                case "ServiceIdentification":
                    serviceIdentification = new OgcDocument_OwsServiceIdentification(element);
                    break;
                case "ServiceProvider":
                    serviceProvider = new OgcDocument_OwsServiceProvider(element);
                    break;
                case "OperationsMetadata":
                    operationsMetadata = new OgcDocument_OwsOperationsMetadata(element);
                    break;
                case "ProcessOfferings":
                    processOfferings = new OgcDocument_ProcessOfferings(element);
                    break;
                case "Languages":
                    break;
                default:
                    OgcDocument._unsupported(element);
                    break;
            }
        });
    }


    @override String toString() {
        return "[Capabilities]\n" +
                serviceIdentification.toString() +
                serviceProvider.toString() +
                operationsMetadata.toString() +
                processOfferings.toString();
    }
}


class OgcDocument_Input extends OgcDocument {
    String identifier;
    String title;

    OgcDocument_Input(Xml.XmlElement element) : super(element, "Input") {
        _parseElements((element) {
            switch (element.name.local) {
                case "Identifier":
                    identifier = element.text;
                    break;
                case "Title":
                    title = element.text;
                    break;
                case "Abstract":
                case "ComplexData":
                    // ignore
                    break;
                default:
                    OgcDocument._unsupported(element);
                    break;
            }
        });
    }


    @override String toString() {
        return "[Input]\n" + "Identifier: $identifier\n" + "Title: $title\n";
    }
}


class OgcDocument_Output extends OgcDocument {
    String identifier;
    String title;

    OgcDocument_Output(Xml.XmlElement element) : super(element, "Output") {
        _parseElements((element) {
            switch (element.name.local) {
                case "Identifier":
                    identifier = element.text;
                    break;
                case "Title":
                    title = element.text;
                    break;
                case "Abstract":
                case "ComplexOutput":
                    // ignore
                    break;
                default:
                    OgcDocument._unsupported(element);
                    break;
            }
        });
    }


    @override String toString() {
        return "[Output]\n" + "Identifier: $identifier\n";
    }
}


class OgcDocument_DataInputs extends OgcDocument {

    List<OgcDocument_Input> inputs = new List<OgcDocument_Input>();

    OgcDocument_DataInputs(Xml.XmlElement element)
            : super(element, "DataInputs") {
        _parseElements((element) {
            switch (element.name.local) {
                case "Input":
                    inputs.add(new OgcDocument_Input(element));
                    break;
                default:
                    OgcDocument._unsupported(element);
                    break;
            }
        });
    }

    @override String toString() {
        return "[Output]\n" + inputs.map((i) => i.toString()).join();
    }
}


class OgcDocument_ProcessOutputs extends OgcDocument {

    List<OgcDocument_Output> outputs = new List<OgcDocument_Output>();

    OgcDocument_ProcessOutputs(Xml.XmlElement element)
            : super(element, "ProcessOutputs") {
        _parseElements((element) {
            switch (element.name.local) {
                case "Output":
                    outputs.add(new OgcDocument_Output(element));
                    break;
                default:
                    OgcDocument._unsupported(element);
                    break;
            }
        });
    }

    @override String toString() {
        return "[Output]\n" + outputs.map((i) => i.toString()).join();
    }
}


class OgcDocument_ProcessDescription extends OgcDocument {

    String identifier;
    String title;
    OgcDocument_DataInputs dataInputs;
    OgcDocument_ProcessOutputs processOutputs;

    OgcDocument_ProcessDescription(Xml.XmlElement element)
            : super(element, "ProcessDescription") {
        _parseElements((element) {
            switch (element.name.local) {
                case "Identifier":
                    identifier = element.text;
                    break;
                case "Title":
                    title = element.text;
                    break;
                case "DataInputs":
                    dataInputs = new OgcDocument_DataInputs(element);
                    break;
                case "ProcessOutputs":
                    processOutputs = new OgcDocument_ProcessOutputs(element);
                    break;
                case "Abstract":
                case "Metadata":
                    // ignore
                    break;
                default:
                    OgcDocument._unsupported(element);
                    break;
            }
        });
    }


    @override String toString() {
        return "[ProcessDescription]" +
                "Identifier: $identifier\n" +
                "Title: $title\n" +
                dataInputs.toString() +
                processOutputs.toString();
    }
}

class OgcDocument_ExceptionReport extends OgcDocument {

    List<OgcDocument_Exception> exceptions = new List<OgcDocument_Exception>();

    OgcDocument_ExceptionReport(Xml.XmlElement element)
            : super(element, "ExceptionReport") {
        _parseElements((element) {
            switch (element.name.local) {
                case "Exception":
                    exceptions.add(new OgcDocument_Exception(element));
                    break;
                default:
                    OgcDocument._unsupported(element);
                    break;
            }
        });
    }

    @override String toString() {
        return "[ExceptionReport]\n" + exceptions.map((i) => i.toString()).join();
    }
}


class OgcDocument_ProcessDescriptions extends OgcDocument {
    List<OgcDocument_ProcessDescription> descriptions = new List<OgcDocument_ProcessDescription>();

    OgcDocument_ProcessDescriptions(Xml.XmlElement element)
            : super(element, "ProcessDescriptions") {
        _parseElements((element) {
            switch (element.name.local) {
                case "ProcessDescription":
                    descriptions.add(new OgcDocument_ProcessDescription(element));
                    break;
                default:
                    OgcDocument._unsupported(element);
                    break;
            }
        });
    }

    @override String toString() {
        return "[ProcessDescriptions]\n" + descriptions.map((i) => i.toString()).join();
    }
}
