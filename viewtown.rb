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
  @game.shop_item.each_with_index do |item,i|
    x = 20+70*i
    y = 10
    pos = @controller.pos_shop == i
    Window.draw(x,y,@itemback)
    Window.draw_font(x+8,y+63,item.price.to_s+"Ч",Font16)
    if pos
      Window.draw_font(20,130,item.name,Font14)
      Window.draw_font(20,150,item.text,Font14)
      Window.draw_font(x+3,y+3,"買う",Font16,{color: GREEN})
    else
      Window.draw_scale(x-98,-88,Image[item.kind],0.2,0.2)
    end
  end
  Window.draw(540,110,@itemback)
  Window.draw_font(543,113,"出る",Font16,mouseover_color(@controller.pos_back_town))
  draw_bag
  draw_log
  draw_info_town
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