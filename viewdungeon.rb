module Viewdungeon

  def draw_dungeon
    @game.dungeon.each_with_index do |card, i|
      x = 20+120*i
      pos = @controller.pos_dungeon == i
      if @game.click_mode == :select_monster and pos
        Window.draw(x,10,@dungeonback2)
      else
        Window.draw(x,10,@dungeonback)
      end
      unless card.blank?
        Window.draw_scale(x-53,-44,Image[card.kind],0.2,0.2)
      end
      if card.rune?
        Window.draw_font(x+3,13,"隠されたルーン",Font14)
      else
        Window.draw_font(x+3,13,card.name,Font14)  
      end
      str = "☆"+card.tier.to_s
      str += " ATK "+card.hp.to_s if card.monster?
      Window.draw_font(x+3,30,str,Font14) unless card.blank?
      if pos
        if @game.click_mode == :select_monster
          #対象選択時はコマンドは表示しない
        else
          draw_dungeon_command_and_note(i)
        end
      end
    end
  end

  def draw_dungeon_command_and_note(num)
    card = @game.dungeon[num]
    x = 20+120*num

    #マウスオーバー時に説明を表示
    if card.rune?
      Window.draw_font(20,130,"隠されたルーン",Font14)
      Window.draw_font(20,150,"唱えると、ルーンの魔法を発動する",Font14)
    elsif card.monster?
      Window.draw_font(20,130,card.name,Font14)
      Window.draw_font(20,150,"ATK "+card.hp.to_s+"   "+card.text,Font14)      
    else
      Window.draw_font(20,130,card.name,Font14)
      Window.draw_font(20,150,card.text,Font14)
    end

    return if @game.monster_exist_front?(num)
    return if @game.click_mode

    if card.monster?
      com = ["戦う","逃げる"]
    elsif card.rune?
      com = ["唱える"]         
    elsif card.item?
      com = ["拾う"]  
    elsif card.door?
      com = ["開ける"]
    elsif card.down_stairs?
      com = ["下りる"]
    elsif card.up_stairs?
      com = ["上る"]
    else
      com = []
    end
    com.each_with_index do |c,i|
      Window.draw_font(x+3,55+25*i,c,Font16,mouseover_color(@controller.pos_dungeon_command == i))
    end

  end

end