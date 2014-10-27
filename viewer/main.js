var osg = window.OSG.osg;
var osgViewer = window.OSG.osgViewer;
var osgDB = window.OSG.osgDB;
var getModel = window.getModel;

var mainloop = function ()
{
    var canvas = document.getElementById( 'View' );

    var viewer;
    viewer = new osgViewer.Viewer( canvas );
    viewer.init();
    viewer.setupManipulator();
    var rotate = new osg.MatrixTransform();
    osg.Matrix.makeRotate( -Math.PI * 0.5, 1, 0, 0, rotate.getMatrix() );
    Q.when( osgDB.parseSceneGraph( getModel() ) ).then( function ( data ) {
        rotate.addChild( data );
    } );
    viewer.setSceneData( rotate );
    viewer.run();
};


( function () {

    window.addEventListener('load', mainloop, true);

} )();


/*
var canvas = document.getElementById( 'View' );

var viewer;
viewer = new osgViewer.Viewer( canvas );
viewer.init();

viewer.getCamera().setClearColor( [ 0.0, 0.0, 0.0, 0.0 ] );


// the root node
var scene = new osg.Node();

// instanciate a node that contains matrix to transform the subgraph
var matrixTransform = new osg.MatrixTransform();

// create the model
var model = this.createModel();

// the scene is a child of the transform so everything that
// change the transform will affect its children
matrixTransform.addChild( model );


// config to let data gui change the scale
var config = {
    scale: 1.0
};
var gui = new window.dat.GUI();
var controller = gui.add( config, 'scale', 0.1, 2.0 );
controller.onChange( function ( value ) {
    // change the matrix
    osg.Matrix.makeScale( value, value, value, matrixTransform.getMatrix() );
    matrixTransform.dirtyBound();
});


scene.addChild( matrixTransform );

viewer.setSceneData( scene );
viewer.setupManipulator();
viewer.getManipulator().computeHomePosition();
*/
