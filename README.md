# SidekiqFakeScheduler

This gem provides behavior similar to [sidekiq](https://github.com/mperham/sidekiq)'s inline mode but respects starting dates for scheduled jobs.
This is especially useful for integration testing when asserting that certain things happen within a certain time frame.

## Example

Imagine you implemented a reminder loop like this:

```ruby
class ReminderWorker
  def perform(phase)
    return if phase > 2
    # send reminder email
    ReminderWorker.perform_in(5.days, phase + 1)
  end
end
```

Then, using this gem, you could test it as follows (I used timecop to manipulate the clock, however, this is not a requirement):

```ruby
RSpec.describe ReminderWorker do
  after { Timecop.return }

  # schedule first reminder for in 5 days
  before { ReminderWorker.perform_in(5.days, 1) }

  # perform all workers that are due
  before { SidekiqFakeScheduler.work }

  it 'should not have sent an email' { ... }

  context '5 days later' do
    # perform all workers that are due
    before do
      Timecop.freeze 5.days.from_now
      SidekiqFakeScheduler.work
    end

    it 'should have sent 1 email' { ... }
  end

  context '10 days later' do
    # perform all workers that are due
    before do
      Timecop.freeze 10.days.from_now
      SidekiqFakeScheduler.work
    end

    it 'should have sent 2 emails' { ... }
  end

  context '15 days later' do
    # perform all workers that are due
    before do
      Timecop.freeze 15.days.from_now
      SidekiqFakeScheduler.work
    end

    it 'should have stopped sending emails after 2 reminders' { ... }
  end
end
```

## Installation

Add this line to your application's Gemfile:

```ruby
group :test do
  gem 'sidekiq-fake-scheduler'
end
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sidekiq-fake-scheduler

## Usage

Whenever you want to perform sidekiq jobs just call `SidekiqFakeScheduler.work`.
Use timecop or a similar library to travel in time.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/dpoetzsch/sidekiq-fake-scheduler. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Sidekiq::Mocks project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/dpoetzsch/sidekiq-fake-scheduler/blob/master/CODE_OF_CONDUCT.md).
