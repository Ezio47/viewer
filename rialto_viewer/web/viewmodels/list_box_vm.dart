// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


class ListBoxItem {
    final String name;
    OptionElement optionElement;

    ListBoxItem(this.name) {
        optionElement = new OptionElement(value: name);
        optionElement.text = name;
    }
}

class ListBoxVM extends ViewModel with MStateControl<String> {
    List<ListBoxItem> _list = new List<ListBoxItem>();
    SelectElement _selectElement;
    Map<OptionElement, String> _map = new Map<OptionElement, String>();
    Function _selectHandler;

    ListBoxVM(String id, {Function onSelect: null})
            : super(id),
              _selectHandler = onSelect {

        _selectElement = _element;
        _selectElement.children.clear();
        _selectElement.onChange.listen(_selectHandler);
    }

    @override
    String get value {
        if (_selectElement.value == null || _selectElement.value.isEmpty) {
            return null;
        }
        return _selectElement.value;
    }

    @override
    set value(String t) => _selectElement.value = (t == null) ? "" : t;

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
        value = "";
    }

    set disabled(bool v) => _selectElement.disabled = v;
    bool get disabled => _selectElement.disabled;

    // only use for item iteration, no modification
//    List<ListBoxItem<T>> get list => _list;
}
