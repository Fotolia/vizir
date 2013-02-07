Vizir (coming soon)
======

Vizir is a web UI for displaying time series from different data sources.

It is written in Ruby, using the Ruby on Rails framework.

It is designed in a modular way, to be easily extended by writing providers for multiple data sources.

Features
--------

 * renders graphs in the browser
 * supports your own time series source with a few lines of code
 * provides a DSL to describe metrics and graphs, to create custom dashboards,
   and to apply operations to data (sums, ratios, etc.)

Setup
-----

 * Copy config/database.yml.example to config/database.yml and edit to match your environment
 * Copy config/providers.yml.example to config/providers.yml and edit to match your environment
 * rake db:migrate
 * rake vizir:init
 * rake vizir:load
