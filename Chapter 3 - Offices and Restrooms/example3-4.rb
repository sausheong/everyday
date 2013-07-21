require 'csv'
require './restroom'

# Simulation script 1 

frequency = 3 # how many times a person goes to the restroom with the period
facilities_per_restroom = 3
use_duration = 1
population_range = 10..600 # using a population range of 0 to 500 people

data = {}
population_range.step(10).each do |population_size|
  Person.population.clear
  population_size.times { Person.population << Person.new(frequency, use_duration) } # create the population
  data[population_size] = [] #initialize the temp data store
  restroom = Restroom.new facilities_per_restroom # create the restroom    

  # iterate over a period
  DURATION.times do |t|
    data[population_size] << restroom.queue.size # we want the queue size
    queue = restroom.queue.clone # create a temporary queue so that we can sort people between the facilities and the restroom queue for this "tick"
    restroom.queue.clear # clear the queue to prepare for the sorting
    
    # take each person from the temporary queue and try adding them to a facility
    until queue.empty? 
      restroom.enter queue.shift # de-queue the person at the front of the line, place in an unoccupied facility or, if none, back to the restroom queue
    end
    

    # for each person in the population check if he needs to go
    Person.population.each do |person|
      if person.need_to_go?
        restroom.enter person
      end
    end
    restroom.tick
  end
end

# write the temp store into CSV
CSV.open('simulation1.csv', 'w') do |csv|
  # setup labels
  lbl = []
  population_range.step(10).each {|population_size| lbl << population_size  }
  csv << lbl  
  
  # write the data
  DURATION.times do |t|
    row = []
    population_range.step(10).each do |population_size|
      row << data[population_size][t]
    end
    csv << row
  end
end
