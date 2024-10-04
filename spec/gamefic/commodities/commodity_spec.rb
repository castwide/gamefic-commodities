# frozen_string_literal: true

RSpec.describe Gamefic::Commodities::Commodity do
  it 'groups' do
    room = Room.new(name: 'room')
    thing1 = Commodity.new(name: 'thing', parent: room)
    thing2 = Commodity.new(name: 'thing')
    thing2.parent = room
    expect(room.children).to eq([thing1])
    expect(thing1.quantity).to be(2)
    expect(thing2.parent).to be_nil
  end

  it 'uses quantities for indefinite articles' do
    commodity = Commodity.new(name: 'thing')
    expect(commodity.indefinitely).to eq('a thing')
    commodity.quantity = 2
    expect(commodity.indefinitely).to eq('2 things')
  end

  describe '#split' do
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

    it 'raises for too many' do
      thing = Commodity.new(name: 'thing', quantity: 1)
      expect { thing.split(5) }.to raise_error(Commodity::CommodityError)
    end
  end

  describe '#count' do
    it 'raises for amounts below 1' do
      thing = Commodity.new(name: 'thing', quantity: 1)
      expect { thing.count(0) }.to raise_error(Commodity::CommodityError)
    end
  end
end
