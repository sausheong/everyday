require 'csv'
require './restroom'

# Simulation script 3 (and 4)

max_frequency = 5 # how many times a person goes to the restroom with the period
facilities_per_restroom = 3
max_use_duration = 1
population_range = 10..600 # using a population range of 0 to 500 people
max_num_of_restrooms = 1..4

max_num_of_restrooms.each do |num_of_restrooms|
  data = {}
  population_range.step(10).each do |population_size|
    Person.population.clear
    population_size.times { Person.population << Person.new(rand(max_frequency)+1, rand(max_use_duration)+1) } # create the population
    data[population_size] = [] #initialize the temp data store
    restrooms = []
    num_of_restrooms.times {restrooms << Restroom.new(facilities_per_restroom)} # create the restroom    

    # iterate over a period
    DURATION.times do |t|
      restroom_shortest_queue = restrooms.min {|n,m| n.queue.size <=> m.queue.size }
      data[population_size] <<  restroom_shortest_queue.queue.size # we want the queue size
      restrooms.each {|restroom|
        queue = restroom.queue.clone # clone the queue so that we don't mess up the live one
        restroom.queue.clear # clear the queue

        # let everyone from the queue enter the restroom first
        until queue.empty? 
          restroom.enter queue.shift # de-queue the first person in line and move him to the restroom
        end
      }
      # for each person in the population check if he needs to go
      Person.population.each do |person|
        person.frequency = (t > 270 and t < 390) ? 12 : rand(max_frequency)+1 # peak for lunch time
        if person.need_to_go?
          restroom = restrooms.min {|a,b| a.queue.size <=> b.queue.size}        
          restroom.enter person
        end
      end
      restrooms.each {|restroom| restroom.tick }
    end

  end

  # write the temp store into CSV
  CSV.open("simulation3-#{num_of_restrooms}.csv", 'w') do |csv|
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
end