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
    click_stairs(num)
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

  if card == :skill #ファイヤーボール
    Sound[:fire].play
    add_log("ファイヤーボールを唱えた "+monster.name+"に10ダメージを与えた")
    monster.hp -= 10
    if monster.hp <= 0
      add_log(monster.name+"を倒した")
      dungeon.delete_at num
    end
    @skill -= 1
    cancel_target_select
  elsif card.scroll? and card.select_target #対象を選ぶタイプの巻物の処理
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

def go_to_next_floor(first_floor=false)
  if monster_exist?
    add_log("この階にはまだモンスターがいる")
    return false
  end
  return false if @deck.size == 0
  @dungeon.each do |c|
    @stock << c if !c.trap? and !c.rune? and !c.blank? 
  end
  @dungeon = []
  refresh_status

  if first_floor
    @deck = @deck.reject{|c|c.trap? || c.stairs?}.shuffle + @deck.select{|c|c.trap? || c.stairs?}
    5.times do 
      @dungeon << @deck.shift
    end
    @deck = @deck.reject{|c|c.stairs?}.shuffle+@deck.select{|c|c.stairs?}
  else
    5.times do 
      @dungeon << @deck.shift
      break if @deck.size == 0
    end

    #罠を先頭に持ってくる
    @dungeon = @dungeon.select{|c|c.trap?}+@dungeon.select{|c|!c.trap?}
    Sound[:stairs].play
    calc_trap
  end
end

def start_withdrawal
  return false if @withdraw
  if monster_exist?
    add_log("この階にはまだモンスターがいる")
    return false
  end
  @withdraw = true
  Sound[:click].play
  (@dungeon_max-@deck.size-@stock.size-6).times do
    @stock << blank_or_monster
  end
  @stock << Stairs.new(:up_stairs,@layer)
  @dungeon = []
  @deck = @stock
  @stock = []
  deck_shuffle
  go_to_next_floor
end

def click_stairs(num)
  card = @dungeon[num]
  if monster_exist?
    add_log("この階にはまだモンスターがいる")
    return false
  end
  if card.down_stairs?
    @stock += @dungeon.reject{|c|c.trap? || c.rune? || c.stairs?} #罠、ルーン、階段以外をストックに
    temp = []
    (@dungeon_max-@stock.size-1).times do
      temp << blank_or_monster
    end
    temp << Stairs.new(:up_stairs,@layer)
    @deck_reserve[@layer] = @stock + temp
    @layer += 1
    init_deck
  elsif card.up_stairs?
    if @layer == 0
      @place = :town
      calc_reset_status
    else
      @layer -= 1
      @deck = @deck_reserve[@layer]
      @dungeon = []
      @stock = []
      @dungeon_max = @deck.size
      go_to_next_floor(true)
    end
  end
  Sound[:stairs].play

end

def use_skill
  return if @job == 0
  return if @skill == 0
  case @job
  when 1
    @click_mode = :select_monster
    @using_card = {card: :skill}
    add_log("どれに対して使う？")
  when 2
    add_log("手入れは行き届いている。")
  when 3
    @hp = @max_hp
    Sound[:rune].play
    add_log("キュアウーンズを唱えた HPが全回復した。")
    @skill -= 1
  end
end

def click_select_personality(sym,num)
  case sym
  when :personality
    @personality = num
  when :job
    @job = num
  when :decide
    @view_status = :main_view
    if @job != 0
      @skill = 3
      @skill_max = 3
    end
    @escape_trap += 2 if @personality == 1
  end
end

def calc_game_clear
  @game_clear = true
  @view_status = :game_clear
  @click_mode = nil
  Sound[:game_clear].play
  add_log("あなたは失われし王冠を寄贈した！")
  add_log("この偉業はいつまでも語り継がれることだろう・・・")
  @bag.select{|c|c.treasure?}.each{|e|@score += e.pt}
  return false
end

end