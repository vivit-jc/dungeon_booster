module Door

def click_door(num)
  @view_status = :select_cardset
  @using_card = {card: @dungeon[num], target: nil, pos: num}
  @cardset = make_cardset
end

def open_door(num)
  if @cardset[num][3] #鍵付き扉の場合、音を鳴らしてreturn
    #Sound[:unlock].play #あとで探す
    return
  end
  add_log("扉を開けた")
  add_card_from_door(num)
end

def unlock_door(num)
  if num == 0 && (can_unlock == 1 || can_unlock == 3)
    add_log("解錠の巻物を使って扉を開けた")
    @bag.delete_at @bag.index{|c|c.scroll? && c.id == 4}
  end
  if num == 1 && (can_unlock == 2 || can_unlock == 3)
    add_log("鍵開け道具を使って扉を開けた")
    @skill -= 1
  end
  @cardset[2].pop #鍵付き扉の添字を消す
  add_card_from_door(2)
end

def can_unlock
  r = 0
  r += 1 if @bag.find{|c|c.scroll? && c.id == 4}
  r += 2 if @skill > 0 && @job.id == 2
  return r
end

def add_card_from_door(num)
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
  2.times do
    c << make_single_cardset(2)
  end
  c << make_single_cardset(2,true)
  return c
end

def make_single_cardset(tier,locked=false)
  minus = [:monster,:trap]
  plus = [:weapon,:shield,:potion,:scroll,:rune,:treasure]
  t = []
  if locked
    3.times do
      t << make_card_at_random(plus.sample,1)
    end
    t << true # 鍵付きであることの添字を追加する
  elsif rand(2) == 0
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
  return t
end

end