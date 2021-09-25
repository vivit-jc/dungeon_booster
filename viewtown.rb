module Viewtown

def draw_town
  text = ["アイテムの売り買いができる。","宝物の寄贈ができる。","アイテムを保管できる。","ダンジョンの探索に向かう。"]
  ["冒険者の店","博物館","倉庫","ダンジョン"].each_with_index do |bldg, i|
    x = 20+120*i
    pos = @controller.pos_town == i
    Window.draw(x,10,@dungeonback)
    Window.draw_font(x+3,13,bldg,Font16,mouseover_color(pos))
    if pos
      Window.draw_font(20,130,bldg,Font14)
      Window.draw_font(20,150,text[i],Font14)
    end
  end
  draw_bag
  draw_log
  draw_info_town
end

def draw_shop
end

def draw_musium
end

def draw_storage
end

def draw_info_town
  Window.draw(20,260,@infoback)
  Window.draw_font(30,270,"ダンジョンの上に立つ町",Font14)
  Window.draw_font(30,290,"所持金 #{@game.money}Ч",Font14)
end

end