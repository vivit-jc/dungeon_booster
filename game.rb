require_remote './card.rb'
require_remote './click.rb'

class Game

include Click

attr_accessor :status, :page, :view_status
attr_reader :game_status, :game_status_memo, :click_mode, :bag, :deck, :dungeon, :stock, :hp, :max_hp, :log, :e_weapon, :e_shield,
:run, :run_max


  def initialize
    @status = :title
    @game_status = nil
    @game_status_memo = nil
    @place = nil
    @click_mode = nil
    @view_status = :main_view
    @deck = []
    @dungeon = []
    @bag = []
    @stock = []
    @hp = 10
    @max_hp = 10
    @base_hp = 10
    @dungeon_max = 15
    @e_weapon = nil
    @e_shield = nil
    @att_buff = 0
    @hp_buff = 0
    @run = 0
    @run_max = 2

    @log = []

    init_testmode
    init_deck
  end

  def start
    @status = :game
  end

  def init_testmode
    @click_mode = :dungeon_attack
    @place = :dungeon
  end

  def init_deck
    temp_deck = [[:monster,0],[:monster,0],[:monster,0],[:monster,0],[:monster,0],
    [:monster,1],[:monster,1],[:monster,1],[:monster,2],[:monster,3],
    [:scroll,0],[:weapon,0],[:shield,0],[:potion,0],[:potion,0],[:potion,0],
    [:treasure,0],[:trap,0],[:trap,1]]
    temp_deck << [:rune,rand(2)]
    temp_deck.each_with_index do |e,i|
      @deck.push Card.new(e[0],e[1])
    end
    @deck.shuffle!
    go_to_next_floor(true)
  end

  def add_log(str)
    @log.push str
  end

  def monster_exist_front?(num)
    num.times do |i|
      return true if @dungeon[i].kind == :monster
    end
    return false
  end

  def monster_exist?
    @dungeon.find{|c|c.kind == :monster}
  end

end