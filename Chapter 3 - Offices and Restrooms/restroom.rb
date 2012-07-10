DURATION = 9 * 60 # minutes

# Models for the restroom, facility and person

class Restroom
  attr_reader :queue # a queue of people waiting to enter the restroom
  attr_reader :facilities

  def initialize(facilities_per_restroom=3)
    @queue = []
    @facilities = [] # the facilties in this restroom
    facilities_per_restroom.times { @facilities << Facility.new }    
  end

  def enter(person)
    unoccupied_facility = @facilities.find { |facility| not facility.occupied?}
    if unoccupied_facility
      unoccupied_facility.occupy person
    else
      @queue << person
      Person.population.delete person
    end
  end

  def tick
    @facilities.each { |f| f.tick }
  end

end

class Facility
  def initialize
    @occupier = nil # no one is occupying this facility at the start
    @duration = 0 # how long the facility has been occupied
  end

  def occupy(person)
    unless occupied? # if this facility is occupied return false
      @occupier = person # this facility is occupied!
      @duration = 1 # this facility has been occupied for 1 tick
      Person.population.delete person # remove the person from the population since he's in the queue now
      true
    else
      false
    end
  end

  def occupied?
    not @occupier.nil?
  end

  def vacate
    Person.population << @occupier # put the person back into the population
    @occupier = nil
  end

  def tick    
    if occupied? and @duration > @occupier.use_duration
      vacate
      @duration = 0
    elsif occupied?
      @duration += 1 
    end
  end  
end

class Person
  @@population = []
  attr_reader :use_duration 
  attr_accessor :frequency
  
  def initialize(frequency=4,use_duration=1)
    @frequency = frequency # how many times the person uses the facility over the experiment period
    @use_duration = use_duration  # how long this person occupies the facility
  end    

  def self.population
    @@population
  end

  def need_to_go?
    rand(DURATION) + 1 <= @frequency
  end
end