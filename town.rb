module Town

def enter_the_dungeon
  init_deck
  @place = :dungeon
  Sound[:stairs].play
end

end