module Door

def click_door(num)
  @view_status = :select_cardset
  @using_card = {card: @dungeon[num], target: nil, pos: num}
  @cardset = make_cardset
end

def open_door(num)
  if @cardset[num].last == true #鍵付き扉の場合、音を鳴らしてreturn
    #Sound[:unlock].play #あとで探す
    return
  end
  add_log("扉を開けた")
  add_card_from_door(num)
end

def unlock_door(num)
  return if can_unlock == 0
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
  r += 2 if @skill > 0 && @job == 2
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
    c << make_single_cardset
  end
  c << ((@layer > 0) ? make_locked_cardset : make_single_cardset)
  return c
end

def make_single_cardset
  kind = [[:monster,:trap],[:weapon,:shield,:potion,:scroll,:rune,:treasure]]
  t = []
  r = rand(2)
  case @layer
  when 0
    [[r,2],[1-r,1],[1-r,1]].each do |e|
      t << make_card_at_random(kind[e[0]].sample,e[1])
    end  
  when 1
    [[[r,2],[1-r,1],[1-r,1]],[[r,3],[1-r,2],[1-r,1]]].sample.each do |e|
      t << make_card_at_random(kind[e[0]].sample,e[1])
    end
  when 2
    (DOOR_CARDSET1+DOOR_CARDSET2).sample.each do |e|
      t << make_card_at_random(kind[(e[0]-r).abs].sample,e[1])
    end  
  when 3
    (DOOR_CARDSET2+DOOR_CARDSET3).sample.each do |e|
      t << make_card_at_random(kind[(e[0]-r).abs].sample,e[1])
    end
  end
  return t
end

def make_locked_cardset
  kind = [[:monster,:trap],[:weapon,:shield,:potion,:scroll,:rune,:treasure]]
  t = []
  case @layer
  when 1
    [[[0,1],[1,1],[1,2]],
    [[0,2],[1,2],[1,2]],
    [[0,2],[1,1],[1,3]]].sample.each do |e|
      t << make_card_at_random(kind[e[0]].sample,e[1])
    end  
  when 2
    [[[0,3],[1,1],[1,4]],
    [[0,3],[1,2],[1,3]],
    [[0,1],[0,2],[1,1],[1,4]],
    [[0,1],[0,2],[1,2],[1,3]]].sample.each do |e|
      t << make_card_at_random(kind[e[0]].sample,e[1])
    end
  when 3
    [[[0,4],[1,2],[1,4]],
    [[0,4],[1,3],[1,3]],
    [[0,1],[0,3],[1,2],[1,4]],
    [[0,1],[0,3],[1,3],[1,3]],
    [[0,2],[0,2],[1,2],[1,4]],
    [[0,2],[0,2],[1,3],[1,3]]].sample.each do |e|
      t << make_card_at_random(kind[e[0]].sample,e[1])
    end
  end
  t << true
  return t

end

end