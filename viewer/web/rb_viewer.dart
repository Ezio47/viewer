import 'package:polymer/polymer.dart';
import 'dart:core';
import 'rb_osg.dart';

@CustomTag('rb-viewer')
class RbViewer extends PolymerElement {
  
  // these are the globals of the model for all the components
  @published double g_mousePositionX = 0.0;
  @published double g_mousePositionY = 0.0;
  @published bool g_showAxes = false;
  @published ObservableList<String> g_files = toObservable([]);
  List<String> _oldFiles = [];
  @published String g_server = "";
  
  RbOsg _elem_osg;
  
  RbViewer.created() : super.created();
    
  @override
  void attached() {
    super.attached();

    _elem_osg =  this.shadowRoot.querySelector("#osg_elem");
    assert(_elem_osg != null);
    
    g_files.changes.listen((r) {
      g_filesChanged2(r);
    });
    
    return;
  }
  
  void g_serverChanged(var olds, var news)
  {
    return;
  }
  
  void g_filesChanged2(List<ChangeRecord> r)
  {
    //PropertyChangeRecord r0 = r[0];
    //PropertyChangeRecord r1 = r[1];
    //PropertyChangeRecord r2 = r[2];
    //var old0 = r0.oldValue;
    //var new0 = r0.newValue;
    //var old1 = r1.oldValue;
    //var new1 = r1.newValue;

    // "added an element" case
    for (var s in g_files)
    {
      if (!_oldFiles.contains(s))
      {
        _elem_osg.addGraph(s);
        _oldFiles.add(s);
      }
    }
    
    // "removed an element" case
    List<String> toremove = [];
    for (var s in _oldFiles)
    {
      if (! g_files.contains(s)) 
      {
        toremove.add(s);
        _oldFiles.remove(s);
      }
    }
    toremove.forEach( (s) => _elem_osg.removeGraph(s) );
    
    // window.alert(g_files.toString());
    return;
  }

 
  @override
  void detached() {
    super.detached();
  }
  
}
