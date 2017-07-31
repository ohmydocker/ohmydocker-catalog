### [MeteorJS](https://www.meteor.com/)

### MongoDB

You'll need a mongodb stack running, choose it in the external link
question below

### Traefik

For external access you'll need to setup [traefik](https://github.com/rancher/community-catalog/tree/master/templates/traefik), all the appropriate
labels will be set when you set the hostname and domain below

### Support

There are experimental versions of this template in this catalog [here](https://github.com/ohmydocker/ohmydocker-catalog) which implement
other setups.  Issues, PRs, etc are welcome there.

### Local usage

There is a Makefile for local usage

`make` should net you a test setup

`make show` will show you the resulting `docker-compose.yml` from the
gotpl `gen.sh` step

`local.yml` is where you can add your own variable values that will be
substituted during the gotpl step (of note you will need golang and
[gotpl](https://github.com/tsg/gotpl) installed)

`local.yml` if missing will be sourced from `local.yml.example`
