module Item

def use_potion(id)
  case(id)
  when 0 # 回復薬
    @hp = @max_hp
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

end