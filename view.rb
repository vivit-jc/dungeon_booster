class View

  def initialize(game,controller)
    @game = game
    @controller = controller

    @view_status_buff = nil

    @dungeonback = Image.new(100,100)
    @dungeonback.box_fill(0,0,100,100,DARKGRAY)

    @infoback = Image.new(200,200)
    @infoback.box_fill(0,0,200,200,DARKGRAY)

    @itemback = Image.new(60,60)
    @itemback.box_fill(0,0,60,60,DARKGRAY)    

    @buttonback = Image.new(100,30)
    @buttonback.box_fill(0,0,100,30,DARKGRAY)

    @growth_gage = Image.new(100,10)
    @great_person_gage = Image.new(100,10)
    @research_gage = Image.new(150,10)
    @production_gage = Image.new(150,10)

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
    if Input.mouse_push?( M_LBUTTON )
      #refresh_gages
      #refresh_back
    end
    if @game.view_status == :gameover
      draw_gameover
    elsif @game.view_status == :log_view
      draw_log_view
    else
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
      Window.draw(x,10,@dungeonback)
      if card.kind != :monster and card.kind != :blank
        Window.draw_scale(x-53,-44,Image[card.kind],0.2,0.2) 
      end
      pos = @controller.pos_dungeon == i
      if card.kind == :rune
        Window.draw_font(x+3,13,"隠されたルーン",Font14)
      else
        Window.draw_font(x+3,13,card.name,Font14)  
      end
      if pos
        if card.kind == :rune
          Window.draw_font(20,130,"隠されたルーン",Font14)
          Window.draw_font(20,150,"唱えると、ルーンの魔法を発動する",Font14)
        else
          Window.draw_font(20,130,card.name,Font14)
          Window.draw_font(20,150,card.text,Font14)
        end
        pdc = @controller.pos_dungeon_command
        next if @game.monster_exist_front?(i)
        if card.monster?
          Window.draw_font(x+3,30,"戦う",Font16,mouseover_color(pdc == 0))
          Window.draw_font(x+3,50,"逃げる",Font16,mouseover_color(pdc == 1))
        elsif card.rune?
          Window.draw_font(x+3,30,"唱える",Font16,mouseover_color(pdc == 0))          
        elsif card.item?
          Window.draw_font(x+3,30,"拾う",Font16,mouseover_color(pdc == 0))
          if !card.equip? and !card.treasure?
            Window.draw_font(x+3,50,"使う",Font16,mouseover_color(pdc == 1))
          end
        end
      end
      
    end

  end

  def draw_bag
    bag = @game.bag
    bag.each_with_index do |card, i|
      card = bag[i]
      x = 260+70*(i%5)
      y = 260+(i/5).floor*70
      Window.draw(x,y,@itemback)
      pos = @controller.pos_bag == i
      if pos
        Window.draw_font(260,400,card.name,Font14)
        Window.draw_font(260,420,card.text,Font14)
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
        Window.draw_font(x+3,y+23,"捨てる",Font16,mouseover_color(pbc == 1))
      else
        Window.draw_scale(x-98,y-98,Image[card.kind],0.2,0.2) #マウスが乗っていない時にアイコンを表示
        Window.draw_font(x,y,"E",Font16) if bag[i] == @game.e_weapon or bag[i] == @game.e_shield
      end
    end
    Window.draw(540,330,@itemback)
    Window.draw_font(552,350,"整理",Font16,mouseover_color(@controller.pos_bag_sort))
  end

  def draw_button
    x = 500
    str = @game.withdraw ? "撤退中" : "前進中"
    Window.draw_font(520,130,str,Font20)

    Window.draw(500,160,@buttonback)
    if @game.deck.size == 0 and @game.withdraw
      Window.draw_font(510,165,"脱出する",Font20,mouseover_color(@controller.pos_button == 0))
    elsif @game.deck.size == 0
      Window.draw_font(510,165,"次の階へ",Font20,{color: BLACK})
    else
      Window.draw_font(510,165,"次の階へ",Font20,mouseover_color(@controller.pos_button == 0))
    end

    Window.draw(500,200,@buttonback)
    if @game.withdraw
      color = {color: BLACK}
    else
      color = mouseover_color(@controller.pos_button == 1)
    end
    Window.draw_font(510,205,"撤退する",Font20,color)
  end

  def draw_info
    Window.draw(20,260,@infoback)
    Window.draw_font(30,274,"HP #{@game.hp} / #{@game.max_hp}  逃げる 残り#{@game.rest_run}回",Font14)
    Window.draw_font(30,294,"残り #{@game.deck.size} 枚",Font14)
    Window.draw_font(30,314,"捨札 #{@game.stock.size} 枚",Font14)
    
  end

  def draw_log
    Window.draw_font(20,190,@game.log[@game.log.size-1],Font14) if @game.log.size >= 1
    Window.draw_font(20,210,@game.log[@game.log.size-2],Font14) if @game.log.size >= 2
    Window.draw_font(20,230,@game.log[@game.log.size-3],Font14) if @game.log.size >= 3
  end

  def draw_gameover
    [@game.log.size,10].min.times do |i|
      Window.draw_font(30,300-18*i,@game.log[i],Font14)
    end
    Window.draw_font(30,30,"GAME OVER",Font50)    
    Window.draw_font(30,400,"タイトルに戻る",Font20,mouseover_color(@controller.pos_back_to_title))
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