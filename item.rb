module Item

# アイテムとルーンの処理をまとめたmodule

def take_item(num)
  if @bag.size >= 8
    add_log("バッグがいっぱいだ")
    return 
  end
  Sound[:take_item].play
  @bag.push @dungeon[num]
  @dungeon.delete_at num
end

def click_rune(num)
  card = @dungeon[num]
  if monster_exist?
    add_log("この階にはまだモンスターがいる")
    return false
  end
  Sound[:rune].play
  add_log("隠されたルーンを唱えた")
  add_log(card.name+"が発動した "+card.text)
  chant_rune(card.id)
  @dungeon.delete_at num
end

def use_potion(id)
  case(id)
  when 0 # 回復薬
    @hp = @max_hp
    Sound[:potion].play
    add_log("回復薬を飲んだ。HPが全回復した。")
  when 1 # 体力増強薬
    Sound[:potion].play
    add_log("体力増強薬を飲んだ。最大HPが2上がった。")
    @hp_buff += 2
    calc_status
  end
end

def use_scroll(id)
  case(id)
  when 1 # 引き寄せ
    Sound[:rune].play
    d = @dungeon.select{|c|c.trap?}+@dungeon.select{|c|c.item?}+@dungeon.select{|c|!c.item? && !c.trap?}
    @dungeon = d
    add_log("この階のアイテムを引き寄せた")
  when 2 # 稲妻
    Sound[:fire].play
    add_log("稲妻の巻物を使った ")
    @dungeon.select{|c|c.monster?}.each do |monster|
      monster.hp -= 2
      if monster.hp <= 0
        add_log(monster.name+"を倒した")
      end
    end
    @dungeon.reject!{|c|c.monster? && c.hp <= 0}
  end
  
end

def chant_rune(id)
  case(id)
  when 0 # 体力増強
    @hp_buff += 5
    calc_status
  when 1 # 俊敏
    @escape_trap += 1
  when 2 # 筋力増強
    @atk_buff += 1
    calc_status    
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
  delete_item(num)
  cancel_target_select
end

end