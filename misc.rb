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
  Card.new(kind,CARDDATA[kind].select{|c|c.tier == tier}.sample.id)
end

def deck_shuffle
  @deck = @deck.reject{|c|c.stairs?}.shuffle+@deck.select{|c|c.stairs?}
end

end