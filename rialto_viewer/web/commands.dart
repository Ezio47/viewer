// Copyright (c) 2015, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


class Commands {
    Hub _hub;

    Commands() :
        _hub = Hub.root;

    Future<Layer> addLayer(LayerData data) {
        return _hub.layerManager.doAddLayer(data);
    }
}


// given a list of things, run a function F against each one, in order
// and with an explicit wait between each one
//
// and return a Future with the list of the results from each F
class CommandChainer {
    Function _f;

    CommandChainer(Function this._f) {

    }

    Future<List<dynamic>> run(List<dynamic> inputs) {

        List<dynamic> outputs = [];
        var c = new Completer();

        _executeNextCommand(inputs, 0, outputs, c).then((_) {

        });

        return c.future;
    }

    Future _executeNextCommand(List<dynamic> inputs, int index, List<dynamic> outputs, Completer c) {

          dynamic input = inputs[index];

          _f(input).then((dynamic result) {

              outputs.add(result);

              if (index + 1 != inputs.length) {
                  _executeNextCommand(inputs, index + 1, outputs, c);
              } else {
                  c.complete(outputs);
                  return;
              }
          });

          return c.future;
      }
}
