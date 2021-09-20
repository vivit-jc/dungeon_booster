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
  @att = @att_buff
  @att += @e_weapon.pt if @e_weapon
  @max_hp = @base_hp + @hp_buff
  @max_hp += @e_shield.pt if @e_shield
  @hp = @max_hp if @max_hp <= @hp
end

def sort_bag
  Sound[:sort].play
  @bag.sort!{|a, b| b.kind <=> a.kind } 
  @bag = @bag.select{|c|!c.treasure?}+@bag.select{|c|c.treasure?}
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