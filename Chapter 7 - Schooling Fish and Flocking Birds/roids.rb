require 'matrix'

# Boids - http://www.red3d.com/cwr/boids/

FPS = 48
ROID_SIZE = 6
WORLD = {:xmax => ROID_SIZE * 100, :ymax => ROID_SIZE * 100} # boundary of the world
POPULATION_SIZE = 50
OBSTACLE_SIZE = 30
MAGIC_NUMBER = 10 # the number of roids it will monitor

SEPARATION_RADIUS = ROID_SIZE * 2 # steer to avoid crowding of flockmates
ALIGNMENT_RADIUS  = ROID_SIZE * 35 # steer towards average heading of flockmates
COHESION_RADIUS   = ROID_SIZE * 35 # steer to move toward average position of flockmates

SEPARATION_ADJUSTMENT = 10 # how far away should roids stay from each other (small further away)
ALIGNMENT_ADJUSTMENT = 8 # how aligned are the roids with each other (smaller more aligned)
COHESION_ADJUSTMENT = 100 # how cohesive the roids are with each other (smaller more cohesive)
CENTER_RADIUS = ROID_SIZE * 10 # radius of how close to the center it stays
MAX_ROID_SPEED = 20

class Vector
  def /(x)
    if (x != 0)
      Vector[self[0]/x.to_f,self[1]/x.to_f]
    else
      self
    end
  end  
end

class Roid
  attr_reader :velocity, :position

  def initialize(slot, p, v)    
    @velocity = v # assume v is a Vector with X velocity and Y velocity as elements
    @position = p # assume p is a Vector with X and Y as elements
    @slot = slot
  end

  def distance_from(roid)
    distance_from_point(roid.position)
  end

  def distance_from_point(vector)
    x = self.position[0] - vector[0]
    y = self.position[1] - vector[1]
    Math.sqrt(x*x + y*y)    
  end

  def nearby?(threshold, roid)
    return false if roid === self
    (distance_from(roid) < threshold) and within_fov?(roid)
  end

  def within_fov?(roid)
    v1 = self.velocity - self.position
    v2 = roid.position - self.position
    cos_angle = v1.inner_product(v2)/(v1.r*v2.r)
    Math.acos(cos_angle) < 0.75 * Math::PI
  end

  def draw
    @slot.oval :left => @position[0], :top => @position[1], :radius => ROID_SIZE, :center => true
    @slot.line @position[0], @position[1], @position[0] - @velocity[0], @position[1] - @velocity[1]    
  end

  def move
    @delta = Vector[0,0]    
    %w(separate align cohere muffle avoid center).each do |action|
      self.send action
    end    
    @velocity += @delta
    @position += @velocity
    fallthrough and draw    
  end

  def separate
    distance = Vector[0,0]
    r = $roids.sort {|a,b| self.distance_from(a) <=> self.distance_from(b)}
    roids = r.first(MAGIC_NUMBER)
      roids.each do |roid|
        if nearby?(SEPARATION_RADIUS, roid)
          distance += self.position - roid.position
        end    
      end
    @delta += distance
  end

  # roids should look out for roids near it and then fly towards the center of where the rest are flying
  def align
    alignment = Vector[0,0]
    r = $roids.sort {|a,b| self.distance_from(a) <=> self.distance_from(b)}
    roids = r.first(MAGIC_NUMBER)
    roids.each do |roid|
      alignment += roid.velocity
    end
    alignment /= MAGIC_NUMBER
    @delta += alignment/ALIGNMENT_ADJUSTMENT
  end

  # roids should stick to each other
  def cohere
    average_position = Vector[0,0]
    r = $roids.sort {|a,b| self.distance_from(a) <=> self.distance_from(b)}
    roids = r.first(MAGIC_NUMBER)
    roids.each do |roid|
      average_position += roid.position
    end
    average_position /= MAGIC_NUMBER
    @delta +=  (average_position - @position)/COHESION_ADJUSTMENT
  end

  # get the roids to move around the center of the displayed world
  def center
    @delta -= (@position - Vector[WORLD[:xmax]/2, WORLD[:ymax]/2]) / CENTER_RADIUS
  end


  # muffle the speed of the roid to dampen the swing
  # swing causes the roid to move too quickly out of range to be affected by the rules
  def muffle
    if @velocity.r > MAX_ROID_SPEED
      @velocity /= @velocity.r 
      @velocity *= MAX_ROID_SPEED  
    end
  end

  def center
    @delta -= (@position - Vector[WORLD[:xmax]/2, WORLD[:ymax]/2]) / CENTER_RADIUS
  end

  def fallthrough
    x = case 
    when @position[0] < 0            then WORLD[:xmax] + @position[0]
    when @position[0] > WORLD[:xmax] then WORLD[:xmax] - @position[0]
    else @position[0]
    end
    y = case 
    when @position[1] < 0            then WORLD[:ymax] + @position[1]
    when @position[1] > WORLD[:ymax] then WORLD[:ymax] - @position[1]
    else @position[1]
    end 
    @position = Vector[x,y]    
  end

  # avoid other objects
  def avoid  
    $obstacles.each do |obstacle|
      if distance_from_point(obstacle) < (OBSTACLE_SIZE + ROID_SIZE*2)
        @delta += (self.position - obstacle)
      end    
    end
  end

end

Shoes.app(:title => 'Roids', :width => WORLD[:xmax], :height => WORLD[:ymax]) do
  stroke slategray
  fill gainsboro

  $roids = []
  $obstacles = []
  POPULATION_SIZE.times do
    random_location = Vector[rand(WORLD[:xmax]),rand(WORLD[:ymax])]
    random_velocity = Vector[rand(11)-5,rand(11)-5]
    $roids << Roid.new(self, random_location, random_velocity)     
  end

  animate(FPS) do 
    click do |button, left, top|
      $obstacles << Vector[left,top]
    end

    clear do
      background ghostwhite
      $obstacles.each do |obstacle| 
        oval(:left => obstacle[0], :top => obstacle[1], :radius => OBSTACLE_SIZE, :center => true, :stroke => red, :fill => pink)
      end
      $roids.each do |roid| roid.move; end
    end
  end
end
