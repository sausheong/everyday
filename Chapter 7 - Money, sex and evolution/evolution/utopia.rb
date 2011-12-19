require 'matrix'
require 'csv'
require 'enc/trans/transdb'
require './parameters'
require './roid'
require './food'

class Vector
  def /(x)
    if (x != 0)
      Vector[self[0]/x.to_f,self[1]/x.to_f]
    else
      self
    end
  end  
end

def random_location
  Vector[rand(WORLD[:xmax]),rand(WORLD[:ymax])]
end

def populate
  POPULATION_SIZE.times do |i|
    random_velocity = Vector[rand(11)-5,rand(11)-5]
    $roids << Roid.new(self, random_location, random_velocity, i)     
  end  
end

def scatter_food
  FOOD_COUNT.times do
    $food << Food.new(self, random_location)     
  end  
end

def randomly_scatter_food(probability)
  if (0..probability).include?(rand(100))
    $food << Food.new(self, random_location)
  end  
end

def write(data)
  CSV.open('data.csv', 'w') do |csv|
    data.each do |row|
      csv << row
    end
  end  
end

Shoes.app(:title => 'Utopia', :width => WORLD[:xmax], :height => WORLD[:ymax]) do
  background ghostwhite
  stroke slategray

  $roids = []
  $food = []
  data = []
  populate
  scatter_food
  
  time = END_OF_THE_WORLD
  
  animate(FPS) do 
    randomly_scatter_food 30
    clear do
      fill yellowgreen      
      $food.each do |food| food.tick; end
      fill gainsboro      
      $roids.each do |roid| 
        roid.tick 
      end
      mean_metabolism = $roids.inject(0.0){ |sum, el| sum + el.metabolism}.to_f / $roids.size
      mean_vision_range = $roids.inject(0.0){ |sum, el| sum + el.vision_range}.to_f / $roids.size
      data << [$roids.size, mean_metabolism.round(2), mean_vision_range.round(2)]      
      para "countdown: #{time}"
      para "population: #{$roids.size}"      
      para "metabolism: #{mean_metabolism.round(2)}"
      para "vision range: #{mean_vision_range.round(2)}"
    end
    
    time -= 1
    close & write(data) if time < 0 or $roids.size <= 0        
  end
end
