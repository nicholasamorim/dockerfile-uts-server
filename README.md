# dockerfile-uts-server
Dockerfile for uts-server - a micro RFC 3161 Time-Stamp server written in C

This Dockerfile is a multi-stage build in order to keep the size of the final image as small as possible.


This container in its default settings run `uts-server` with test certs and in development mode (plenty of logs). In the default configuration the server run as the `uts-server` user.

`/etc/uts-server` is available as a VOLUME to mount and add your configuration file and certs.

## Running with default (test) settings:

```
docker run -d -p 2020:2020 uts-server
```

## Running with your own configuration file:

```
docker run -d -v /path/to/uts/conf/:/etc/uts-server -p 2020:2020 uts-server -c /etc/uts-server/uts.conf
```

You may pass any number of parameters after `uts-server`, but the only other useful parameter is `-D` which will run `uts-server` in development mode.

Note that if you provide your own configuration, you're responsible for setting up `run_as_user` variable.

