require_remote './card.rb'
require_remote './click.rb'
require_remote './item.rb'
require_remote './monster.rb'
require_remote './door.rb'
require_remote './trap.rb'
require_remote './town.rb'
require_remote './misc.rb'

class Game

include Click
include Item
include Monster
include Door
include Trap
include Town
include Misc

attr_accessor :status, :page, :view_status
attr_reader :game_status, :game_status_memo, :click_mode, :place, :bag, :deck, :dungeon, :stock, :atk, :hp, :max_hp, :log, :e_weapon, :e_shield,
:run, :run_max, :escape_trap, :withdraw, :gameover, :dungeon_max, :using_card, :help_page, :select_mode, :cardset, :score, :layer, :money,
:shop_item, :donate_count, :explore_count

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
    @money = 100
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
    @escape_trap = 2
    @using_card = nil
    @layer = 0
    @donate_count = 0
    @explore_count = 0
    @deck_reserve = [[],[],[],[]]

    @withdraw = false
    @game_clear = false
    @gameover = false
    @completed = false
    @score = 0

    @log = []
    @help_page = nil

    init_testmode
    init_shop
  end

  def start
    Sound[:click].play
    @status = :game
  end

  def init_testmode
    @place = :town
  end

  def init_deck

    @deck = []
    @dungeon = []
    @stock = []

    case @layer
    when 0 #上層
      @deck << Stairs.new(:down_stairs,@layer)
      @deck << make_card_at_random(:rune,1)
      @deck << make_card_at_random(:weapon,1)
      @deck << make_card_at_random(:shield,1)
      2.times{@deck << make_card_at_random(:monster,2)}
      7.times{@deck << make_card_at_random(:monster,1)}
      3.times{@deck << make_card_at_random(:door,1)}
      3.times{@deck << make_card_at_random(:trap,1)}
      7.times{@deck << make_card_at_random([:scroll,:potion,:treasure].sample,1)}
    when 1 #中層
      @deck << Stairs.new(:down_stairs,@layer)
      @deck << make_card_at_random(:rune,2)
      @deck << make_card_at_random(:weapon,2)
      @deck << make_card_at_random(:shield,2)
      10.times{@deck << make_card_at_random(:monster,2)}
      3.times{@deck << make_card_at_random(:door,1)}
      3.times{@deck << make_card_at_random(:trap,1)}
      7.times{@deck << make_card_at_random([:scroll,:potion,:treasure].sample,1)}
    when 2 #下層
      @deck << Stairs.new(:down_stairs,@layer)
      @deck << make_card_at_random(:rune,2)
      @deck << make_card_at_random(:weapon,2)
      @deck << make_card_at_random(:shield,2)
      10.times{@deck << make_card_at_random(:monster,2)}
      3.times{@deck << make_card_at_random(:door,1)}
      3.times{@deck << make_card_at_random(:trap,1)}
      7.times{@deck << make_card_at_random([:scroll,:potion,:treasure].sample,1)}
    when 3 #最下層
      @deck << Card.new(:treasure,4)
      @deck << make_card_at_random(:rune,2)
      @deck << make_card_at_random(:weapon,2)
      @deck << make_card_at_random(:shield,2)
      10.times{@deck << make_card_at_random(:monster,2)}
      3.times{@deck << make_card_at_random(:door,1)}
      3.times{@deck << make_card_at_random(:trap,1)}
      7.times{@deck << make_card_at_random([:scroll,:potion,:treasure].sample,1)}

    end

    @dungeon_max = @deck.size
    go_to_next_floor(true)
  end

end