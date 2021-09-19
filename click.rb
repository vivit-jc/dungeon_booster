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
    d = card.hp
    d -= @e_weapon.pt if @e_weapon
    d = 0 if d < 0
    damage(d,card.name)
    Sound[:fight].play
    add_log(card.name+"を倒した") if @hp > 0
    @dungeon.delete_at num
  elsif com == 1 #逃げる
    if rest_run <= 0
      add_log("これ以上逃げられない")
    else
      Sound[:runaway].play
      add_log(card.name+"から逃げた")
      @run += 1
      @stock << card
      @dungeon.delete_at num
      @dungeon.reject!{|c|c.rune?}
    end
  end
end

def click_target_monster(num)
  return false unless @dungeon[num].monster?
  card = @using_item[:card]
  monster = @dungeon[num]
  #対象を選ぶタイプの巻物の処理
  if card.scroll? and card.select_target
    case(card.id)
    when 0 #火炎
      Sound[:fire].play
      add_log("火炎の巻物を使った "+monster.name+"に5ダメージを与えた")
      monster.hp -= 5
      if monster.hp <= 0
        add_log(monster.name+"を倒した")
        dungeon.delete_at num
      end
    end
    @bag.delete_at @using_item[:pos]
    @click_mode = nil
    @using_item = nil
  end

end

def click_rune(num)
  card = @dungeon[num]
  if monster_exist?
    add_log("この階にはまだモンスターがいる")
    return false
  end
  Sound[:rune].play
  add_log("隠されたルーンを唱えた")
  add_log(card.name+"が発動した "+card.text)
  chant_rune(card.id)
  @dungeon.delete_at num
end

def take_item(num)
  if @bag.size >= 8
    add_log("バッグがいっぱいだ")
    return 
  end
  Sound[:take_item].play
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
    Sound[:equip].play
    add_log(card.name+"を装備した")
  elsif com == 0 #使う
    if card.treasure?
      mes = ["これはなかなかの値打ち物だ。",card.name+"は上品に輝いている。","魔術的な仕掛けは特に無さそうだ。","ダンジョンのお宝は冒険者の物。"]
      add_log(card.name+"を眺めた。"+mes[rand(4)])
    else
      if card.potion?
        use_potion(card.id)
        @bag.delete_at num
      end
      if card.scroll? and card.select_target
        @click_mode = :select_monster
        @using_item = {card: card, target: nil, pos: num}
        add_log("どれに対して使う？")
      end
    end
  elsif com == 1 #捨てる
    add_log(card.name+"を捨てた")
    @stock << card
    @bag.delete_at num  
  end
  
end

def calc_status
  @att = @att_buff
  @att += @e_weapon.pt if @e_weapon
  @max_hp = @base_hp + @hp_buff
  @max_hp += @e_shield.pt if @e_shield
  @hp = @max_hp if @max_hp <= @hp
end

def calc_trap
  @dungeon.select{|c|c.trap?}.each do |trap|
    if rand(4) == 0
      add_log(trap.name+"をうまく避けた")
      next
    else
      Sound[:trap].play
      add_log(trap.name+"を踏んだ")
      calc_trap_d(trap.id)
    end
  end
end

def calc_trap_d(id)
  case(id)
  when 0 #トラバサミ
    @run_max_floor = 0
  when 1 #矢の罠
    damage(2,"矢の罠")
  end

end

def go_to_next_floor(first_floor=false)
  if monster_exist?
    add_log("この階にはまだモンスターがいる")
    return false
  end
  if @deck.size == 0 and @withdraw
    @game_clear = true
    @view_status = :game_clear
    Sound[:game_clear].play
    if @completed
     add_log("あなたはダンジョンを踏破し、無事生還した！")
    else
     add_log("あなたはダンジョンから無事脱出した！")
    end
    return false
  end
  return false if @deck.size == 0
  @dungeon.each do |c|
    @stock << c if !c.trap? and !c.rune? and !c.blank? 
  end
  @dungeon = []
  refresh_status

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
    Sound[:stairs].play
    calc_trap
    if @deck.size == 0 and !@withdraw
      add_log("この層の最深部に到達した") 
      @completed = true
    end
  end
end

def start_withdrawal
  return false if @deck.size+5 >= @dungeon_max
  if monster_exist?
    add_log("この階にはまだモンスターがいる")
    return false
  end
  @withdraw = true
  @dungeon = []
  @deck = @stock
  @stock = []
  Sound[:click].play
  (@dungeon_max-@deck.size-5).times do
    @deck << Card.new(:blank,0)
  end
  @deck.shuffle!
  go_to_next_floor

end

def refresh_status
  @run_max_floor = nil
  @run = 0
end

def sort_bag
  Sound[:sort].play
  @bag.sort!{|a, b| b.kind <=> a.kind } 
  @bag = @bag.select{|c|!c.treasure?}+@bag.select{|c|c.treasure?}
end

def cancel_target_select
  @using_item = nil
  @click_mode = nil
end

def call_help
  Sound[:click].play
  case(@help_page)
  when nil
    @view_status = :help
    @help_page = 0
  when 0
    @help_page = 1
  when 1
    @help_page = nil
    @view_status = :main_view
  end
end

end