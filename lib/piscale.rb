require "piscale/version"
require 'sonic_pi'
require 'timescaledb'

ActiveRecord::Base.establish_connection(ARGV[0])

module Piscale
  class Error < StandardError; end
  Timescaledb::Hypertable.find_each do |hypertable|
    class_name = hypertable.hypertable_name.singularize.camelize
    model = Class.new(ActiveRecord::Base) do
      self.table_name = hypertable.hypertable_name
      acts_as_hypertable time_column: hypertable.main_dimension.column_name
    end
    Piscale.const_set(class_name, model)
  end

  WeatherMetric.acts_as_time_vector value_column: :temp_c, segment_by: "city_name"


  # Your code goes here...
  module_function

  def ny
    WeatherMetric.where(city_name: "New York")
  end

  def lttb_demo
    ny.lttb(threshold: 500).each do |(time, temp)|
      temp.each do |t|
        run("play #{(44 + temp).to_i}")
        run "sleep 0.5"
        sleep 0.5
      end
    end
  end

  def ohlc_demo
    run "use_synth :dark_ambience"
    ny.ohlc(timeframe: '1d').each do |candle|
      attack = (candle.high_time - candle.open_time) / 1.hour
      decay = (candle.low_time - candle.open_time) / 1.hour
      amp = [candle.high_time, candle.low_time].sort.reverse.inject(:-) / 1.hour
      pan = candle["open"] > candle.close ? -1 : 1
      run "play 64+#{candle.high}, attack: #{attack}, decay: #{decay}, amp: #{amp}, pan: #{pan}"
      sleep(amp)
    end
  end

  def ohlc_beat
    candles = ny.ohlc(timeframe: '1y')
    previous = candles.first
    candles.each do |candle|
      beat_time = (candle.high_time - candle.open_time) / 1.year
        puts candle.high_time
        o,h,l,c = candle["open"], candle.high, candle.low, candle.close
        [o,h,l,c].each do |amp|
        run "sample :ambi_drone, beat_stretch: #{beat_time}, amp: #{amp}"
        sleep beat_time * 0.95
      end
      previous = candle
    end
  end

  def ohlc_chord
    candles = ny.ohlc(timeframe: '1 month')
    previous = candles.first
    candles.each do |candle|
      o,h,l,c = candle["open"], candle.high, candle.low, candle.close
      base = :C4
      chords = [o,h,l,c].map {|temp| "#{base.inspect} + #{temp}" }
      run "play_chord [#{chords.join(', ')}]"
      sleep 0.7 

      previous = candle
    end;nil
  end

  def reverb_with_humidity(city_name: "New York", bpm: :humidity)
    run <<-ruby
    define :play_sine_with_reverb do |freq, duration, reverb_room|
      with_fx :reverb, room: reverb_room do
        use_synth :sine
        play freq, release: duration
      end
    end
    ruby
    scope = WeatherMetric.where(city_name: city_name)

    scope.select("temp_c, humidity_percent, wind_speed_ms").order("time").each do |row|
      temperature, humidity, wind = row.temp_c, row.humidity_percent, row.wind_speed_ms
      run "play_sine_with_reverb 40+#{temperature}, #{humidity / 100}, #{wind}"
      case bpm
      when :humidity
        sleep (humidity / 100) * 0.5
      when :wind
        sleep (1.0 / wind)
      else
        sleep 0.5
      end
    end
  end

  def run msg
    puts msg
    server.run msg
  end

  def server
    @server ||= SonicPi.new 4560
  end

  def reset!
    @server = nil
    server
  end
end
