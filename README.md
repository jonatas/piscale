# Piscale

The Piscale is a bridge between Timescale and SonicPi.

The aspiration of this application is to create an approachable interface
to allow developers/musicians and any data enthusiasts to create music from
data.

The bridge here is starting with Timescaledb and Raspiberry PI, but I hope it
inspires people to build more plugins and allow to mix different data into the
same interface.

My genuine intuition to create this program is that I want to pipe data to sound
synthesizers like the BPM represents the time of the music, the timeseries data
can correlate and make noise driven by the data inputs.

Think about car issues in the motor, the owner of the car can detect if something
is going wrong even not being an expert. And the mechanic can recognize several
issues depending the noise of the motor.

My invite here is to put our data to make noise. To extract sound and meaning
out of it.

# The project

The actual library is only loading a SonicPI client that can stream messages to
the server using the data from Timescale. It will work with any Postgresql
database, but I'm using Timescaledb directly to inherit all hypertable scenarios
available for timeseries data. I also added the toolkit to allow to query more 
advanced statistics with the hyperfunctions and encourage me to explore new
scenarios of data with statistics to drive the music.

I'm very open for ideas and I'd love to brainstorm about how to make this
project something useful and available to researchers and sonification
enthusiasts to join me on this journey. Please, use the discussions to bring new
ideas or start new features.

# Philosophy

The core lib will contain the minimal core to only offer the basic engines to
use both Postgres and SonicPi.

It will be able to process multiple queries and pipe the data back to multiple
backends. Allowing the user to orchestrate multiple instruments and scenarios,
enabling the Data DJ to combine different queries configured as instruments.

# DSL

One important aspect to fast prototype a new data sonification is make it easy
to the enduser to express what they want.

Here are a few ideas to be implementing as part of the core library:

```ruby
use_bpm Model.avg(:value).to_i
```

## Examples

Use `bin/console` to start the application and confirm that you can listen to
the application.


Paste the following code into your SonicPI app:

```ruby
live_loop :tsdb do
  msg = sync("/osc:127.0.0.1:51062/run-code").last
  eval(msg)
end
```

It will just allow you to connect as a remote source into your Sonic PI and
execute commands.

Make sure you adapt the port and url as the `Cues` view shows.

Want to learn more? Check out my [sonification workshop](https://github.com/jonatas/sonification-workshop)

## Usage

Use `bin/console` with a Postgresql URI to fetch data from the database. It
expects you're using hypertables and it's already mapping all hypertables as
models in the console.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jonatas/piscale. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/jonatas/piscale/blob/master/CODE_OF_CONDUCT.md).


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Piscale project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/jonatas/piscale/blob/master/CODE_OF_CONDUCT.md).
