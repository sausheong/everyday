class Roid
  attr_reader :velocity, :position, :energy, :uid, :sex, :lifespan, :age, :metabolism, :vision_range
  
  def initialize(slot, p, v, id) 
    @velocity = v # assume v is a Vector with X velocity and Y velocity as elements
    @position = p # assume p is a Vector with X and Y as elements
    @slot = slot
    @energy = rand(MAX_ENERGY)
    @uid = id
    @sex = rand(2) == 1 ? :male : :female
    @lifespan = rand(MAX_LIFESPAN)
    @age = 0
    @metabolism = rand(MAX_METABOLISM*10.0)/10.0
    @vision_range = rand(MAX_VISION_RANGE*10.0)/10.0
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
    size = ROID_SIZE * @energy.to_f/50.0
    size = 10 if size > 10
    o = @slot.oval :left => @position[0], :top => @position[1], :radius => size, :center => true
    o.fill = @slot.lightblue if @sex == :male
    @slot.line @position[0], @position[1], @position[0] - @velocity[0], @position[1] - @velocity[1]    
  end

  def move
    @delta = Vector[0,0]    
    %w(separate align cohere muffle hungry).each do |action|
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

  # get attracted to food
  def hungry
    $food.each do |food|
      if distance_from_point(food.position) < (food.quantity + @vision_range)
        @delta -= self.position - food.position
      end  
      if distance_from_point(food.position) <= food.quantity + 15
        eat food
      end  
    end    
  end

  def reduce_energy_from_childbirth
    @energy = @energy * CHILDBEARING_ENERGY_SAP
  end

  # consume the food and replenish energy with it
  def eat(food)  
    food.eat 1
    @energy += @metabolism 
  end

  # lose energy at every tick
  def lose_energy
    @energy -= 1
  end
  
  def grow_older
    @age += 1
  end

  def inherit(crossover)
    @metabolism = crossover[0]
    @vision_range = crossover[1]
  end

  def procreate
    if attractive and @sex == :female
      # check for potential nearby mates
      r = $roids.sort {|a,b| self.distance_from(a) <=> self.distance_from(b)}
      roids = r.first(MAGIC_NUMBER)
      roids.each do |roid|
        if roid.attractive and roid.sex == :male
          baby = Roid.new(@slot, @position, @velocity, 1001)
          crossovers = [[@metabolism, @vision_range],
                        [@metabolism,roid.vision_range],
                        [roid.metabolism, @vision_range],
                        [roid.metabolism,roid.vision_range]]
          baby.inherit crossovers[rand(4)]
          $roids << baby
          reduce_energy_from_childbirth
          roid.reduce_energy_from_childbirth
        end
        
      end      
    end
  end

  def attractive
    CHILDBEARING_AGE.include? @age  and @energy > CHILDBEARING_ENERGY_LEVEL
  end

  # called at every tick of time
  def tick
    move
    lose_energy
    grow_older
    procreate
    if @energy <= 0 or @age > @lifespan
      $roids.delete self
    end    
  end

end