module Trap

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
    #一旦、ダンジョンにある罠以外のものをデッキに戻す
    size = @dungeon.select{|c|!c.trap?}.size
    @deck += @dungeon.select{|c|!c.trap?}
    size.times do 
      @dungeon.pop
    end
    #その後、デッキからモンスターだけを引いてくる
    @deck = @deck.select{|c|c.monster?}+@deck.select{|c|!c.monster? && !c.stairs?}+@deck.select{|c|c.stairs?}
    size.times do 
      @dungeon << @deck.shift
    end
    deck_shuffle
  when 3 #毒矢の罠
    damage(2,"毒矢の罠")
    @hp_buff -= 2
    calc_status
  end
end

end