# shinybox

Simplified self-contained renv-controlled shiny apps launched with a one liner + some handy admin tools.

When you lanch a repo as a self contained shiny app, it is run inside a docker container, and maps ports to your host machine. Within the repo folder a new `_shiny` folder is created than maps some useful locations from the containerised shiny server to your host machine:

```
./_shiny
├── cache
├── config
│   └── shiny-server.conf
└── logs
```

Note the cache folder can be moved if necessary.

If your repo contains an `renv.lock` in the root, an renv is automatically initialised and restored. The embedded shiny server will use it when running your app. The renv package cache is shared with the host machine and all apps launched by `shinybox`

Example one liner:

```
runapp dashboard -d ~/repos/dashboard -p 8080 -v 4.1.1
```

Spins up a new self contained app called "dashboard" from the repo `~/repos/dashboard`, mapped to port 8080 on the host machine, running against the Rocker/shiny image tagged with `4.1.1`

See below for detailed usage.

# Server software package dependencies

* `docker.io`
* `nvme-cli`
* `jq`

example Ubuntu install:

```
sudo apt-get install docker.io nvme-cli jq
```

# Host cloud instance setup

```
cd shiny_server
sudo ./install.sh
```

`install.sh`:
  
  - installs the `runapp` and `appshell` commands to `/usr/local/bin`
  - installs the ssd cache init script to `/usr/local/bin` (might not be used).
  - creates a folder for a shared `renv` cache: `/usr/local/renv_cache`
  - installs a generic dockerfile in `/usr/share/shinybox` based on rocker/shiny.

## Shiny cache location

Inside the container, within the app root, a folder is created: `_shiny/cache` for your shiny cache that maps to
`$SHINYBOX_CACHE_DIR/<app_name>/_shiny/cache` on the host machine.

You can manually set `$SHINYBOX_CACHE_DIR` or let it default to `./_shiny/cache` in the repo folder on the host machine.

Your app will need to be using a cache at `./_shiny/cache` when making `shiny::bindCache` calls, otherwise it won't be writing to a known location on the host machine. This probably only matters if you want to target fast storage for the cache, see below.

### Using an SSD on AWS

If you're on AWS and want to use an available ssd as your cache add this to the crontab (`sudo crontab -e`):

```
@reboot sudo /usr/local/bin/init_ssd_cache.sh
```

It identifies and remounts the SSD at `/ssd`. Apparently this is necessary every reboot with AWS ephemeral ssd storage.

`init_sdd_cache.sh` sets `SHINYBOX_CACHE_DIR=/ssd`

# Detailed usage

## Running containerised shiny apps

To run a folder as an app:

```
runapp dashboard -d ~/repos/dashboard -p 8080 -v 4.1.1
```

Will run a Shiny server running R 4.1.1 on port 8080 of the host for the app in ~/repos/dashboard. It can be viewed at:

```
http://<host_ip>:8080
```

**Note:** The first argument is the name for the app, in this case `dashboard`, it must be unique since this name is also given to the docker container.

## Stopping containerised shiny apps

To stop a running app:

```
sudo docker stop dashboard
```

## Getting a shell to an app:

To attach a shell to a running app's server:

```
appshell dashboard
```

## Viewing the log of an app

To view the most recent log of a running app:

```
catlog dashboard
```

## Debugging

Within the container, running shiny application code can be found at `/srv/shiny-server/app`.

If you get a shell to the app via `appshell` and run:

```
cd /srv/shiny-server/app
R
```

you'll have an R prompt, with package environment as per the app's renv.

If you want to call `runApp()` interactively you'll first need to check if you have any ports available to debug on:

```
$sudo docker ps
CONTAINER ID   IMAGE            COMMAND   CREATED          STATUS          PORTS                                                                                    NAMES
ecbc512df6ae   shinybox:4.1.3   "/init"   11 minutes ago   Up 11 minutes   0.0.0.0:8081->3838/tcp, :::8081->3838/tcp, 0.0.0.0:8082->12345/tcp, :::8082->12345/tcp   dashboard-prerelease
831e04a416e6   shinybox:4.1.2   "/init"   6 weeks ago      Up 6 weeks      0.0.0.0:8080->3838/tcp, :::8080->3838/tcp                                                dashboard
```

There is an escape hatch into docker arguments for `runapp` which can be used to add debugging ports or other temporary config, `-f` or `--docker-flags` takes a string arugment which is inlined into the docker run expression for the app. So adding ports could be done like so:

```
 runapp dashboard-prerelease -d ~/repos/interactive_location_analytics_dashboard.prerelease -p 8081 -v 4.1.2 -f "-p 8082:12345"
```

Which will append `-p 8082:12345` to the `docker run` command for the app, meaning if you do:
```
runApp(host = "0.0.0.0", port = 12345)
```

From the app R prompt mentioned above, you will have an interactively run app you can hit on your host on port 8082.



# Links

* [Shiny server configuration guide](https://docs.rstudio.com/shiny-server/#default-configuration)
* [rocker docker images](https://github.com/rocker-org/rocker-versioned2)
* [Make an Amazon EBS volume available for use on Linux](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ebs-using-volumes.html)


