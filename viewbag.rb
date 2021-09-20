module Viewbag

  def draw_bag
    bag = @game.bag
    bag.each_with_index do |card, i|
      card = bag[i]
      x = 260+70*(i%5)
      y = 260+(i/5).floor*70
      pos = @controller.pos_bag == i
      if pos
        Window.draw(x,y,@game.click_mode == :select_bag ? @itemback2 : @itemback)
        Window.draw_font(260,400,card.name,Font14)
        Window.draw_font(260,420,card.text,Font14)
      else
        Window.draw(x,y,@itemback)
      end
      if pos && !@game.click_mode
        pbc = @controller.pos_bag_command
        if card.equip? and (@game.e_weapon == card or @game.e_shield == card)
          str = "外す" 
        elsif card.equip?
          str = "装備" 
        elsif card.treasure?
          str = "眺める"
        else
          str = "使う"
        end
        Window.draw_font(x+3,y+3,str,Font16,mouseover_color(pbc == 0))
      else
        Window.draw_scale(x-98,y-98,Image[card.kind],0.2,0.2) #マウスが乗っていない時にアイコンを表示
        Window.draw_font(x,y,"E",Font16) if bag[i] == @game.e_weapon or bag[i] == @game.e_shield
      end
    end
    
    # アイテム横のボタン
    3.times do |i|
      Window.draw(540,330+40*i,@itembuttonback)
    end
    Window.draw_font(545,337,"整理",Font16,mouseover_color((@controller.pos_bag_sort && !@game.click_mode)))
    Window.draw_font(545,377,"捨てる",Font16,mouseover_color(@controller.pos_dispose_item && !@game.click_mode))
    Window.draw_font(545,417,"ヘルプ",Font16,mouseover_color(@controller.pos_help && !@game.click_mode))
    
  end


end