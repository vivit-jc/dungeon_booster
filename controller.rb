require 'native' 
#alias_method :new_name, :old_name

class Controller
  attr_reader :x,:y,:mx,:my

  def initialize(game)
    @game = game
  end

  def input
    @mx = Input.mouse_x
    @my = Input.mouse_y
    if Input.mouse_push?( M_LBUTTON )
      case @game.status
      when :title
        @game.start if(pos_title_menu == 0)
        #@game.load if(pos_title_menu == 1)
        #@game.option if(pos_title_menu == 2)
      when :game
        click_on_game
      when :stats
        @game.go_title if(pos_return)
      when :end
        @game.next if(pos_return)
      end
    end
    if(Input.key_push?(K_SPACE))
      case @game.status
      when :game
        @game.push_space
      end
    end
  end

  def click_on_game

    #各項でreturnするのを忘れないこと！（１クリックで処理が２回行われてしまうため）
    case @game.click_mode
    when :select_monster
      if pos_dungeon and @game.dungeon[pos_dungeon].monster?
        @game.click_target_monster(pos_dungeon) 
      else
        @game.add_log(@game.using_card[:card].name+"を使うのをやめた")
        @game.cancel_target_select
      end
      return
    when :select_bag
      if pos_bag and @game.select_mode == :dispose
        @game.dispose_item(pos_bag)
      else
        @game.add_log("アイテムを捨てるのをやめた")
        @game.cancel_target_select
      end
      return
    end

    if @game.view_status == :main_view
      @game.click_dungeon(pos_dungeon,pos_dungeon_command) if pos_dungeon_command
      @game.click_bag(pos_bag,pos_bag_command) if pos_bag_command
      @game.go_to_next_floor if pos_button == 0
      @game.start_withdrawal if pos_button == 1
      @game.sort_bag if pos_bag_sort
      @game.dispose_item_select if pos_dispose_item
      @game.call_help if pos_help
    elsif @game.view_status == :select_cardset
      @game.open_door(pos_cardset) if pos_cardset
      @game.cancel_select_cardset if pos_cancel_select_cardset
    elsif @game.view_status == :gameover or @game.view_status == :game_clear
      if pos_back_to_title
        @game.initialize 
        Sound[:click].play
      end
    elsif @game.view_status == :help
      @game.call_help
    end

  end

  def pos_title_menu
    3.times do |i|
      #return i if(mcheck(MENU_X, MENU_Y[i], MENU_X+Font32.get_width(MENU_TEXT[i]), MENU_Y[i]+32))
      return i if(mcheck(TITLE_MENU_X, TITLE_MENU_Y[i], TITLE_MENU_X+130, TITLE_MENU_Y[i]+32))
    end
    return -1
  end

  def pos_dungeon
    @game.dungeon.size.times do |i|
      x = 20+120*i
      y = 10
      return i if mcheck(x,y,x+DUNGEON_WIDTH,y+DUNGEON_HEIGHT)
    end
    return false
  end

  def pos_dungeon_command
    pd = pos_dungeon
    return false unless pd

    3.times do |i|
      x = 20+120*pd
      y = 55+25*i
      return i if mcheck(x,y,x+60,y+20)
    end
    return false
  end

  def pos_bag
    @game.bag.each_with_index do |card,i|
      x = 260+70*(i%5)
      y = 260+(i/5).floor*70
      return i if mcheck(x,y,x+60,y+60)
    end
    return false
  end

  def pos_bag_command
    pb = pos_bag
    return false unless pb

    3.times do |i|
      x = 260+70*(pb%5)
      y = 260+(pb/5).floor*70+20*i
      return i if mcheck(x,y,x+60,y+20)
    end
    return false
  end

  def pos_cardset
    3.times do |i|
      y = 80 + 120*i
      return i if mcheck(170,y,570,y+100)
    end
    return false
  end

  def pos_cancel_select_cardset
    mcheck(60,360,120,380)
  end

  def pos_bag_sort
    mcheck(540,330,600,360)
  end

  def pos_dispose_item
    mcheck(540,370,600,400)
  end

  def pos_help
    mcheck(540,400,600,440)
  end

  def pos_button
    2.times do |i|
      y = 160+40*i
      return i if mcheck(500,160+40*i,600,190+40*i)
    end
    return false
  end

  def pos_back_to_title
    return mcheck(30,400,170,420)
  end

  def get_width(str)
    canvas = Native(`document.getElementById('dxopal-canvas')`)
    width = canvas.getContext('2d').measureText(str).width
    return width
  end

  def mcheck(x1,y1,x2,y2)
    x1 < @mx && x2 > @mx && y1 < @my && y2 > @my    
  end

end