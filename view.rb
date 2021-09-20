require_remote './viewmisc.rb'
require_remote './viewbag.rb'
require_remote './viewdungeon.rb'

class View

  include Viewmisc
  include Viewbag
  include Viewdungeon

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
    when :select_cardset
      draw_select_cardset
    when :main_view
      @view_status_buff = :main_view
      draw_dungeon
      draw_bag
      draw_info
      draw_log
      draw_button
    end
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
    if @game.withdraw || @game.deck.size+5 >= @game.dungeon_max
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

    Window.draw_font(30,300,"HP #{@game.hp} / #{@game.max_hp}  ATK #{@game.atk}",Font14)
    Window.draw_font(30,320,"逃げる 残り#{@game.rest_run}回",Font14)
    Window.draw_font(30,340,"残り #{@game.deck.size} 枚",Font14)
    Window.draw_font(30,360,"捨札 #{@game.stock.size} 枚",Font14)
    
  end

  def draw_select_cardset
    Window.draw_font(310,30,"どの扉を開ける？",Font16)
    Window.draw_scale(-40,125,Image[:door2],0.3,0.3)
    Window.draw_font(60,360,"やめる",Font20,mouseover_color(@controller.pos_cancel_select_cardset))
    @game.cardset.each_with_index do |cards,i|
      Window.draw(170,80+120*i,Image[:cardset_frame]) if @controller.pos_cardset == i
      cards.each_with_index do |c,j|
        Window.draw_scale(195+100*j-57,50+120*i-57,Image[c.kind],0.2,0.2)
        Window.draw_font(255+100*j,150+120*i,"☆"+c.tier.to_s,Font14)
      end
    end
  end

end