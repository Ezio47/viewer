// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.frontend.private;

/// UI component for the item in a list box
class ListBoxItem {
  final String name;
  OptionElement optionElement;

  ListBoxItem(this.name) {
    optionElement = new OptionElement(value: name);
    optionElement.text = name;
  }
}

/// UI component for a list box
class ListBoxVM extends InputVM<String> {
  List<ListBoxItem> _list = new List<ListBoxItem>();
  SelectElement _selectElement;
  Map<OptionElement, String> _map = new Map<OptionElement, String>();
  Function _selectHandler;

  ListBoxVM(RialtoFrontend frontend, String id, {Function handler: null})
      : super(frontend, id, null),
        _selectHandler = handler {
    _selectElement = _element;
    _selectElement.children.clear();
    _selectElement.onChange.listen(_selectHandler);

    _selectElement.onChange.listen((e) {
      String v = null;
      if (_selectElement.value != null && !_selectElement.value.isEmpty) {
        v = _selectElement.value;
      }
      refresh(v);
    });
  }

  void _elementRefresh(String v) {}

  void add(String item) {
    var wrapper = new ListBoxItem(item);
    _list.add(wrapper);
    _selectElement.children.add(wrapper.optionElement);
    _map[wrapper.optionElement] = item;
  }

  void clear() {
    _list.clear();
    _map.clear();
    _selectElement.children.clear();
    stateControl.setCurrentValue(null);
  }

  set disabled(bool v) => _selectElement.disabled = v;
  bool get disabled => _selectElement.disabled;
}
