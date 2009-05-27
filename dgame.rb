Shoes.app(:title => 'DSpace', :width => 600, :height => 600, :resizable => false) do
  $s = self
  require 'game_engine'
  engine = GameEngine::Base.new
  engine.start
end