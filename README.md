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

### You can...

* from general to specific *

- report_everything(page, status, twitter_update)
- report_buckets(bucket_names, status, twitter_update)
- report_bucket(bucket_name, status, twitter_update)
- report_radars(bucket_name, radar_names, status, twitter_update)
- report_radar(bucket_name, radar_name, status, twitter_update)

#### Important Notes

- `status` must be either `investigating|identified|monitoring|resolved`.
- RunScope likes to throw ISEs if you specify invalid IDs or names, just keep this in mind.

### Glossary

- bucket: A group of radars/tests.
- radar: A test with one or more assertions.
- twitter_update parameter: StatusPage can spit incidents out to Twitter, this is a toggle for this functionality.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment. 

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/[my-github-username]/runscope_statuspage/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
