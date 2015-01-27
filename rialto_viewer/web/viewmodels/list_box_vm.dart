// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


class ListBoxItem<T> {
    String name;
    OptionElement optionElement;
    T data;

    ListBoxItem(T this.data, String this.name) {
        optionElement = new OptionElement(value: name);
        optionElement.text = name;
    }
}


class ListBoxVM<T> extends ViewModel {
    List<ListBoxItem<T>> _list = new List<ListBoxItem<T>>();
    SelectElement _selectElement;
    Map<OptionElement, T> _map = new Map<OptionElement, T>();

    ListBoxVM(String id): super(id) {
        _selectElement = _element;
        _selectElement.children.clear();
    }

    void setSelectHandler(var f) {
        _selectElement.onClick.listen((e) => f(e));
    }

    void add(T item) {
        var wrapper = new ListBoxItem<T>(item, item.toString());
        _list.add(wrapper);
        _selectElement.children.add(wrapper.optionElement);
        _map[wrapper.optionElement] = item;
    }

    void clear() {
        _list.clear();
        _selectElement.children.clear();
    }

    void removeWhere(bool test(T element)) {
        _list.removeWhere((i) => test(i.data));
    }

    List<T> getCurrentSelection() {
        var list = new List<T>();
        var o = _selectElement.selectedOptions;
        _selectElement.selectedOptions.forEach((opt) => list.add(_map[opt]));
        return list;
    }

    int get length => _list.length;

    // only use for item iteration, no modification
    List<ListBoxItem<T>> get list => _list;
}
