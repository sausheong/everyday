require 'csv'

SIMULATION_DURATION = 150
NUM_OF_PRODUCERS = 10
NUM_OF_CONSUMERS = 10

MAX_STARTING_SUPPLY = 20
SUPPLY_INCREMENT = 80

COST = 5
MAX_ACCEPTABLE_PRICE = COST * 10
MAX_STARTING_PROFIT = 5
PRICE_INCREMENT = 1.1
PRICE_DECREMENT = 0.9


class Producer
  attr_accessor :supply, :price
  def initialize
    @supply, @price = 0, 0
  end

  def generate_goods
   @supply += SUPPLY_INCREMENT if @price > COST
  end

  def produce
    if @supply > 0
      @price *= PRICE_DECREMENT unless @price < COST
    else
      @price *= PRICE_INCREMENT
      generate_goods
    end
  end
end

class Consumer
  attr_accessor :demands

  def initialize
    @demands = 0
  end

  def buy    
    until @demands <= 0 or Market.supply <= 0 
      cheapest_producer = Market.cheapest_producer
      if cheapest_producer
        @demands *= 0.5 if cheapest_producer.price > MAX_ACCEPTABLE_PRICE
        cheapest_supply = cheapest_producer.supply
        if @demands > cheapest_supply
          @demands -= cheapest_supply
          cheapest_producer.supply = 0
        else        
          cheapest_producer.supply -= @demands
          @demands = 0
        end
      end
    end
  end
end

class Market
  def self.average_price
    ($producers.inject(0.0) { |memo, producer| memo + producer.price}/$producers.size).round(2)
  end  

  def self.supply
    $producers.inject(0) { |memo, producer| memo + producer.supply }
  end

  def self.demand
    $consumers.inject(0) { |memo, consumer| memo + consumer.demands }
  end

  def self.cheapest_producer
    producers = $producers.find_all {|f| f.supply > 0} 
    producers.min_by{|f| f.price}
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
  producer.price = COST + rand(MAX_STARTING_PROFIT)
  producer.supply = rand(MAX_STARTING_SUPPLY)
  $producers << producer
end

$consumers = []
NUM_OF_CONSUMERS.times do
  $consumers << Consumer.new
end

$generated_demand  = []
SIMULATION_DURATION.times {|n| $generated_demand << ((Math.sin(n)+2)*20).round  }

demand_supply, price_demand = [], []

SIMULATION_DURATION.times do |t|
  $consumers.each do |consumer|
    consumer.demands = $generated_demand[t]
  end
  demand_supply << [t, Market.demand, Market.supply]
  
  $producers.each do |producer|
    producer.produce
  end
  
  price_demand << [t, Market.average_price, Market.demand]
  
  until Market.demand == 0 or Market.supply == 0 do
    $consumers.each do |consumer|
      consumer.buy 
    end
  end
end

write("demand_supply", demand_supply)
write("price_demand", price_demand)
