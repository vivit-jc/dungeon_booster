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
    [:weapon, :shield, :monster, :potion, :scroll, :rune, :trap, :treasure, :door, :blank].each do |e|
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
    case @kind
    when :weapon,:shield
      return true
    else
      return false
    end
  end

end