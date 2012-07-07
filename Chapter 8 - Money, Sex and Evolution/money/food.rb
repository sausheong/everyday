class Food
  attr_reader :quantity, :position 

  def initialize(slot, p)
    @position = p 
    @slot = slot
    @quantity = rand(20) + 10
  end
  
  def eat(much)
    @quantity -= much
  end
  
  def draw
    @slot.oval :left => @position[0], :top => @position[1], :radius => quantity, :center => true
  end  
  
  def tick
    if @quantity <= 0
      $food.delete self
    end
    draw
  end
end