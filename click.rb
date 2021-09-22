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
  elsif card.door?
    click_door(num)
  elsif card.stairs?
    p "click_stairs"
  end
end

def click_monster(num,com)
  card = @dungeon[num]
  if com == 0 #戦う
    d = card.hp
    d -= @atk
    d = 0 if d < 0
    damage(d,card.name)
    Sound[:fight].play
    add_log(card.name+"を倒した") if @hp > 0
    calc_monster(num,com)
    @dungeon.delete_at num
  elsif com == 1 #逃げる
    if rest_run <= 0
      add_log("これ以上逃げられない")
    else
      Sound[:runaway].play
      add_log(card.name+"から逃げた")
      add_log("ルーンを見失った") if @dungeon.find{|c|c.rune?}
      @run += 1
      @stock << card
      @dungeon.delete_at num
      @dungeon.reject!{|c|c.rune?}
    end
  end
end

def click_target_monster(num)
  return false unless @dungeon[num].monster?
  card = @using_card[:card]
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
    delete_item(@using_card[:pos])
    cancel_target_select
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

def click_door(num)
  @view_status = :select_cardset
  @using_card = {card: @dungeon[num], target: nil, pos: num}
  @cardset = make_cardset
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
  if card.equip? && com == 0 && (@e_weapon == num || @e_shield == num) 
    if card.weapon?
      @e_weapon = nil
    elsif card.shield?
      @e_shield = nil 
    end
    calc_status
    add_log(card.name+"を外した")
  elsif card.equip? and com == 0 #装備
    if card.weapon?
      @e_weapon = num
    elsif card.shield?
      @e_shield = num
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
        delete_item(num)
      end
      if card.scroll? and card.select_target
        @click_mode = :select_monster
        @using_card = {card: card, target: nil, pos: num}
        add_log("どれに対して使う？")
      elsif card.scroll?
        use_scroll(card.id)
        delete_item(num)
      end
    end
  end
end

def calc_trap
  @dungeon.select{|c|c.trap?}.each do |trap|
    if rand(4) <= @escape_trap
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
  when 2 #召喚スイッチ
    size = @dungeon.select{|c|!c.trap?}.size
    @deck += @dungeon.select{|c|!c.trap?}
    size.times do 
      @dungeon.pop
    end
    @deck = @deck.select{|c|c.monster?}+@deck.select{|c|!c.monster?}
    size.times do 
      @dungeon << @deck.shift
    end
    @deck.shuffle!
  when 3 #毒矢の罠
    damage(2,"毒矢の罠")
    @hp_buff -= 2
    calc_status
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
    @bag.select{|c|c.treasure?}.each{|e|@score += e.pt}
    return false
  end
  return false if @deck.size == 0
  @dungeon.each do |c|
    @stock << c if !c.trap? and !c.rune? and !c.blank? 
  end
  @dungeon = []
  refresh_status

  if first_floor
    @deck = @deck.reject{|c|c.trap?}.shuffle + @deck.select{|c|c.trap?}
    5.times do 
      @dungeon << @deck.shift
    end
    @deck.shuffle!
  else
    5.times do 
      if @deck.size == 0
        @dungeon << Stairs.new(:down_stairs,@layer)
        break
      end
      @dungeon << @deck.pop
    end
    #罠を先頭に持ってくる
    @dungeon = @dungeon.select{|c|c.trap?}+@dungeon.select{|c|!c.trap?}
    Sound[:stairs].play
    calc_trap
    if @deck.size == 0 && !@withdraw && !@completed 
      add_log("この層の最深部に到達した") 
      @completed = true
    end
  end
end

def start_withdrawal
  return false if @deck.size+5 >= @dungeon_max
  return false if @withdraw
  if monster_exist?
    add_log("この階にはまだモンスターがいる")
    return false
  end
  @withdraw = true
  Sound[:click].play
  (@dungeon_max-@deck.size-@stock.size-5).times do
    @stock << Card.new(:blank,0)
  end
  @dungeon = []
  @deck = @stock
  @stock = []
  @deck.shuffle!
  go_to_next_floor
end

def open_door(num)
  add_log("扉を開けた")
  @deck += @cardset[num]
  @deck.shuffle!
  @dungeon_max += @cardset[num].size
  @dungeon.delete_at @using_card[:pos]
  Sound[:door].play
  @cardset = []
  @using_card = nil
  @view_status = :main_view
end

def cancel_select_cardset
  add_log("この扉は開けないことにした")
  @dungeon.delete_at @using_card[:pos]
  @using_card = nil
  @view_status = :main_view
  @cardset = []
end

def make_cardset
  c = []
  minus = [:monster,:trap]
  plus = [:weapon,:shield,:potion,:scroll,:rune,:treasure]
  3.times do
    t = []
    if rand(2) == 0
      t << make_card_at_random(minus.sample,2)
      2.times do
        t << make_card_at_random(plus.sample,1)
      end  
    else
      t << make_card_at_random(plus.sample,2)
      2.times do
        t << make_card_at_random(minus.sample,1)
      end   
    end
    c << t
  end

  return c
end

end