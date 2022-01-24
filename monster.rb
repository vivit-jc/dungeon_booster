module Monster

#戦闘前に効果のあるモンスター
def calc_monster_before(num,com)
  card = @dungeon[num]
  case card.id
  when 5 #ピクシー
    while(1)
      r = rand(@bag.size)
      break unless(@bag[r].equip?)
    end
    temp_item = @bag[r]
    delete_item(r)
    @stock << temp_item
    add_log(temp_item.name+"をどこかへ持ち去られてしまった")
    return true
  when 7 #サラマンダー
    add_log("サラマンダーは炎を吐いた")
    damage(1,card.name)
  end
  return false
end

#戦闘後に効果のあるモンスター
def calc_monster_after(num,com)
  card = @dungeon[num]
  case card.id
  when 2 #酸のスライム
    return if !@e_weapon
    delete_item(@e_weapon)
  	@e_weapon = nil
  	calc_status
    add_log("装備していた武器が壊れた")
  when 4 #大蜘蛛
  	@run += 1
  	add_log("蜘蛛の糸に絡まった")
  end
end

end