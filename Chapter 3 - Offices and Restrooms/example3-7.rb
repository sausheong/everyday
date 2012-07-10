require 'csv'
require './restroom'

# Simulation script 2

frequency = 3 # how many times a person goes to the restroom with the period
use_duration = 1
population_size = 1000 # using a population range of 1000 people
facilities_per_restroom_range = 1..30
data = {}
facilities_per_restroom_range.each do |facilities_per_restroom|
  Person.population.clear
  population_size.times { Person.population << Person.new(frequency, use_duration) } # create the population
  data[facilities_per_restroom] = [] #initialize the temp data store
  restroom = Restroom.new facilities_per_restroom # create the restroom    

  # iterate over a period
  DURATION.times do |t|
    queue = restroom.queue.clone # clone the queue so that we don't mess up the live one
    restroom.queue.clear # clear the queue
    data[facilities_per_restroom] << queue.size # we want the queue size
    
    # let everyone from the queue enter the restroom first
    until queue.empty? 
      restroom.enter queue.shift # de-queue the first person in line and move him to the restroom
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
CSV.open('simulation2.csv', 'w') do |csv|
  # setup labels
  lbl = []
  facilities_per_restroom_range.each {|facilities_per_restroom| lbl << facilities_per_restroom  }
  csv << lbl  
  
  # write the data
  DURATION.times do |t|
    row = []
    facilities_per_restroom_range.each do |facilities_per_restroom|
      row << data[facilities_per_restroom][t]
    end
    csv << row
  end
end
