# frozen_string_literal: true

RSpec.describe Gamefic::Commodities do
  it 'has a version number' do
    expect(Gamefic::Commodities::VERSION).not_to be nil
  end

  it 'splits' do
    thing1 = Commodity.new(name: 'thing', quantity: 4)
    thing2 = thing1.split(1)
    expect(thing1.quantity).to be(3)
    expect(thing2.quantity).to be(1)
  end

  it 'splits with except' do
    thing1 = Commodity.new(name: 'thing', quantity: 4)
    thing2 = thing1.split(3)
    expect(thing1.quantity).to be(1)
    expect(thing2.quantity).to be(3)
  end

  it 'raises for amounts below 1' do
    thing = Commodity.new(name: 'thing', quantity: 1)
    expect { thing.split(0) }.to raise_error(Commodity::CommodityError)
  end

  it 'raises for too many' do
    thing = Commodity.new(name: 'thing', quantity: 1)
    expect { thing.split(5) }.to raise_error(Commodity::CommodityError)
  end
end
