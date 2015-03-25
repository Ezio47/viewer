# Vagrant and Tuple

## Using Vagrant

1. Install it according to your operating system.

## Spin up a docker enabled VM

1. The included `Vagrantfile` can guide you in getting set up.
    - You can find it at `docker/vagrant`
2. Create a directory `docker-tuple`
3. Copy the `Vagrantfile` to that directory.
4. Clone the [tuple](https://github.com/radiantbluetechnologies/tuple) repo inside your `tuple` directory
5. Here is an eample of what your directory should look like: 

         docker-tuple
         |- Vagrantfile
         |- tuple

6. From `docker-tuple`:
    -  `$ vagrant up`

This gets docker installed installed in a CentOS 6 minimal box and booted. Now you can login with `$ vagrant ssh`

## Helpful hints

- You probably need to start the docker daemon, and have it enabled on reboot. You can do that with: 
    - `# chkconfig docker on`
    - `# service docker start`.
- You can avoid needed to use `sudo` as the vagrant user by adding it to the `docker` group:
    - `# usermod -aG docker vagrant` **You'll need to logout and then login again**


