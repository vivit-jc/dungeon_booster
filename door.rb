module Door

def click_door(num)
  @view_status = :select_cardset
  @using_card = {card: @dungeon[num], target: nil, pos: num}
  @cardset = make_cardset
end

def open_door(num)
  add_log("扉を開けた")
  if @deck.size > 0
    @deck += @cardset[num]
  else #その層の最後の階で扉を開けた場合、復路にカードが追加される
    @stock += @cardset[num]    
  end
  deck_shuffle
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