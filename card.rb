class Card

attr_accessor :hp
attr_reader :num, :kind, :name, :text, :att, :pt, :id, :select_target
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
  end

  def monster?
    return @kind == :monster
  end

  def potion?
    return @kind == :potion
  end

  def scroll?
    return @kind == :scroll
  end

  def rune?
    return @kind == :rune
  end

  def trap?
    return @kind == :trap
  end

  def treasure?
    return @kind == :treasure
  end

  def blank?
    return @kind == :blank
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