require_remote './card.rb'
require_remote './click.rb'
require_remote './item.rb'
require_remote './monster.rb'
require_remote './misc.rb'

class Game

include Click
include Item
include Monster
include Misc

attr_accessor :status, :page, :view_status
attr_reader :game_status, :game_status_memo, :click_mode, :bag, :deck, :dungeon, :stock, :atk, :hp, :max_hp, :log, :e_weapon, :e_shield,
:run, :run_max, :withdraw, :gameover, :dungeon_max, :using_card, :help_page, :select_mode, :cardset, :score


  def initialize

    Card.define_kind

    @status = :title
    @game_status = nil
    @game_status_memo = nil
    @place = nil
    @click_mode = nil
    @select_mode = nil
    @view_status = :main_view
    @deck = []
    @dungeon = []
    @bag = []
    @stock = []
    @hp = 10
    @max_hp = 10
    @base_hp = 10
    @e_weapon = nil
    @e_shield = nil
    @atk = 0
    @atk_buff = 0
    @hp_buff = 0
    @run = 0
    @run_max = 2
    @run_max_floor = nil
    @escape_trap = 0
    @using_card = nil

    @withdraw = false
    @game_clear = false
    @gameover = false
    @completed = false
    @score = 0

    @log = []
    @help_page = nil

    init_testmode
    init_deck
  end

  def start
    Sound[:click].play
    @status = :game
  end

  def init_testmode
    @place = :dungeon
  end

  def init_deck

    @deck = []
    @deck << make_card_at_random(:rune,1)
    @deck << make_card_at_random(:weapon,1)
    @deck << make_card_at_random(:shield,1)
    2.times{@deck << make_card_at_random(:monster,2)}
    7.times{@deck << make_card_at_random(:monster,1)}
    3.times{@deck << make_card_at_random(:door,1)}
    3.times{@deck << make_card_at_random(:trap,1)}
    7.times{@deck << make_card_at_random([:scroll,:potion,:treasure].sample,1)}

    @dungeon_max = @deck.size
    @deck.shuffle!
    go_to_next_floor(true)
  end

  def add_log(str)
    @log.push str
  end

  def damage(num,src)
    @hp -= num
    check_death(src)
  end

  def check_death(src)
    return false if @hp > 0
    Sound[:gameover].play
    add_log(src+"??????????????????????????????")
    add_log("?????????????????????????????????")
    @gameover = true
    @view_status = :gameover
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

  def rest_run
    if @run_max_floor
      return @run_max_floor #?????????????????????????????????????????????
    elsif @run_max <= @run
      return 0
    else
      return @run_max - @run
    end
  end

end