class Card

attr_reader :num, :kind, :name, :text, :att, :pt, :id
  def initialize(kind, num)
    card = CARDDATA[kind][num]
  	@kind = kind
  	@num = num
    @id = card.id
  	@name = card.name
    @text = card.text
    @att = card.att if kind == :monster
    @pt = card.pt
  end

  def monster?
    return @kind == :monster
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