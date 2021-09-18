module Click

# クリックで発生する処理をまとめるmodule

def click_dungeon(num,com)
  return false if monster_exist_front?(num)
  card = @dungeon[num]
  if card.item? and com == 0
    take_item(num)
  elsif card.monster?
    click_monster(num, com)
  elsif card.rune?
    click_rune(num)
  end
end

def click_monster(num,com)
  card = @dungeon[num]
  if com == 0 #戦う
    @hp -= card.att.to_i
    add_log(card.name+"を倒した")
    @dungeon.delete_at num
  elsif com == 1 #逃げる
    if @run >= @run_max
      add_log("これ以上逃げられない")
    else
      add_log(card.name+"から逃げた")
      @run += 1
      @stock << card
      @dungeon.delete_at num
      @dungeon.reject!{|c|c.rune?}
    end
  end
end

def click_rune(num)
  if monster_exist?
    add_log("この階にはまだモンスターがいる")
    return false
  end
  add_log("隠されたルーンを唱えた")
  add_log(@dungeon[num].name+"が発動した "+@dungeon[num].text)
  @dungeon.delete_at num
end

def take_item(num)
  if @bag.size >= 8
    add_log("バッグがいっぱいだ")
    return 
  end
  @bag.push @dungeon[num]
  @dungeon.delete_at num
end

def click_bag(num,com)
  card = @bag[num]

  #装備をはずす
  if card.equip? and com == 0 and (@e_weapon == card or @e_shield == card) 
    if card.kind == :weapon
      @e_weapon = nil
    elsif card.kind == :shield
      @e_shield = nil 
    end
    calc_status
    add_log(card.name+"を外した")
  elsif card.equip? and com == 0 #装備
    if card.kind == :weapon
      @e_weapon = card 
    elsif card.kind == :shield
      @e_shield = card 
    end
    calc_status
    add_log(card.name+"を装備した")
  elsif com == 0 #使う
    if card.treasure?
      add_log(card.name+"を眺めた")
    else
      add_log(card.name+"を使った")
      @bag.delete_at num
    end
  elsif com == 1 #捨てる
    add_log(card.name+"を捨てた")
    @stock << card
    @bag.delete_at num  
  end
  
end

def calc_status
  @att = @e_weapon.pt.to_i+@att_buff if @e_weapon
  @max_hp = @base_hp+@e_shield.pt.to_i+@hp_buff if @e_shield
end

def go_to_next_floor(first_floor=false)
  return false if @deck.size == 0
  if monster_exist?
    add_log("この階にはまだモンスターがいる")
    return false
  end
  @dungeon.each do |c|
    @stock << c if !c.trap? and !c.rune? and !c.blank? 
  end
  @run = 0
  @dungeon = []

  if first_floor
    no_trap = @deck.select{|c|!c.trap?}
    traps = @deck.select{|c|c.trap?}
    5.times do
      @dungeon.push no_trap.pop
    end
    @deck = (no_trap+traps).shuffle
  else
    5.times do 
      @dungeon.push @deck.pop
      break if @deck.size == 0
    end
    #罠を先頭に持ってくる
    @dungeon = @dungeon.select{|c|c.trap?}+@dungeon.select{|c|!c.trap?}
    add_log("この層の最深部に到達した") if @deck.size == 0 and !@withdraw
  end
end

def start_withdrawal
  if monster_exist?
    add_log("この階にはまだモンスターがいる")
    return false
  end
  @withdraw = true
  @dungeon = []
  @deck = @stock
  @stock = []
  (@dungeon_max-@deck.size-5).times do
    @deck << Card.new(:blank,0)
  end
  @deck.shuffle!
  go_to_next_floor

end

def sort_bag
  @bag.sort!{|a, b| b.kind <=> a.kind } 
  @bag = @bag.select{|c|!c.treasure?}+@bag.select{|c|c.treasure?}
end

end