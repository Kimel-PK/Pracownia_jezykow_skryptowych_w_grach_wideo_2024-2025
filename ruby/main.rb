require 'ruby2d'

set title: "Ruby2D Mario", width: 512, height: 480
set background: [0.360, 0.580, 0.988, 1.0]

# Constants
TILE_SIZE = 32
GRAVITY = 0.35
JUMP_FORCE = -10
MOVE_SPEED = 3

# Level map
LEVEL_MAP = [
    "",
    "",
    "",
    "",
    "",
    "                      ?                                                         XXXXXXXXX   XXX?              ?           XXX    X??X                                                        BB",
    "                                                                                                                                                                                            BBB",
    "                                                                                                                                                                                           BBBB",
    "                                                                                                                                                                                          BBBBB",
    "                ?   X?X?X                     ╒╕         ╒╕                  X?X               ?     XX    ?  ?  ?     X          XX      B  B          BB  B            XX?X            BBBBBB",
    "                                      ╒╕      ├┤         ├┤                                                                              BB  BB        BBB  BB                          BBBBBBB",
    "                            ╒╕        ├┤      ├┤         ├┤                                                                             BBB  BBB      BBBB  BBB     ╒╕              ╒╕ BBBBBBBB",
    "                            ├┤        ├┤      ├┤         ├┤                                                                            BBBB  BBBB    BBBBB  BBBB    ├┤              ├┤BBBBBBBBB        B",
    "OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO  OOOOOOOOOOOOOOOO   OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO  OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO",
    "#####################################################################  ################   ################################################################  ###########################################################"
]

tileset = Tileset.new(
    'assets/tiles.png',
    tile_width: TILE_SIZE,
    tile_height: TILE_SIZE,
    padding: 0,
    spacing: 0,
)

tileset.define_tile('grass_top', 0, 0)
tileset.define_tile('dirt', 2, 6)
tileset.define_tile('brick', 2, 9)
tileset.define_tile('question_mark_block', 3, 9)
tileset.define_tile('question_mark_block_collected', 5, 9)
tileset.define_tile('pipe_top_left', 4, 6)
tileset.define_tile('pipe_top_right', 5, 6)
tileset.define_tile('pipe_left', 4, 7)
tileset.define_tile('pipe_right', 5, 7)
tileset.define_tile('undefined', 4, 9)

# Block collisions and types
class Block
  attr_reader :collider
  attr_accessor :type

  def initialize(collider, type)
    @collider = collider
    @type = type
  end
end

# Player
player = Rectangle.new(
    x: TILE_SIZE * 0.8 * 2,
    y: TILE_SIZE * 0.8 * 11,
    width: TILE_SIZE * 0.8,
    height: TILE_SIZE * 0.8 * 2,
    color: 'blue'
)

player_vy = 0
on_ground = false
died = false

blocks = []
tiles = Hash.new { |hash, key| hash[key] = [] }

def create_level(blocks, tiles)
    # Clear arrays
    blocks.clear
    tiles.clear
    
    # Create level tiles
    LEVEL_MAP.each_with_index do |row, y|
        row.chars.each_with_index do |char, x|
            if char == " "
                next
            end
            
            tile_type = case char
            when "#"
                "dirt"
            when "O"
                "grass_top"
            when "X"
                "brick"
            when "?"
                "question_mark_block"
            when "╒"
                "pipe_top_left"
            when "╕"
                "pipe_top_right"
            when "├"
                "pipe_left"
            when "┤"
                "pipe_right"
            else
                "undefined"
            end
            
            # Graphics tile
            tiles[tile_type] << { x: x * TILE_SIZE, y: y * TILE_SIZE }
            
            # Collision box
            blocks << Block.new(Square.new(
                x: x * TILE_SIZE,
                y: y * TILE_SIZE,
                size: TILE_SIZE,
                color: [1, 0, 0, 0]
            ), tile_type)
        end
    end
end

# Camera offset
camera_x = 0

# Input
keys = {}

on :key_held do |event|
    keys[event.key] = true
end

on :key_up do |event|
    keys[event.key] = false
    if event.key == "space" and player_vy < 0 and !died
        player_vy /= 2
    end
end

def aabb_collision?(a, b)
    a.x < b.x + b.width &&
    a.x + a.width > b.x &&
    a.y < b.y + b.height &&
    a.y + a.height > b.y
end

# Main
create_level(blocks, tiles)

points = 0
lives = 3

hud = Text.new(
    "Points: #{points}  Lives: #{lives}",
    x: 10,
    y: 10,
    size: 20,
    color: 'white',
    z: 100  # draw above other objects
)

update do
    
    # Movement
    dx = 0
    if !died
        dx -= MOVE_SPEED if keys['left']
        dx += MOVE_SPEED if keys['right']
    end

    # Jump
    if keys['space'] && on_ground
        player_vy = JUMP_FORCE
        on_ground = false
    end
    
    # Apply gravity
    player_vy += GRAVITY
    player.y += player_vy

    # Check collisions
    on_ground = false
    
    block_to_remove = nil
    
    # Vertical collisions
    blocks.each do |block|
        collider = block.collider
        type = block.type
        
        if aabb_collision?(player, collider)
            # Collision from falling
            if player_vy > 0 && player.y + player.height > collider.y
                player.y = collider.y - player.height
                player_vy = 0
                on_ground = true
            end

            # Collision from jumping
            if player_vy < 0 && player.y < collider.y + collider.height
                if type == "brick" or type == "question_mark_block"
                    block_to_remove = block
                end
                player.y = collider.y + collider.height
                player_vy = 0
            end
        end
    end
    
    if block_to_remove
        case block_to_remove&.type
        when "brick"
            points += 50
            blocks.delete(block_to_remove) 
            tiles[block_to_remove&.type].delete_if do |tile|
                tile[:x] == block_to_remove.collider.x && tile[:y] == block_to_remove.collider.y
            end
        when "question_mark_block"
            points += 200
            block_to_remove.type = "question_mark_block_collected"
            tiles[block_to_remove&.type].delete_if do |tile|
                tile[:x] == block_to_remove.collider.x && tile[:y] == block_to_remove.collider.y
            end
            tiles["question_mark_block_collected"] << { x: block_to_remove.collider.x, y: block_to_remove.collider.y }
        end
        
        # Update hud
        hud.text = "Points: #{points}  Lives: #{lives}"
    end
    
    player.x += dx
    
    # Horizontal collisions
    blocks.each do |block|
        collider = block.collider
        
        if aabb_collision?(player, collider)
            if dx > 0
                # Moving right — push player to the left edge of collider
                player.x -= MOVE_SPEED
            elsif dx < 0
                # Moving left — push player to the right edge of collider
                player.x += MOVE_SPEED
            end
        end
    end

    # Camera follow
    camera_x = player.x - Window.width / 2
    camera_x = 0 if camera_x < 0

    # Apply camera transform to tiles
    tiles.each_value do |tile_array|
        tile_array.each do |tile|
            tile[:x] -= camera_x
        end
    end
    
    tileset.clear_tiles()
    tiles.each do |type, tile_array|
        tileset.set_tile(type, tile_array)
    end

    # Apply camera transform to collision blocks
    blocks.each do |block|
        collider = block.collider
        collider.x -= camera_x
    end

    player.x = 0 if player.x < 0
    player.x -= camera_x
    
    if player.y > 500
        if !died
            player_vy = -15
            died = true
        else
            # Lose life
            lives -= 1
            if lives == 0
                lives = 3
                points = 0
            end
            hud.text = "Points: #{points}  Lives: #{lives}"
            
            # Reset to start of level
            create_level(blocks, tiles)
            player.x = TILE_SIZE * 2
            player.y = TILE_SIZE * 11
            died = false
        end
    end
end

show
