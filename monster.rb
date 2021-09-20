module Monster

#戦闘後に効果のあるモンスター
def calc_monster(num,com)
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