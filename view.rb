require_remote './viewmisc.rb'
require_remote './viewbag.rb'
require_remote './viewdungeon.rb'
require_remote './viewtown.rb'

class View

  include Viewmisc
  include Viewbag
  include Viewdungeon
  include Viewtown

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

    @cardsetback = Image.new(400,100)
    @cardsetback.box(0,0,400,100,WHITE)

    @helpback = Image.new(20,20)
    @helpback.box_fill(0,0,30,30,DARKGRAY)    

    @hp_gage = Image.new(180,16)
    @hp_gage.box_fill(0,0,180,16,GREEN)
    @hp_buffer = @game.hp
    @max_hp_buffer = @game.max_hp

    @skill_gage = Image.new(17,4)
    @skill_gage.box_fill(0,0,17,4,YELLOW)

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
    when :select_cardset
      draw_select_cardset
    when :select_personality
      draw_select_personality
    when :main_view
      draw_help_button
      case @game.place
      when :dungeon
        draw_dungeon_view
      when :town
        draw_town
      when :shop
        draw_shop
      when :museum
        draw_museum
      when :storage
        draw_storage
      end
    end
  end

  def draw_select_personality
    Window.draw_font(20,20,"あなたはどんな冒険者ですか？",Font20)
    CARDDATA[:personality].each_with_index do |e,i|
      if i == @game.personality
        color = YELLOW
      elsif i == @controller.pos_personality
        color = GREEN
      else
        color = WHITE
      end
      Window.draw_font(30,80+40*i,e.name,Font20,{color: color})
    end
    CARDDATA[:job].each_with_index do |e,i|
      if i == @game.job
        color = YELLOW
      elsif i == @controller.pos_job
        color = GREEN
      else
        color = WHITE
      end
      Window.draw_font(270,80+40*i,e.name,Font20,{color: color})
    end

    str = nil
    if @controller.pos_personality
      str = CARDDATA[:personality][@controller.pos_personality].text
    elsif @game.personality
      str = CARDDATA[:personality][@game.personality].text
    end
    Window.draw_font(20,320,str,Font16) if str

    str = nil
    if @controller.pos_job
      str = CARDDATA[:job][@controller.pos_job].text
    elsif @game.job
      str = CARDDATA[:job][@game.job].text
    end
    Window.draw_font(20,360,str,Font16) if str

    Window.draw_font(460,400,"決定",Font24,mouseover_color(@controller.pos_select_personality_decide)) if @game.personality && @game.job
  end

  def draw_dungeon_view
    @view_status_buff = :main_view
    draw_dungeon
    draw_bag
    draw_info
    draw_log
    draw_button
  end

  def draw_button
    x = 500
    str = @game.withdraw ? "撤退中" : "前進中"
    Window.draw_font(520,130,str,Font20)

    Window.draw(500,160,@buttonback)
    button_green = (@controller.pos_button == 0 && !@game.click_mode)
    Window.draw_font(510,165,"次の階へ",Font20,@game.deck.size == 0 ? {color: BLACK} : mouseover_color(button_green))

    Window.draw(500,200,@buttonback)
    if @game.withdraw
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
    Window.draw_font(30,270,"ダンジョン #{LAYER[@game.layer]}",Font14)
    Window.draw_font(30,290,@game.get_persona,Font14)
    Window.draw(30,316,@hp_gage)
    Window.draw_font(30,340,"HP #{@game.hp} / #{@game.max_hp}  ATK #{@game.atk}",Font14)
    Window.draw_font(30,360,"逃げる 残り#{@game.rest_run}回",Font14)
    Window.draw_font(30,380,"罠回避率 #{@game.escape_trap}0%",Font14)
    Window.draw_font(30,400,"この層のカード 残り #{@game.deck.size} 枚",Font14)
    Window.draw_font(30,420,"捨札 #{@game.stock.size} 枚",Font14)
  end

  def draw_select_cardset
    Window.draw_font(310,30,"どの扉を開ける？",Font16)
    Window.draw_scale(-40,125,Image[:door2],0.3,0.3)
    Window.draw_font(60,360,"やめる",Font20,mouseover_color(@controller.pos_cancel_select_cardset))
    3.times do |i|
      cards = @game.cardset[i]
      Window.draw(170,86+120*i,Image[:cardset_frame]) if @controller.pos_cardset == i
      4.times do |j|
        c = cards[j]
        if c == true || !c
          next
        end
        Window.draw_scale(195+100*j-57,50+120*i-57,Image[c.kind],0.2,0.2)
        Window.draw_font(255+100*j,150+120*i,"☆"+c.tier.to_s,Font14)
        Window.draw_font(220+100*j+get_padding(14,7,c.name.size),165+120*i,c.name,Font14) if @game.personality == 2 && c.monster?
        
      end
    end

    # 鍵付きの扉の場合
    if @game.cardset[2].last == true
      Window.draw(180,350,Image[:lock])
      if @game.can_unlock == 1 || @game.can_unlock == 3
        Window.draw_font(200,434,"解錠の巻物で開ける",Font16,mouseover_color(@controller.pos_select_unlock == 0))
      end
      if @game.can_unlock == 2 || @game.can_unlock == 3
        Window.draw_font(380,434,"鍵開け道具で開ける",Font16,mouseover_color(@controller.pos_select_unlock == 1))
      end
      Window.draw(170,320,Image[:cardset_frame]) if @controller.pos_select_unlock && @game.can_unlock > 0
    end
  end

end