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
    case @game.click_mode
    when :select_invasion_bonus, :select_great_person_bonus, :select_wonder_from_engineer
      @game.click_bonus(pos_bonus) if pos_bonus
      return
    when :select_tech_from_scientist
      @game.finish_tech_from_scientist(@game.get_tech_sym_from_xy(pos_tech_view)) if pos_tech_view
      return
    when :select_hand
      return unless pos_hand
      @game.click_hand(pos_hand)
      return
    when :delete_unit
      if pos_unit
        @game.click_unit(pos_unit)
      else
        @game.cancel_delete_unit
      end
      return
    end

    if @game.view_status == :main_view
      @game.click_dungeon(pos_dungeon,pos_dungeon_command) if pos_dungeon_command
      @game.click_bag(pos_bag,pos_bag_command) if pos_bag_command
      @game.go_to_next_floor if pos_button == 0
      @game.start_withdrawal if pos_button == 1
      @game.sort_bag if pos_bag_sort
    elsif @game.view_status == :gameover or @game.view_status == :game_clear
      @game.initialize if pos_back_to_title
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
      y = 30+20*i
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

  def pos_bag_sort
    mcheck(540,330,600,390)
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