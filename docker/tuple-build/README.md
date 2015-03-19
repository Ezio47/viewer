# Tuple Build Container

## Building
    $ docker build --tag=rialto-build:latest .
    
## Running
    $ docker run -d --rm -v /vagrant/tuple-out/:/rialto-viewer --name="tuple-builder" radiantblue/tuple-build:latest

