module Town

def enter_the_dungeon
  init_deck
  @explore_count += 1
  @place = :dungeon
  Sound[:stairs].play
end

def enter_shop
  @place = :shop
  Sound[:stairs].play
end

def enter_museum
  @place = :museum
  Sound[:stairs].play
end

def back_town
  @place = :town
  Sound[:stairs].play
end

def init_shop
  @shop_item = [Card.new(:weapon,1),Card.new(:shield,1),Card.new(:potion,0),Card.new(:scroll,0),Card.new(:scroll,0),Card.new(:scroll,0),Card.new(:scroll,0),Card.new(:scroll,0)]
end

def buy_item(num)
  card = @shop_item[num]
  if @bag.size  >= 8
    add_log("バッグがいっぱいだ")
    return
  end
  if @money < card.price
    add_log("お金が足りない ")
    return
  end
  @money -= card.price
  @bag << card.clone
  add_log("#{card.name}を買った")
end

def sell_item(num)
  card = @bag[num]
  @money += card.price/2
  add_log("#{card.name}を売った")
  @bag.delete_at num
end

def donate_treasure(num)
  return unless @bag[num].treasure?
  card = @bag[num]
  @score += card.price
  add_log("#{card.name}を寄贈した　score +#{card.price}")
  @donate_count += 1
  @bag.delete_at num
end

end