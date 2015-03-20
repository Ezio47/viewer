# Tuple Build Container

## Building
    $ docker build --tag=rialto-build:latest .
    
## Running
    $ docker run -v /ABSOLUTE/PATH/TO/tuple/rialto_viewer/:/rialto-viewer --name="tuple-builder" radiantblue/tuple-build:latest

## Output
Your web app will be built inside the `/ABSOLUTE/PATH/TO/tuple` `/web` folder and is ready for deployment.

