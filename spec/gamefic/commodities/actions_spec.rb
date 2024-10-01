# frozen_string_literal: true

RSpec.describe Gamefic::Commodities::Actions do
  let(:klass) do
    Class.new(Gamefic::Plot) do
      include Gamefic::Standard
      include Gamefic::Commodities::Actions

      attr_seed :room, Room, name: 'room'

      introduction { |actor| actor.parent = room }
    end
  end

  it 'combines on take' do
    plot = klass.new
    player = plot.introduce
    Commodity.new(name: 'thing', parent: plot.room)
    Commodity.new(name: 'thing', parent: player)
    player.perform 'take thing'
    expect(plot.room.children).to eq([player])
    expect(player.children).to be_one
    expect(player.children.first.quantity).to eq(2)
  end

  it 'returns quantities on examine' do
    plot = klass.new
    player = plot.introduce
    Commodity.new(name: 'thing', parent: plot.room, quantity: 2)
    player.perform 'look thing'
    expect(player.messages).to include('There are 2')
  end

  it 'reports numbers above quantity' do
    plot = klass.new
    player = plot.introduce
    Commodity.new(name: 'thing', parent: plot.room)
    player.perform 'take 2 things'
    expect(player.messages).to include('There is only 1')
  end

  it 'reports numbers below 1' do
    plot = klass.new
    player = plot.introduce
    Commodity.new(name: 'thing', parent: plot.room)
    player.perform 'take 0 things'
    expect(player.messages).to include('1 or more')
  end

  it 'works with exact numbers' do
    plot = klass.new
    player = plot.introduce
    Commodity.new(name: 'thing', parent: plot.room)
    Commodity.new(name: 'thing', parent: player)
    player.perform 'take 1 thing'
    expect(plot.room.children).to eq([player])
    expect(player.children).to be_one
    expect(player.children.first.quantity).to eq(2)
  end

  it 'collects' do
    plot = klass.new
    player = plot.introduce
    Commodity.new(name: 'thing', parent: plot.room)
    supporter = Supporter.new(name: 'supporter', parent: plot.room)
    Commodity.new(name: 'thing', parent: supporter)
    player.perform 'take all the things'
    expect(plot.room.children).to eq([player, supporter])
    expect(player.children).to be_one
    expect(player.children.first.quantity).to eq(2)
  end
end
