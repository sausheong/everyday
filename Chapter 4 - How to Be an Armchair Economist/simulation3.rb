require 'csv'

SIMULATION_DURATION = 150
NUM_OF_PRODUCERS = 10
NUM_OF_CONSUMERS = 10

MAX_STARTING_SUPPLY = Hash.new
MAX_STARTING_SUPPLY[:ducks] = 20
MAX_STARTING_SUPPLY[:chickens] = 20
SUPPLY_INCREMENT = 60

COST = Hash.new
COST[:ducks] = 24
COST[:chickens] = 12

MAX_ACCEPTABLE_PRICE = Hash.new
MAX_ACCEPTABLE_PRICE[:ducks] = COST[:ducks] * 10
MAX_ACCEPTABLE_PRICE[:chickens] = COST[:chickens] * 10

MAX_STARTING_PROFIT = Hash.new
MAX_STARTING_PROFIT[:ducks] = 15
MAX_STARTING_PROFIT[:chickens] = 15
PRICE_INCREMENT = 1.1
PRICE_DECREMENT = 0.9

PRICE_CONTROL = Hash.new
PRICE_CONTROL[:ducks] = 28
PRICE_CONTROL[:chickens] = 16

class Producer
  attr_accessor :supply, :price
  def initialize
    @supply, @supply[:chickens], @supply[:ducks] = {}, 0, 0
    @price, @price[:chickens], @price[:ducks] = {}, 0, 0
  end

  def change_pricing
    @price.each do |type, price|
      if @supply[type] > 0
        @price[type] *= PRICE_DECREMENT unless @price[type] < COST[type]
      else
        @price[type] *= PRICE_INCREMENT unless @price[type] > PRICE_CONTROL[type]
      end
    end
  end

  def generate_goods
    to_produce = Market.average_price(:chickens) > Market.average_price(:ducks) ? :chickens : :ducks
    @supply[to_produce] += (SUPPLY_INCREMENT) if @price[to_produce] > COST[to_produce]
  end
  
  def produce
    change_pricing
    generate_goods
  end
end

class Consumer
  attr_accessor :demands

  def initialize
    @demands = 0
  end

  def buy(type)
    until @demands <= 0 or Market.supply(type) <= 0
      cheapest_producer = Market.cheapest_producer(type)
      if cheapest_producer
        @demands *= 0.5 if cheapest_producer.price[type] > MAX_ACCEPTABLE_PRICE[type]
        cheapest_supply = cheapest_producer.supply[type]
        if @demands > cheapest_supply then
          @demands -= cheapest_supply
          cheapest_producer.supply[type] = 0
        else        
          cheapest_producer.supply[type] -= @demands
          @demands = 0
        end
      end
    end
  end
end

class Market
  def self.average_price(type)
    ($producers.inject(0.0) { |memo, producer| memo + producer.price[type]}/$producers.size).round(2)
  end  

  def self.supply(type)
    $producers.inject(0) { |memo, producer| memo + producer.supply[type] }
  end

  def self.demands
    $consumers.inject(0) { |memo, consumer| memo + consumer.demands }
  end

  def self.cheaper(a,b)
    cheapest_a_price = $producers.min_by {|f| f.price[a]}.price[a]
    cheapest_b_price = $producers.min_by {|f| f.price[b]}.price[b]
    cheapest_a_price < cheapest_b_price ? a : b
  end 

  def self.cheapest_producer(type)
    producers = $producers.find_all {|producer| producer.supply[type] > 0} 
    producers.min_by{|producer| producer.price[type]}
  end
end

def write(name,data)
  CSV.open("#{name}.csv", 'w') do |csv|
    data.each do |row|
      csv << row
    end
  end  
end

$producers = []
NUM_OF_PRODUCERS.times do
  producer = Producer.new
  producer.price[:chickens] = COST[:chickens] + rand(MAX_STARTING_PROFIT[:chickens])
  producer.price[:ducks]    = COST[:ducks] + rand(MAX_STARTING_PROFIT[:ducks])
  producer.supply[:chickens] = rand(MAX_STARTING_SUPPLY[:chickens])
  producer.supply[:ducks]    = rand(MAX_STARTING_SUPPLY[:ducks])
  $producers << producer
end

$consumers = []
NUM_OF_CONSUMERS.times do
  $consumers << Consumer.new
end

$generated_demand  = []
SIMULATION_DURATION.times {|n| $generated_demand << ((Math.sin(n)+2)*20).round }

price_data, supply_data = [], []
SIMULATION_DURATION.times do |t|
  $consumers.each do |consumer|
    consumer.demands = $generated_demand[t]
  end
  supply_data << [t, Market.supply(:chickens), Market.supply(:ducks)]
  $producers.each do |producer|
    producer.produce    
  end
  cheaper_type = Market.cheaper(:chickens, :ducks)
  until Market.demands == 0 or Market.supply(cheaper_type) == 0  do
    $consumers.each do |consumer|
      consumer.buy cheaper_type
    end
  end
  price_data << [t, Market.average_price(:chickens), Market.average_price(:ducks)]
end

write("price_data", price_data)
write("supply_data", supply_data)