// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


class ControlledItem<T> {
    String name;
    OptionElement optionElement;
    T data;

    ControlledItem(T this.data) {
        optionElement = new OptionElement(value: name);
        optionElement.text = name;
    }
}


class ControlledList<T> {
    List<ControlledItem<T>> _list = new List<ControlledItem<T>>();
    SelectElement _selectElement;

    ControlledList(SelectElement this._selectElement) {
        _selectElement.children.clear();
    }

    void add(T item) {
        var wrapper = new ControlledItem<T>(item);
        _list.add(wrapper);
        _selectElement.children.add(wrapper.optionElement);
    }

    void clear() {
        _list.clear();
        _selectElement.children.clear();
    }

    void removeWhere(bool test(T element)) {
        _list.removeWhere((i) => test(i.data));
    }

    int get length => _list.length;

    // only use for item iteration, no modification
    List<ControlledItem<T>> get list => _list;
}
