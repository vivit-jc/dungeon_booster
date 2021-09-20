module Viewmisc

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