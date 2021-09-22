class Card

attr_accessor :hp
attr_reader :num, :kind, :name, :text, :pt, :id, :select_target, :tier
  def initialize(kind, num)
    card = CARDDATA[kind][num]
  	@kind = kind
  	@num = num
    @id = card.id
  	@name = card.name
    @text = card.text
    @pt = card.pt.to_i
    @hp = @pt if monster?
    @select_target = true if card.select_target
    @tier = card.tier
  end

  def self.define_kind
    [:weapon, :shield, :monster, :potion, :scroll, :rune, :trap, :treasure, :door, :blank, :up_stairs, :down_stairs].each do |e|
      define_method(e.to_s+"?") do
        @kind == e
      end
    end
  end

  def item?
    case @kind
    when :scroll,:weapon,:shield,:potion,:treasure
      return true
    else
      return false
    end
  end

  def equip?
    @kind == :weapon || @kind == :shield
  end

  def stairs?
    @kind == :up_stairs || @kind == :down_stairs
  end

end

class Stairs < Card
  def initialize(kind,num)
    super(kind,0)
    if kind == :down_stairs
      @text = LAYER[num+1]+@text
      @name = LAYER[num+1]+@name
    elsif kind == :up_stairs
      @text = LAYER[num-1]+@text
      @name = LAYER[num-1]+@name  
    end
  end
end