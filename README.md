# Cron Monitor

A basic Sinatra app to monitor crons. Alerts you if a cron has started and not ended or if a cron has not started within the specified time.

All you need to do is curl a url before and after a cron runs

Before cron - http://localhost:5000/ping?name=cron_name&et=approx_time_taken_to_run&pf=time_between_2_runs&status=start

After cron - http://localhost:5000/ping?name=cron_name&status=compelte

## Configuration

Dependencies and all configuration is done in <tt>environment.rb</tt>. Your
database is also set up here. DataMapper will use mysql by default in this app. Tests
use the sqlite3-memory adapter (no configuration needed).

Add your controller actions in <tt>application.rb</tt>. Views for these actions
are placed in the <tt>views</tt> directory. Static files, including a stock
stylesheet, go in the <tt>public</tt> directory. Models go in the <tt>lib</tt>
directory and are auto-loaded.

Environment variables that you want to expose to your application can be added
in <tt>.env</tt>

## Testing

It needs proper specs

Add your specs in <tt>spec</tt>; just require <tt>spec_helper.rb</tt> to
pre-configure the test environment. A number of samples are provided (including
a sample model, which can be removed). To run the specs:

    bundle exec rake spec

## Getting Started

    bundle install
    bundle exec foreman start

## Extras

We've included a handy <tt>console</tt> script that fires up irb with your
environment loaded. To load it, use the Rake task:

    bundle exec rake console

## Credits

The sinatra template has been adapted from [Nick Plante](https://github.com/zapnap/sinatra-template).
