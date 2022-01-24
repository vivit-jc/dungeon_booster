module Misc

def cancel_target_select
  @using_card = nil
  @click_mode = nil
  @select_mode = nil
end

def refresh_status
  @run_max_floor = nil
  @run = 0
end

def calc_status
  @atk = @atk_buff
  @atk += @bag[@e_weapon].pt if @e_weapon
  @atk = 0 if @atk < 0
  @max_hp = @base_hp + @hp_buff
  @max_hp += @bag[@e_shield].pt if @e_shield
  @hp = @max_hp if @max_hp <= @hp
end

def sort_bag
  Sound[:sort].play
  ew = @e_weapon ? @bag[@e_weapon].id : nil
  es = @e_shield ? @bag[@e_shield].id : nil
  @bag.sort!{|a, b| b.kind <=> a.kind } 
  @bag = @bag.select{|c|!c.treasure?}+@bag.select{|c|c.treasure?}
  @e_weapon = @bag.size.times.select{|i|@bag[i].weapon? && @bag[i].id == ew}[0] if ew
  @e_shield = @bag.size.times.select{|i|@bag[i].shield? && @bag[i].id == es}[0] if es
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

def delete_item(num)
  @e_weapon -= 1 if @e_weapon && num < @e_weapon
  @e_shield -= 1 if @e_shield && num < @e_shield
  @bag.delete_at num
end

def make_card_at_random(kind,tier)
  if kind == :trap && tier == 4
    kind = :monster
  elsif (kind == :weapon || kind == :shield || kind == :potion || kind == :scroll) && tier == 4
    kind = [:rune, :treasure].sample
  end
  Card.new(kind,CARDDATA[kind].select{|c|c.tier == tier}.sample.id)
end

def deck_shuffle
  @deck = @deck.reject{|c|c.stairs?}.shuffle+@deck.select{|c|c.stairs?}
end

def add_log(str)
  return if @gameover
  @log.push str
end

def damage(num,src)
  @hp -= num
  check_death(src)
end

def check_death(src)
  return false if @hp > 0
  Sound[:gameover].play
  add_log(src+"により致命傷を負った")
  add_log("あなたは息絶えた・・・")
  @gameover = true
  @view_status = :gameover
end

def calc_reset_status
  @max_hp = 10
  @hp = 10
  @max_hp = 10
  @base_hp = 10
  @e_weapon = nil
  @e_shield = nil
  @atk = 0
  @atk_buff = 0
  @hp_buff = 0
  @run = 0
  @run_max = 2
  @escape_trap = 2
  @withdraw = false
  @log = []
end

def monster_exist_front?(num)
  num.times do |i|
    return true if @dungeon[i].kind == :monster
  end
  return false
end

def monster_exist?
  @dungeon.find{|c|c.kind == :monster}
end

def rest_run
  if @run_max_floor
    return @run_max_floor #今の所トラバサミのみが関係する
  elsif @run_max <= @run
    return 0
  else
    return @run_max - @run
  end
end

def get_persona
  return CARDDATA[:personality][@personality].name+CARDDATA[:job][@job].name
end

def blank_or_monster
  p = 5
  p += 3 if @personality == 0
  if rand(p) == 0
    return add_stock_monster
  else
    return Card.new(:blank,0)
  end
end

def add_stock_monster
  case @layer
  when 0
    return make_card_at_random(:monster,1+(rand(4)==0 ? 1 : 0))
  when 1
    return make_card_at_random(:monster,2+(rand(4)==0 ? 1 : 0))
  when 2
    return make_card_at_random(:monster,3-(rand(4)==0 ? 1 : 0))
  when 3
    return make_card_at_random(:monster,3)
  end
end

def in_dungeon?
  return @place == :dungeon
end

end