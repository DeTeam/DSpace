module GameEngine

  class Base 
    
    def initialize

      $s.background $s.fill 'images/logo.gif'
      
      @sboard = $s.para '0', :align => 'right', :fill => $s.white
      $s.para 'Scores: ', :align => 'right', :fill => $s.white
      @lboard = $s.para '3', :align => 'right', :fill => $s.white
      $s.para 'Lifes: ', :align => 'right', :fill => $s.white
      @levelboard = $s.para '1', :align => 'right', :fill => $s.white
      $s.para 'Level: ', :align => 'right', :fill => $s.white

      @bullets = []
      @npc = []
      @bonuses = []

      @char = Ship.new(200, 550, $s.image('images/char.gif'))

      @scores = 0
      @lifes = 3
      @level = 0
      @guns = 1
      @npc_speed = 1
      @char_speed = 4

      send_npc
      $s.every(10) { send_npc }
      $s.every(2) do
        if @lifes <= 0
          @gloop.stop
          alert 'Game Over'
          $s.exit
        end
      end

      $s.motion { |left, top| @mx = left }
      $s.click do |button, left, top|
        @guns.times do |i|
          x = @char.x + 40 * i + 10
          y = @char.y - 5
          @bullets << Bullet.new(x, y)
        end
      end


    end
    
    def start
      @gloop = $s.animate(20) do |i|

        if @mx > @char.x
          @char.move(@char_speed, 0)
        else
          @char.move(-@char_speed, 0)
        end

        @npc.each do |npc|
          npc.move
          npc.render
          if npc.y > 600
            @lifes -= 1
            @npc.delete(npc)
            npc.image.remove
          end
          @lboard.text = @lifes
        end
        @char.render

        @bonuses.each do |bonus|
          bonus.move
          bonus.render
          if bonus.x + bonus.image.full_width > @char.x && bonus.x < @char.x + @char.image.full_width && bonus.y > @char.y && bonus.y + bonus.image.full_height < @char.y + @char.image.full_height

            @bonuses.delete(bonus)
            bonus.image.remove

            @char_speed += 1 if bonus.type == :speed
            @guns += 1 if bonus.type == :gun

          end
          if bonus.y > 600
            @bonuses.delete(bonus)
            bonus.image.remove
          end
        end

        @bullets.each do |bullet|
          bullet.move
          bullet.render
          @npc.each do |npc|
            if bullet.x > npc.x && bullet.x < npc.x + npc.image.full_width && bullet.y > npc.y  && bullet.y < npc.y + npc.image.full_height
              bullet.image.remove
              @bullets.delete(bullet)
              @npc.delete(npc)
              npc.image.remove
              @scores += 1
              @sboard.text = @scores
            end
          end
          if bullet.life > 100 || bullet.y < 0
            bullet.image.remove
            @bullets.delete(bullet)
          end
        end
      end
    end

    def send_npc
      12.times do |i|
        @npc << NPC.new(i*50, 50, $s.image("images/npc#{@npc.size % 5}.gif"), @npc_speed)
      end
      @level += 1
      @levelboard.text = @level
      @npc_speed += 1 if @level % 3 == 0 && @level > 2
      @bonuses << Bonus.new(rand(500) + 50, 100, $s.image('images/speed.gif'), :speed) if @char_speed <= 13
      if @level % 5 == 0 && @level > 4 && @guns < 4
        @bonuses << Bonus.new(rand(500) + 50, 100 + rand(50), $s.image('images/bonus.gif'), :gun)
      end
    end
    
  end
  
  class GObject
    attr_accessor :x, :y, :image

    def initialize(x, y, pic)
      @x, @y, @image = x, y, pic
      render
    end
    
    def render
      @image.move(@x, @y)
    end
    
    def move(dx, dy)
      @x += dx
      @y += dy
    end
  end

  class Bullet < GObject
    attr_accessor :life
    def initialize x,y
      super(x, y, $s.image('images/bullet.gif'))
      @life = 0
    end

    def move
      super(0, -10)
      @life += 1
    end
  end

  class Ship < GObject
    def move(dx, dy)
      x = @x + dx
      y = @y + dy
      if x < 550 && x > 0 && y > 0 && y < 600
        super(dx, dy)
      end
    end
  end
  
  class NPC < GObject
    attr_accessor :speed

    def initialize x, y, pic, speed
      super(x, y, pic)
      @speed = speed
    end

    def move
      super(0, @speed)
    end
  end

  class Bonus < GObject
    attr_accessor :type

    def initialize x, y, pic, type
      super(x, y, pic)
      @type = type
    end

    def move
      super(0, 1)
    end
  end

end
