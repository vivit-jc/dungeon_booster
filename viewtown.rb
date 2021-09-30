module Viewtown

def draw_town
  text = ["アイテムの売り買いができる。","宝物の寄贈ができる。","アイテムを保管できる。","ダンジョンの探索に向かう。"]
  ["冒険者の店","博物館","倉庫","ダンジョン"].each_with_index do |bldg, i|
    x = 20+120*i
    pos = @controller.pos_town == i
    Window.draw(x,10,@dungeonback)
    Window.draw_font(x+3,13,bldg,Font16,@game.click_mode != :confirm_dungeon ? mouseover_color(pos) : {color: WHITE})
    if pos && @game.click_mode != :confirm_dungeon
      Window.draw_font(20,130,bldg,Font14)
      Window.draw_font(20,150,text[i],Font14)
    elsif @game.click_mode == :confirm_dungeon
      Window.draw_font(20,140,"ダンジョン探索を始めますか？",Font16)
      Window.draw_font(290,140,"はい",Font16,mouseover_color(@controller.pos_confirm_dungeon == 0))
      Window.draw_font(340,140,"いいえ",Font16,mouseover_color(@controller.pos_confirm_dungeon == 1))
    end
  end
  draw_town_set
end

def draw_shop
  @game.shop_item.each_with_index do |card,i|
    x = 20+70*(i%7)
    y = 10+82*(i/7).floor
    pos = @controller.pos_shop == i
    Window.draw(x,y,@itemback)
    Window.draw_font(x+8,y+63,card.price.to_s+"Ч",Font16)
    draw_item_note(pos,x,y,i,card,"買う")
  end
  draw_town_set
  draw_back_town_button
end

def draw_museum
  Window.draw_font(20,20,"寄贈した回数 #{@game.donate_count}",Font16)
  Window.draw_font(20,40,"score #{@game.score}",Font16)
  Window.draw_font(20,60,"ダンジョンを探索した回数 #{@game.explore_count}",Font16)
  if @game.click_mode == :confirm_game_clear
    Window.draw_font(20,140,"失われし王冠を寄贈するとゲームクリアとなります。よろしいですか？",Font16)
    Window.draw_font(20,160,"はい",Font16,mouseover_color(@controller.pos_confirm_game_clear == 0))
    Window.draw_font(90,160,"いいえ",Font16,mouseover_color(@controller.pos_confirm_game_clear == 1))
  else
    draw_back_town_button
  end
  draw_town_set
end

def draw_storage
  @game.storage.each_with_index do |card,i|
    x = 20+70*(i%7)
    y = 10+82*(i/7).floor
    pos = @controller.pos_storage == i
    Window.draw(x,y,@itemback)
    draw_item_note(pos,x,y,i,card,"出す")
  end
  draw_town_set
  draw_back_town_button
end

def draw_item_note(pos,x,y,i,card,com)
  if pos
    Window.draw_font(20,181,card.name,Font14)
    Window.draw_font(20,201,card.text,Font14)
    Window.draw_font(x+3,y+3,com,Font16,{color: GREEN})
  else
    Window.draw_scale(x-98,-88+82*(i/7).floor,Image[card.kind],0.2,0.2)
  end
end

def draw_info_town
  Window.draw(20,260,@infoback)
  Window.draw_font(30,270,"ダンジョンの上に立つ町",Font14)
  Window.draw_font(30,290,@game.get_persona,Font14)
  Window.draw_font(30,310,"所持金 #{@game.money}Ч",Font14)
end

def draw_back_town_button
  Window.draw(520,92,@itemback)
  Window.draw_font(523,95,"出る",Font16,mouseover_color(@controller.pos_back_town))
end

def draw_town_set
  draw_bag
  draw_log_short
  draw_info_town
end

end