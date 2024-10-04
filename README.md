# Gamefic::Commodities

A groupable Gamefic entity.

Commodities are grouped by default. When a commodity gets added to a parent
that already contains a commodity with the same class and name, they get
combined, i.e., the existing commodity's quantity is increased by the new
commodity's quantity, and the other commodity is destroyed.

Players can specify quantities in commands, e.g., `take 1 coin`.

## Installation

Add the library to your Gamefic project's Gemfile:

```
gem 'gamefic-commodities'
```

Run `bundle install`.

Add the requirement to your project's code (typically in `main.rb`):

```
require 'gamefic-commodities'
```

## Usage

The `Commodity` entity and related actions are automatically imported into `Gamefic::Standard`.

Example of adding a commodity:

```ruby
class Example::Plot < Gamefic::Plot
  include Gamefic::Standard

  attr_seed :room, Room,
            name: 'room'

  make_seed Commodity,
            name: 'coin',
            quantity: 2,
            parent: _attr(:room)

  introduction do |actor|
    actor.parent = room
  end
end
```

Example gameplay:

    > look
    You see 2 coins.
    > take coin
    You take 2 coins.
    > drop 1 coin
    You drop a coin.
    > look
    You see a coin.
    > inventory
    You're carrying a coin.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/castwide/gamefic-commodity.
