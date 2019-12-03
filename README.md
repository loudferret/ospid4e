# ospid4e

Simple Erlang application to save (Linux) OS PID into file to be used by OS, i.e. by `systemd`.

## Build

    $ rebar3 compile

## Usage

Made for use with rebar3 releases; add following to your `rebar.config` dependencies:

    {ospid4e, {git, "https://github.com/loudferret/ospid4e.git", {branch, master}}}

And add to config file location of PID file

    {ospid4e, [ {pidfile, "/var/tun/path/to/pidfile.pid"} ]}

Default would be `/tmp/ospid4e.pid`

Then you can use the PID file in systemd service definition:

    PIDFile=/var/tun/path/to/pidfile.pid

Once the application (rebar release) is started the PID is written into specified file. When the application is properly terminated the file is deleted.
ospid4e overwrites PID file with new PID number when it already exists
.
