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

    OgcDocument(Xml.XmlElement this.element, [String this.type]) {
        assert(type == null || element.name.local == type);
    }

    static OgcDocument_WpsCapabilities parseWpsCapabilities(Xml.XmlDocument document) {
        var node = _getElement(document.children, "Capabilities");
        if (node == null) return null; // TODO
        return new OgcDocument_WpsCapabilities(node);
    }

    static OgcDocument_ExceptionReport parseExceptionReport(Xml.XmlDocument document) {
        var node = _getElement(document.children, "ExceptionReport");
        if (node == null) return null; // TODO
        return new OgcDocument_ExceptionReport(node);
    }

    static OgcDocument_WpsProcessDescriptions parseWpsProcessDescriptions(Xml.XmlDocument document) {
        var node = _getElement(document.children, "ProcessDescriptions");
        if (node == null) return null; // TODO
        return new OgcDocument_WpsProcessDescriptions(node);
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
        return "type: $type";
    }

    void _unsupported(Xml.XmlElement element) {
        log("Element type ${element.name.local} not supported");
    }
}

class OgcDocument_OwsServiceIdentification extends OgcDocument {
    OgcDocument_OwsServiceIdentification(Xml.XmlElement element) : super(element, "ServiceIdentification");
}

class OgcDocument_OwsServiceProvider extends OgcDocument {
    OgcDocument_OwsServiceProvider(Xml.XmlElement element) : super(element, "ServiceProvider");
}


class OgcDocument_OwsOperationsMetadata extends OgcDocument {
    OgcDocument_OwsOperationsMetadata(Xml.XmlElement element) : super(element, "OperationsMetadata");
}


class OgcDocument_WpsProcessOfferings extends OgcDocument {
    OgcDocument_WpsProcessOfferings(Xml.XmlElement element) : super(element, "ProcessOfferings");
}

class OgcDocument_Exception extends OgcDocument {
    OgcDocument_Exception(Xml.XmlElement element) : super(element, "Exception");
}


class OgcDocument_WpsCapabilities extends OgcDocument {
    OgcDocument_OwsServiceIdentification serviceIdentification;
    OgcDocument_OwsServiceProvider serviceProvider;
    OgcDocument_OwsOperationsMetadata operationsMetadata;
    OgcDocument_WpsProcessOfferings processOfferings;

    OgcDocument_WpsCapabilities(Xml.XmlElement element) : super(element, "Capabilities") {
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
                    processOfferings = new OgcDocument_WpsProcessOfferings(element);
                    break;
                case "Languages":
                    break;
                default:
                    _unsupported(element);
                    break;
            }
        });
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
                    _unsupported(element);
                    break;
            }
        });
    }

    @override String toString() {
        return super.toString() + "\nIdentifier: $identifier";
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
                    _unsupported(element);
                    break;
            }
        });
    }

    @override String toString() {
        return super.toString() + "\nIdentifier: $identifier";
    }
}

class OgcDocument_DataInputs extends OgcDocument {
    List<OgcDocument_Input> inputs = new List<OgcDocument_Input>();

    OgcDocument_DataInputs(Xml.XmlElement element) : super(element, "DataInputs") {
        _parseElements((element) {
            switch (element.name.local) {
                case "Input":
                    inputs.add(new OgcDocument_Input(element));
                    break;
                default:
                    _unsupported(element);
                    break;
            }
        });
    }
}

class OgcDocument_ProcessOutputs extends OgcDocument {
    List<OgcDocument_Output> outputs = new List<OgcDocument_Output>();

    OgcDocument_ProcessOutputs(Xml.XmlElement element) : super(element, "ProcessOutputs") {
        _parseElements((element) {
            switch (element.name.local) {
                case "Output":
                    outputs.add(new OgcDocument_Output(element));
                    break;
                default:
                    _unsupported(element);
                    break;
            }
        });
    }
}


class OgcDocument_WpsProcessDescription extends OgcDocument {
    String identifier;
    String title;
    OgcDocument_DataInputs dataInputs;
    OgcDocument_ProcessOutputs processOutputs;

    OgcDocument_WpsProcessDescription(Xml.XmlElement element) : super(element, "ProcessDescription") {
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
                    _unsupported(element);
                    break;
            }
        });
    }

    @override String toString() {
        return super.toString() + "\nIdentifier: $identifier\nTitle: $title";
    }
}

class OgcDocument_ExceptionReport extends OgcDocument {
    List<OgcDocument_Exception> exceptions = new List<OgcDocument_Exception>();

    OgcDocument_ExceptionReport(Xml.XmlElement element) : super(element, "ExceptionReport") {
        _parseElements((element) {
            switch (element.name.local) {
                case "Exception":
                    exceptions.add(new OgcDocument_Exception(element));
                    break;
                default:
                    _unsupported(element);
                    break;
            }
        });
    }
}

class OgcDocument_WpsProcessDescriptions extends OgcDocument {
    Map<String, OgcDocument_WpsProcessDescription> descriptions = new Map<String, OgcDocument_WpsProcessDescription>();

    OgcDocument_WpsProcessDescriptions(Xml.XmlElement element) : super(element, "ProcessDescriptions") {
        _parseElements((element) {
            switch (element.name.local) {
                case "ProcessDescription":
                    var description = new OgcDocument_WpsProcessDescription(element);
                    descriptions[description.identifier] = description;
                    break;
                default:
                    _unsupported(element);
                    break;
            }
        });
    }
}
