# frozen_string_literal: true

RSpec.describe Gamefic::Commodities::Actions do
  let(:klass) do
    Class.new(Gamefic::Plot) do
      include Gamefic::Standard
      include Gamefic::Commodities

      attr_seed :room, Gamefic::Standard::Room, name: 'room'

      introduction { |actor| actor.parent = room }
    end
  end

  it 'reports quantities of available entities' do
    plot = klass.new
    player = plot.introduce
    Gamefic::Commodities::Commodity.new(name: 'thing', parent: plot.room, quantity: 5)
    player.perform 'look thing'
    expect(player.messages).to include('5 of them')
  end

  it 'reports quantities of children' do
    plot = klass.new
    player = plot.introduce
    Gamefic::Commodities::Commodity.new(name: 'thing', parent: player, quantity: 5)
    player.perform 'look thing'
    expect(player.messages).to include('5 of them')
  end

  it 'combines on take' do
    plot = klass.new
    player = plot.introduce
    Gamefic::Commodities::Commodity.new(name: 'thing', parent: plot.room)
    Gamefic::Commodities::Commodity.new(name: 'thing', parent: player)
    player.perform 'take thing'
    expect(plot.room.children).to eq([player])
    expect(player.children).to be_one
    expect(player.children.first.quantity).to eq(2)
  end

  it 'reports numbers above quantity' do
    plot = klass.new
    player = plot.introduce
    Gamefic::Commodities::Commodity.new(name: 'thing', parent: plot.room)
    player.perform 'take 2 things'
    expect(player.messages).to include('There is only 1')
  end

  it 'reports numbers below 1' do
    plot = klass.new
    player = plot.introduce
    Gamefic::Commodities::Commodity.new(name: 'thing', parent: plot.room)
    player.perform 'take 0 things'
    expect(player.messages).to include('1 or more')
  end

  it 'splits on valid quantities' do
    plot = klass.new
    player = plot.introduce
    Gamefic::Commodities::Commodity.new(name: 'thing', parent: plot.room, quantity: 5)
    player.perform 'take 3 things'
    expect(player.children.last.quantity).to be(3)
    expect(plot.room.children.last.quantity).to be(2)
  end

  it 'works with exact numbers' do
    plot = klass.new
    player = plot.introduce
    Gamefic::Commodities::Commodity.new(name: 'thing', parent: plot.room)
    Gamefic::Commodities::Commodity.new(name: 'thing', parent: player)
    player.perform 'take 1 thing'
    expect(plot.room.children).to eq([player])
    expect(player.children).to be_one
    expect(player.children.first.quantity).to eq(2)
  end

  it 'collects' do
    plot = klass.new
    player = plot.introduce
    Gamefic::Commodities::Commodity.new(name: 'thing', parent: plot.room)
    supporter = Gamefic::Standard::Supporter.new(name: 'supporter', parent: plot.room)
    Gamefic::Commodities::Commodity.new(name: 'thing', parent: supporter)
    player.perform 'take all the things'
    expect(plot.room.children).to eq([player, supporter])
    expect(player.children).to be_one
    expect(player.children.first.quantity).to eq(2)
  end

  it 'disambiguates' do
    plot = klass.new
    narrator = Gamefic::Narrator.new(plot)
    player = plot.introduce
    supporter = Gamefic::Standard::Supporter.new(name: 'supporter', parent: plot.room)
    container = Gamefic::Standard::Container.new(name: 'container', open: true, parent: plot.room)
    taken = Gamefic::Commodities::Commodity.new(name: 'thing', parent: supporter)
    Gamefic::Commodities::Commodity.new(name: 'thing', parent: container)
    player.perform 'take thing'
    expect(player.messages).to match(/Where.*?supporter.*?container/)
    narrator.start
    player.queue.push 'supporter'
    narrator.finish
    expect(supporter.children).to be_empty
    expect(player.children).to eq([taken])
  end

  it 'proceeds on non-commodities with quantities' do
    plot = klass.new
    player = plot.introduce
    item = Gamefic::Standard::Item.new(name: 'thing', parent: plot.room)
    player.perform 'take 2 thing'
    expect(player.messages).to include("don't know what you mean")
    expect(item.parent).to be(plot.room)
  end

  it 'destroys orphaned commodities' do
    plot = klass.new
    player = plot.introduce
    plot.make Gamefic::Commodities::Commodity, name: 'thing'
    plot.update_blocks.each(&:call)
    expect(plot.entities).to eq([plot.room, player])
  end

  it 'drops quantities' do
    plot = klass.new
    player = plot.introduce
    plot.make Gamefic::Commodities::Commodity, name: 'thing', quantity: 5, parent: player
    player.perform 'drop 2 things'
    expect(player.children.first.quantity).to eq(3)
    expect(plot.room.children.last.quantity).to eq(2)
  end

  it 'inserts quantities' do
    plot = klass.new
    player = plot.introduce
    plot.make Gamefic::Commodities::Commodity, name: 'thing', quantity: 5, parent: player
    receptacle = plot.make Gamefic::Standard::Receptacle, name: 'receptacle', parent: plot.room
    player.perform 'insert 2 things in receptacle'
    expect(player.children.first.quantity).to eq(3)
    expect(receptacle.children.first.quantity).to eq(2)
  end

  it 'places quantities' do
    plot = klass.new
    player = plot.introduce
    plot.make Gamefic::Commodities::Commodity, name: 'thing', quantity: 5, parent: player
    receptacle = plot.make Gamefic::Standard::Supporter, name: 'supporter', parent: plot.room
    player.perform 'place 2 things on supporter'
    expect(player.children.first.quantity).to eq(3)
    expect(receptacle.children.first.quantity).to eq(2)
  end
end
