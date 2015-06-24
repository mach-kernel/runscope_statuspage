# RunscopeStatuspage

Do you use [RunScope](https://runscope.com) to test your API, and [StatusPage](https://statuspage.io) to show it all off to your customers? Don't want to write bindings for both APIs? If yes, RunscopeStatuspage is perfect for you.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'runscope_statuspage'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install runscope_statuspage

## Usage

In a nutshell, each call will grab metrics from RunScope then send them over to StatusPage, once per call. There is no scheduling done by this gem, it is left as an exercise for the reader. Ideally, you will want to use something such as [Sidekiq](https://github.com/mperham/sidekiq) or [Resque](https://github.com/resque/resque) to fire these jobs off every few minutes/hours. Keep in mind that StatusPage will rate-limit requests to its API, one request per minute. 


### Poll for incidents

*from general to specific:*

- *report_everything:* Report all radars of all buckets.
```ruby
opts = {:status => "page status (either 'investigating|identified|monitoring|resolved')",
:twitter_update => 'do you want to post status to twitter (bool)',
:fail_on => 'number of failures to induce statuspage update (int, default 0)'}
```
- *report_buckets:* Report all radars of buckets in list.
```ruby
opts = {:bucket_names => 'list of names of buckets containing radars',
:status => "page status (either 'investigating|identified|monitoring|resolved')",
:twitter_update => 'do you want to post status to twitter (bool)',
:fail_on => 'number of failures to induce statuspage update (int, default 0)'}
```
- *report_bucket:* Report all radars in bucket.
```ruby
opts = {:bucket_name => 'name of bucket containing radars',
:status => "page status (either 'investigating|identified|monitoring|resolved')",
:twitter_update => 'do you want to post status to twitter (bool)',
:fail_on => 'number of failures to induce statuspage update (int, default 0)'}
```
- *report_radars:* Report radars in list for given bucket.
```ruby
opts = {:bucket_name => 'name of bucket containing radars',
:radar_names => 'list of names of radars within bucket',
:status => "page status (either 'investigating|identified|monitoring|resolved')",
:twitter_update => 'do you want to post status to twitter (bool)',
:fail_on => 'number of failures to induce statuspage update (int, default 0)'}
```
- *report_radar:* Report one radar in bucket.
```ruby
opts = {:bucket_name => 'name of bucket containing radars',
:radar_name => 'name of radar within bucket',
:status => "page status (either 'investigating|identified|monitoring|resolved')",
:twitter_update => 'do you want to post status to twitter (bool)',
:fail_on => 'number of failures to induce statuspage update (int, default 0)'}
```

#### Important Notes

- `status` must be either `investigating|identified|monitoring|resolved`.
- RunScope likes to throw ISEs if you specify invalid IDs or names, just keep this in mind.
- If an exception is thrown while calling `latest_radar_result` in any of the above, it will not halt execution. This is to prevent breaking integrations when a new test is added and `runscope_statuspage` polls before it has the chance to run.

#### Runscope Bindings
Usage: 

```ruby
@client = RunscopeStatuspage::RunscopeAPI.new "token"
```

- **buckets**: Get list of buckets.
- **bucket_id_by_name(name)**: Get bucket ID from its name.
- **radars(bucket)**: Get list of radars for bucket (by ID).
- **get_radar(bucket, radar)**: Get radar from bucket (by both IDs)
- **latest_radar_result(bucket, radar)**: Get latest result from a radar, by ID.
- **messages(bucket, count)**: Get latest messages for bucket (by name).
- **message_detail(bucket, message)**: Get message detail (both by ID).

#### Statuspage Bindings 
Usage: 

```ruby
@client = RunscopeStatuspage::StatspageAPI.new "token"
```

- **create_realtime_incident(page, name, msg, status, twitter)**: Creates a realtime incident.
- **push_metric_data(page_id, metric_id, data, timestamp)**: Publish data for a page metric. Data must be either int/float.
- **clear_metric_data(page_id, metric_id)**: Clear metric data for a specific page, for a specific metric.

### Glossary

- bucket: A group of radars/tests.
- radar: A test with one or more assertions.
- twitter_update parameter: StatusPage can spit incidents out to Twitter, this is a toggle for this functionality.

## Changelog

0.1.4
* Added attr_accessor for `@rs` and `@sp`.

0.1.3
* Changed all functions in `RunscopeStatuspage` to use `options = {}` hash for better readability.
* Added `opts[:fail_on]` threshold parameter for greater granularity.
* Fixed no parameter issue on `StatuspageAPI.clear_metric_data`
* More informative exception messages
* Better error handling (not being able to retrieve a radar's latest result will not bring the whole sweep of operations for that bucket down).

0.1.2
* Added Statuspage metrics bindings.

0.1.1
* Fixed bugs + edge cases that shipped with release.

0.1.0
* Initial Release

## Development and Contributions

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment. 

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

----

1. Fork it ( https://github.com/[my-github-username]/runscope_statuspage/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## License

The MIT License (MIT)

Copyright (c) 2015 David Stancu

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
