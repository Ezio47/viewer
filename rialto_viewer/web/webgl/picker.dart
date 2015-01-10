// Copyright (c) 2014, RadiantBlue Technologies, Inc.
// This file may only be used under the MIT-style
// license found in the accompanying LICENSE.txt file.

part of rialto.viewer;

class Picker {
    Hub _hub;

    RenderingContext gl;
    CanvasElement _canvas;
    var _texture;
    var _frameBuffer;
    var _renderBuffer;

    Picker() {
        _hub = Hub.root;
        _configure();
        _hub.eventRegistry.WindowResize.subscribe0(_handleWindowResize);
    }

    void _handleWindowResize() {
        var width = _hub.width;
        var height = _hub.height;

        gl.bindTexture(TEXTURE_2D, _texture);
        gl.texImage2D(TEXTURE_2D, 0, RGBA, width, height, 0, RGBA, UNSIGNED_BYTE, null);

        //2. Init Render Buffer
        gl.bindRenderbuffer(RENDERBUFFER, _renderBuffer);
        gl.renderbufferStorage(RENDERBUFFER, DEPTH_COMPONENT16, width, height);
    }

    void _configure() {
        var width = _hub.width;
        var height = _hub.height;

        //1. Init Picking Texture
        _texture = gl.createTexture();
        gl.bindTexture(TEXTURE_2D, _texture);
        gl.texImage2D(TEXTURE_2D, 0, RGBA, width, height, 0, RGBA, UNSIGNED_BYTE, null);

        //2. Init Render Buffer
        _renderBuffer = gl.createRenderbuffer();
        gl.bindRenderbuffer(RENDERBUFFER, _renderBuffer);
        gl.renderbufferStorage(RENDERBUFFER, DEPTH_COMPONENT16, width, height);

        //3. Init Frame Buffer
        _frameBuffer = gl.createFramebuffer();
        gl.bindFramebuffer(FRAMEBUFFER, _frameBuffer);
        gl.framebufferTexture2D(FRAMEBUFFER, COLOR_ATTACHMENT0, TEXTURE_2D, _texture, 0);
        gl.framebufferRenderbuffer(FRAMEBUFFER, DEPTH_ATTACHMENT, RENDERBUFFER, _renderBuffer);

        //4. Clean up
        gl.bindTexture(TEXTURE_2D, null);
        gl.bindRenderbuffer(RENDERBUFFER, null);
        gl.bindFramebuffer(FRAMEBUFFER, null);
    }

    List find(Point coords) {
        // BUG: is 2*2=4 the right window size?
        // BUG: should we look for more than one hit in the window?
        // BUG: should we hit test at the center of the window first?

        int xsize = 3;
        int ysize = 3;

        //read a block of (xsize x ysize) pixels
        var readout = new Uint8List(1 * 1 * 4 * (xsize * ysize));
        gl.bindFramebuffer(FRAMEBUFFER, _frameBuffer);

        int xmin = coords.x - xsize ~/ 2;
        if (xmin < 0) {
            xsize -= (0 - xmin);
            xmin = 0;
        }
        if (xmin + xsize >= _hub.width) xsize -= _hub.width - (xmin + xsize);

        int ymin = coords.y - ysize ~/ 2;
        if (ymin < 0) {
            ysize -= (0 - ymin);
            ymin = 0;
        }
        if (ymin + ysize >= _hub.height) ysize -= _hub.height - (ymin + ysize);

        gl.readPixels(xmin, ymin, xsize, ysize, RGBA, UNSIGNED_BYTE, readout);
        gl.bindFramebuffer(FRAMEBUFFER, null);

        Shape hit = null;

        for (int i = 0; i < xsize * ysize; i++) {
            final int ri = readout[i * 4];
            final int gi = readout[i * 4 + 1];
            final int bi = readout[i * 4 + 2];

            //print("readout: $ri $gi $bi");

            var l = _hitTest(ri, gi, bi);
            if (l != null) {
                print("HIT");
                return l;
            }
        }

        print("pick miss");
        return null;
    }

    List _hitTest(int ri, int gi, int bi) {

        if (ri == 0 && gi == 0 && bi == 0) {
            // not an object at all
            return null;
        }

        print("readout: $ri $gi $bi");

        final int id = Utils.convertIvecToId(ri, gi, bi);
        if (!Hub.root.shapesMap.containsKey(id)) {
            // error: we have an object that we don't have a key for!
            assert(false);
        }

        var hit = Hub.root.shapesMap[id];
        hit.pick(id);

        return [hit, id];
    }
}
