// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;


//
// All components should register themselves with the hub and then
// express interest in whatever events they care about.
//
// For polymer elements, this is done in ready() or maybe attached()
//

typedef void MouseMoveHandler(int newX, int newY);
typedef void MouseDownHandler();
typedef void MouseUpHandler();
typedef void WindowResizeHandler();


class EventRegistry {
    // global handlers
    List<MouseMoveHandler> _mouseMoveHandlers = new List<MouseMoveHandler>();
    List<MouseDownHandler> _mouseDownHandlers = new List<MouseDownHandler>();
    List<MouseUpHandler> _mouseUpHandlers = new List<MouseUpHandler>();
    List<WindowResizeHandler> _windowResizeHandlers = new List<WindowResizeHandler>();

    Hub _hub;

    EventRegistry() {
        _hub = Hub.root;
    }

    void start(var domElement) {
        domElement.onMouseMove.listen(_handleMouseMove);
        domElement.onMouseDown.listen(_handleMouseDown);
        domElement.onMouseUp.listen(_handleMouseUp);
        window.onResize.listen(_handleWindowResize);
    }

    //
    // Mouse Move
    //

    void _handleMouseMove(var event) {
         //event.preventDefault();

         final int newX = event.client.x;
         final int newY = event.client.y;

         _mouseMoveHandlers.forEach((h) => h(newX, newY));
     }

     void registerMouseMoveHandler(MouseMoveHandler handler) {
         if (!_mouseMoveHandlers.contains(handler))
             _mouseMoveHandlers.add(handler);
     }

     void unregisterMouseMoveHandler(MouseMoveHandler handler) {
         _mouseMoveHandlers.remove(handler);
     }

     //
     // Window Resize
     //

     void _handleWindowResize(var event) {
         _windowResizeHandlers.forEach((h) => h());
     }

     void registerWindowResizeHandler(WindowResizeHandler handler) {
         if (!_windowResizeHandlers.contains(handler))
             _windowResizeHandlers.add(handler);
     }

     void unregisterWindowResizeHandler(WindowResizeHandler handler) {
         _windowResizeHandlers.remove(handler);
     }

     //
     // Mouse Down
     //

     void _handleMouseDown(var event) {
         _mouseDownHandlers.forEach((h) => h());
     }

     void registerMouseDownHandler(MouseDownHandler handler) {
         if (!_mouseDownHandlers.contains(handler))
             _mouseDownHandlers.add(handler);
     }

     void unregisterMouseDownHandler(MouseDownHandler handler) {
         _mouseDownHandlers.remove(handler);
     }

     //
     // Mouse Up
     //

     void _handleMouseUp(var event) {
         _mouseUpHandlers.forEach((h) => h());
     }

     void registerMouseUpHandler(MouseUpHandler handler) {
         if (!_mouseUpHandlers.contains(handler))
             _mouseUpHandlers.add(handler);
     }

     void unregisterMouseUpHandler(MouseUpHandler handler) {
         _mouseUpHandlers.remove(handler);
     }
}
