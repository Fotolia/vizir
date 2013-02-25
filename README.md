# Vizir

Vizir is a web UI for displaying time series from different data sources.

It is written in Ruby, using the Ruby on Rails framework.

It is designed in a modular way, to be easily extended by writing providers for multiple data sources.

collect is the only provider currently implemented, but more to come.

It's still under development.

## Features

 * renders graphs in the browser
 * supports your own time series source with a few lines of code
 * provides a DSL to describe metrics and graphs, to create custom dashboards,
   and to apply operations to data (sums, ratios, etc.)

## Setup

#### Dependencies

Vizir depends on Ruby >= 1.9 (tested only with MRI 1.9) and bundle.

The collectd backend depends on librrd (`apt-get install librrd4` on Debian and related).

#### Install

 * `git clone https://github.com/Fotolia/vizir`
 * `cd vizir; bundle install`
 * Copy config/database.yml.example to config/database.yml and edit to match your environment
 * Copy config/providers.yml.example to config/providers.yml and edit to match your environment
 * `rake db:migrate`
 * `rake vizir:init`
 * `rake vizir:load`

#### Rails secret token

The secret token used to sign cookies is generated at the application's first start.
It is stored in `config/secret_token.yml` file which is not tracked.
To create a new one, juste delete it and restart the application.

## Metrics, graphs and dashboards definition

Vizir provides a comprehensive Ruby DSL to define metrics, graphs and dashboards (each one being a set of one or more of the previous).

It comes with a set of definitions, stored in `lib/definitions/<provider>`, the only provider being "collectd" at the moment.

Example of definition for a load average graph:

```ruby
graph "load" do
  { :shortterm => 1, :midterm => 5, :longterm => 15 }.each do |term,time|
    metric "load_#{time.to_s}" do
      rrd "load/load.rrd"
      ds term.to_s
      title "Load average #{time.to_s}min"
    end
  end

  layout :line
  title "Load average"
  scope :entity
end
```
will define 3 metrics (load_1, load_5, load_15), gathered in a graph.
The `scope :entity` line means the graph is defined for each entity (e.g host) which provides load data.

Graphs can be grouped in dashboards to simplify the display.
Currently, graphs must be part of a dashboard to be displayed.

Definition of a "System" dashboard :

```ruby
dashboard "system" do
  title "System metrics"
  graphs ["load", "cpu", "memory"]
end
```

Each component can be defined independently in different files, or nested (e.g dashboard containing graphs containing metrics).

At the moment, definition modifications need a reload of application data with the rake task, but we're working to avoid this step.
