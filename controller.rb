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
    case @game.place
    when :dungeon
      click_on_dungeon
    when :town
      click_on_town
    when :shop
      click_on_shop
    when :museum
      click_on_museum
    when :storage
      click_on_storage
    end
  end

  def click_on_dungeon
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
      click_bag_sub_button
    elsif @game.view_status == :select_cardset
      @game.open_door(pos_cardset) if pos_cardset
      @game.cancel_select_cardset if pos_cancel_select_cardset
    elsif @game.view_status == :gameover
      click_back_to_title
    elsif @game.view_status == :help
      @game.call_help
    end
  end

  def click_on_town
    if @game.view_status == :help
      @game.call_help
    elsif @game.click_mode == :confirm_dungeon
      @game.enter_the_dungeon if pos_confirm_dungeon == 0
      @game.cancel_confirm_dungeon if pos_confirm_dungeon == 1
    elsif @game.view_status == :main_view
      case pos_town
      when 0
        @game.enter_shop
      when 1
        @game.enter_museum
      when 2
        @game.enter_storage
      when 3
        @game.confirm_dungeon
      end
      click_bag_sub_button
    end
  end

  def click_on_shop
    @game.buy_item(pos_shop) if pos_shop
    @game.sell_item(pos_bag) if pos_bag_command == 0
    @game.back_town if pos_back_town
    click_bag_sub_button
  end

  def click_on_museum
    if @game.view_status == :game_clear
      click_back_to_title
      return
    elsif @game.click_mode == :confirm_game_clear
      @game.calc_game_clear if pos_confirm_game_clear == 0
      @game.cancel_confirm_game_clear if pos_confirm_game_clear == 1
      return
    end
    @game.donate_treasure(pos_bag) if pos_bag_command == 0
    @game.back_town if pos_back_town
    click_bag_sub_button

  end

  def click_on_storage
    @game.get_item(pos_storage) if pos_storage
    @game.put_item(pos_bag) if pos_bag_command == 0
    @game.back_town if pos_back_town
    click_bag_sub_button
  end

  def click_bag_sub_button
    @game.sort_bag if pos_bag_sort
    @game.dispose_item_select if pos_dispose_item
    @game.call_help if pos_help
  end

  def click_back_to_title
    if pos_back_to_title
      @game.initialize 
      Sound[:click].play
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

  def pos_town
    4.times do |i|
      x = 20+120*i
      y = 10
      return i if mcheck(x,y,x+DUNGEON_WIDTH,y+DUNGEON_HEIGHT)
    end
    return false
  end

  def pos_shop
    pos_storage_or_shop(@game.shop_item)
  end

  def pos_storage
    pos_storage_or_shop(@game.storage)
  end

  def pos_storage_or_shop(cards)
    cards.size.times do |i|
      x = 20+70*(i%7)
      y = 10+82*(i/7).floor
      return i if mcheck(x,10,x+60,y+60)
    end
    return false
  end

  def pos_back_town
    mcheck(520,92,580,152)
  end

  def pos_confirm_dungeon
   return 0 if mcheck(290,140,330,160)
   return 1 if mcheck(340,140,400,160)
   return false 
  end

  def pos_confirm_game_clear
   return 0 if mcheck(20,160,60,180)
   return 1 if mcheck(90,160,140,180)
   return false 
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