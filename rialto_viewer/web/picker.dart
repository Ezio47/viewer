part of rialto.viewer;


class Picker {
    RenderingContext gl;
    CanvasElement _canvas;
    var _texture;
    var _frameBNuffer;
    var _renderBuffer;

    List<Shape> renderables;

    Picker(RenderingContext this.gl, CanvasElement this._canvas) {
        _configure();
    }

    void update() {
        var width = _canvas.width;
        var height = _canvas.height;

        gl.bindTexture(TEXTURE_2D, _texture);
        gl.texImage2D(TEXTURE_2D, 0, RGBA, width, height, 0, RGBA, UNSIGNED_BYTE, null);

        //2. Init Render Buffer
        gl.bindRenderbuffer(RENDERBUFFER, _renderBuffer);
        gl.renderbufferStorage(RENDERBUFFER, DEPTH_COMPONENT16, width, height);
    }

    void _configure() {
        var width = _canvas.width;
        var height = _canvas.height;

        //1. Init Picking Texture
        _texture = gl.createTexture();
        gl.bindTexture(TEXTURE_2D, _texture);
        gl.texImage2D(TEXTURE_2D, 0, RGBA, width, height, 0, RGBA, UNSIGNED_BYTE, null);

        //2. Init Render Buffer
        _renderBuffer = gl.createRenderbuffer();
        gl.bindRenderbuffer(RENDERBUFFER, _renderBuffer);
        gl.renderbufferStorage(RENDERBUFFER, DEPTH_COMPONENT16, width, height);

        //3. Init Frame Buffer
        _frameBNuffer = gl.createFramebuffer();
        gl.bindFramebuffer(FRAMEBUFFER, _frameBNuffer);
        gl.framebufferTexture2D(FRAMEBUFFER, COLOR_ATTACHMENT0, TEXTURE_2D, _texture, 0);
        gl.framebufferRenderbuffer(FRAMEBUFFER, DEPTH_ATTACHMENT, RENDERBUFFER, _renderBuffer);

        //4. Clean up
        gl.bindTexture(TEXTURE_2D, null);
        gl.bindRenderbuffer(RENDERBUFFER, null);
        gl.bindFramebuffer(FRAMEBUFFER, null);
    }

    bool find(Vector2i coords) {
        // BUG: is 2*2=4 the right window size?
        // BUG: should we look for more than one hit in the window?
        // BUG: should we hit test at the center of the window first?

        int xsize = 3;
        int ysize = 3;

        //read a block of (xsize x ysize) pixels
        var readout = new Uint8List(1 * 1 * 4 * (xsize*ysize));
        gl.bindFramebuffer(FRAMEBUFFER, _frameBNuffer);

        int xmin = coords.x - xsize ~/ 2;
        if (xmin < 0) { xsize -= (0-xmin); xmin = 0; }
        if (xmin + xsize >= c_width) xsize -= c_width - (xmin + xsize);

        int ymin = coords.y - ysize ~/ 2;
        if (ymin < 0) { ysize -= (0-ymin); ymin = 0; }
        if (ymin + ysize >= c_height) ysize -= c_height - (ymin + ysize);

        gl.readPixels(xmin, ymin, xsize, ysize, RGBA, UNSIGNED_BYTE, readout);
        gl.bindFramebuffer(FRAMEBUFFER, null);

        Shape hit = null;

        for (int i = 0; i < xsize*ysize; i++) {
            final int ri = readout[i * 4];
            final int gi = readout[i * 4 + 1];
            final int bi = readout[i * 4 + 2];

            //print("readout: $ri $gi $bi");

            hit = _hitTest(ri, gi, bi);
            if (hit != null) break;
        }

        return (hit != null);
    }

    Shape _hitTest(int ri, int gi, int bi) {

      //print("readout: $ri $gi $bi");

      if (ri == 0 && gi == 0 && bi == 0) {
          // not an object at all
          return null;
      }

      final int id = Utils.convertIvecToId(ri, gi, bi);
      if (!Shape.shapes.containsKey(id)) {
          // error: we have an object that we don't have a key for!
          assert(false);
      }

      var hit = Shape.shapes[id];
      print("BOOM: $id is ${hit.runtimeType.toString()}");
      if (hit is CloudShape) {
          int objId = hit.id;
          int pointId = id;
          int pointNum = pointId - (objId + 1);
          assert(pointNum >= 0 && pointNum < (hit as CloudShape).numPoints);
          print("   point $pointNum");

      }

      return hit;
    }
}
