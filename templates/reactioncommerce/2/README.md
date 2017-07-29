### Docs

The Reaction Commerce official docs are
[here](https://docs.reactioncommerce.com/)

This template implements the same method as found
[here](https://docs.reactioncommerce.com/reaction-docs/master/deploying-reaction-using-docker)

### MongoDB

You'll need a mongodb stack running, choose it in the external link
question below

### Traefik

For external access you'll need to setup [traefik](https://github.com/rancher/community-catalog/tree/master/templates/traefik), all the appropriate
labels will be set when you set the hostname and domain below

### Support

There are experimental versions of this template in this catalog [here](https://github.com/ohmydocker/ohmydocker-catalog) which implement
other setups.  Issues, PRs, etc are welcome there.

### Baking in a theme and/or plugin

The official Docs
[Configuring Reaction](https://docs.reactioncommerce.com/reaction-docs/master/configuration)
[Creating a theme](https://docs.reactioncommerce.com/reaction-docs/master/creating-a-theme)
and
[Intro to creating a plugin](https://docs.reactioncommerce.com/reaction-docs/master/plugin-intro-1)
are a good place to start, then create a Dockerfile in your theme or
plugin something like this:

```
FROM reactioncommerce/reaction:v1.4.0

COPY mytheme imports/plugins/custom/
COPY myplugin imports/plugins/custom/
```

Now swap out the `Image` variable below
with your custom image with your
theme and/or plugin

### Local usage

There is a Makefile for local usage

`make` should net you a test setup

`make show` will show you the resulting `docker-compose.yml` from the
gotpl `gen.sh` step

`local.yml` is where you can add your own variable values that will be
substituted during the gotpl step (of note you will need golang and
[gotpl](https://github.com/tsg/gotpl) installed)

`local.yml` if missing will be sourced from `local.yml.example`
