module Item

def use_potion(id)
  case(id)
  when 0 # 回復薬
    @hp = @max_hp
    Sound[:potion].play
    add_log("回復薬を飲んだ。HPが全回復した。")
  end
end

def use_scroll(id)
  
end

def chant_rune(id)
  case(id)
  when 0 # 体力増強
    @hp_buff = 5
    calc_status
  when 1 # 俊敏
    @run_max += 1
  end
end

def dispose_item_select
  @click_mode = :select_bag
  @select_mode = :dispose
  add_log("どれを捨てる？")
end

def dispose_item(num)
  Sound[:take_item].play
  card = @bag[num]
  add_log(card.name+"を捨てた")
  @stock << card
  @bag.delete_at num
  cancel_target_select
end

end