# ServiceButler

A simple gem to interface directly with microservice functions trough a unified API.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'service_butler'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install service_butler

## Usage

These services are a miniature function of Activerecord. 
The following methods are available:
- `.find([ID])` (When `action` is defined) (also with `!`)
- `.find_by([KEY => VALUE])` (When `action` is defined) (also with `!`)
- `.where([KEY => VALUE])` (When `batch_action` is defined) 
- `.all` (When `batch_action` is defined) 

It will autodetect the available fields and create methods accordingly;
```ruby
item = ExampleService.find(1) # => ExampleService
item.name # => "John Doe"
```

### GraphQL Service
To define a graphql service you can use the following example;
```ruby
class ExampleService < ServiceButler::GraphQLService
  host 'http://localhost:3002/graphql' # Endpoint location
  action 'event' # Single record fetch
  batch_action 'events' # Batch record fetch endpoint
end
```

Both `action` and `batch_action` are optional. But at lease one of them is required

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/cgservices/service_butler.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
