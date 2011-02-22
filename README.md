Squarebot!
=====

He's a Foursquare aware campfire bot that tells you where your friends are when you ask him!

### Getting started

* bootstrap:

> gem install activesupport json yajl-ruby daemons

* create a config.yml file in the project root (see config.yml.example) with campfire + foursquare api information

* run him!
> ./script/console (to test locally)
>
> ./script/run (to run in the foreground)
>
> ./script/daemon (to start him in the background)

Basic commands:
----

> @squarebot where is frank?
>
> @squarebot where is DW

Note:

'@squarebot' can also be 'Squarebot:', he can give you the location of people by either their firstname or their initials (Matthew & MR both match 'Matthew Rathbone' )



PLUGINS
----
He's built with a plugin system so that you can make him do more things. (see lib/plugins/example.rb)

add options to the config file and have them passed to your plugin when you register it (see lib/plugins/where_is.rb as an example)

* add plugins to ./lib/plugins to put them under source control
* add plugins to ./secret to not add them to source control (we have secrets too!)