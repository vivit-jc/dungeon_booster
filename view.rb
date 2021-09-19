class View

  def initialize(game,controller)
    @game = game
    @controller = controller

    @view_status_buff = nil

    @dungeonback = Image.new(100,100)
    @dungeonback.box_fill(0,0,100,100,DARKGRAY)

    @dungeonback2 = Image.new(100,100)
    @dungeonback2.box_fill(0,0,100,100,DARKGRAY2)

    @infoback = Image.new(200,200)
    @infoback.box_fill(0,0,200,200,DARKGRAY)

    @itemback = Image.new(60,60)
    @itemback.box_fill(0,0,60,60,DARKGRAY)

    @itemback2 = Image.new(60,60)
    @itemback2.box_fill(0,0,60,60,DARKGRAY2)

    @itembuttonback = Image.new(60,30)
    @itembuttonback.box_fill(0,0,60,30,DARKGRAY)

    @buttonback = Image.new(100,30)
    @buttonback.box_fill(0,0,100,30,DARKGRAY)

    @hp_gage = Image.new(180,16)
    @hp_gage.box_fill(0,0,180,16,GREEN)
    @hp_buffer = @game.hp
    @max_hp_buffer = @game.max_hp

  end

  def draw
    case @game.status
    when :title
      draw_title
    when :game
      draw_game
    when :stats
      draw_stats
    end
    draw_xy
    draw_debug
  end

  def draw_title
    Window.draw(0,0,Image[:title])
    Window.draw_font(30, 20, "DUNGEON BOOSTER", Font50, {color: YELLOW})
    TITLE_MENU_TEXT.each_with_index do |menu,i|
      Window.draw_font(TITLE_MENU_X,TITLE_MENU_Y[i],menu,Font32,mouseover_color(@controller.pos_title_menu == i, YELLOW)) 
    end
  end

  def draw_game
    case(@game.view_status)
    when :gameover
      draw_gameover
    when :game_clear
      draw_game_clear
    when :log_view
      draw_log_view
    when :help
      draw_help
    when :main_view
      @view_status_buff = :main_view
      draw_dungeon
      draw_bag
      draw_info
      draw_log
      draw_button
    end
  end

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
    if card.kind == :rune
      Window.draw_font(20,130,"隠されたルーン",Font14)
      Window.draw_font(20,150,"唱えると、ルーンの魔法を発動する",Font14)
    else
      Window.draw_font(20,130,card.name,Font14)
      Window.draw_font(20,150,card.text,Font14)
    end

    return if @game.monster_exist_front?(num)
    return if @game.click_mode
    pdc = @controller.pos_dungeon_command
    if card.monster?
      Window.draw_font(x+3,55,"戦う",Font16,mouseover_color(pdc == 0))
      Window.draw_font(x+3,80,"逃げる",Font16,mouseover_color(pdc == 1))
    elsif card.rune?
      Window.draw_font(x+3,55,"唱える",Font16,mouseover_color(pdc == 0))          
    elsif card.item?
      Window.draw_font(x+3,55,"拾う",Font16,mouseover_color(pdc == 0))
    end
  end

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

  def draw_button
    x = 500
    str = @game.withdraw ? "撤退中" : "前進中"
    Window.draw_font(520,130,str,Font20)

    Window.draw(500,160,@buttonback)
    button_green = (@controller.pos_button == 0 && !@game.click_mode)
    if @game.deck.size == 0 and @game.withdraw
      Window.draw_font(510,165,"帰還する",Font20,mouseover_color(button_green))
    elsif @game.deck.size == 0
      Window.draw_font(510,165,"次の階へ",Font20,{color: BLACK})
    else
      Window.draw_font(510,165,"次の階へ",Font20,mouseover_color(button_green))
    end

    Window.draw(500,200,@buttonback)
    if @game.withdraw or @game.deck.size+5 >= @game.dungeon_max
      color = {color: BLACK}
    else
      color = mouseover_color(@controller.pos_button == 1 && !@game.click_mode)
    end
    Window.draw_font(510,205,"撤退開始",Font20,color)
  end

  def draw_info

    #HPゲージの再描画
    if @hp_buffer != @game.hp or @max_hp_buffer != @game.max_hp
      @hp_buffer = @game.hp
      @hp_gage.box_fill(0,0,180,16,BLACK)
      ratio = @game.hp/@game.max_hp
      @hp_gage.box_fill(0,0,@game.hp/@game.max_hp*180,16,GREEN) if ratio > 0.3
      @hp_gage.box_fill(0,0,@game.hp/@game.max_hp*180,16,RED) if ratio <= 0.3
    end

    Window.draw(20,260,@infoback)
    Window.draw(30,274,@hp_gage)

    atk = @game.e_weapon ? @game.e_weapon.pt : 0
    Window.draw_font(30,300,"HP #{@game.hp} / #{@game.max_hp}  ATK #{atk}",Font14)
    Window.draw_font(30,320,"逃げる 残り#{@game.rest_run}回",Font14)
    Window.draw_font(30,340,"残り #{@game.deck.size} 枚",Font14)
    Window.draw_font(30,360,"捨札 #{@game.stock.size} 枚",Font14)
    
  end

  def draw_log
    Window.draw_font(20,190,@game.log[@game.log.size-1],Font14) if @game.log.size >= 1
    Window.draw_font(20,210,@game.log[@game.log.size-2],Font14) if @game.log.size >= 2
    Window.draw_font(20,230,@game.log[@game.log.size-3],Font14) if @game.log.size >= 3
  end

  def draw_game_clear
    [@game.log.size,10].min.times do |i|
      Window.draw_font(30,130+18*i,@game.log[@game.log.size-1-i],Font14)
    end
    Window.draw_font(30,30,"GAME CLEAR",Font50)    
    Window.draw_font(30,400,"タイトルに戻る",Font20,mouseover_color(@controller.pos_back_to_title))
  end

  def draw_gameover
    [@game.log.size,10].min.times do |i|
      Window.draw_font(30,130+18*i,@game.log[@game.log.size-1-i],Font14)
    end
    Window.draw_font(30,30,"GAME OVER",Font50)    
    Window.draw_font(30,400,"タイトルに戻る",Font20,mouseover_color(@controller.pos_back_to_title))
  end

  def draw_help
    Window.draw(0,0,Image[:help1]) if @game.help_page == 0
    Window.draw(0,0,Image[:help2]) if @game.help_page == 1
  end

  def draw_xy
    Window.draw_font(0,460,Input.mouse_pos_x.to_s+" "+Input.mouse_pos_y.to_s,Font16)
  end

  def draw_debug
  
  end

  def mouseover_color(bool, color=WHITE)
    return {color: GREEN} if bool
    return {color: color}
  end

end