require 'ruby2d'

set title: "Ruby2D Mario", width: 512, height: 480

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
    "                      ?                                                         XXXXXXXXX   XXX?",
    "",
    "",
    "",
    "                ?   X?X?X                     ╒╕         ╒╕                  X?X               ?",
    "                                      ╒╕      ├┤         ├┤",
    "                            ╒╕        ├┤      ├┤         ├┤",
    "                            ├┤        ├┤      ├┤         ├┤",
    "OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO  OOOOOOOOOOOOOOOO   OOOOOO",
    "#####################################################################  ################   ######"
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
tileset.define_tile('pipe_top_left', 4, 6)
tileset.define_tile('pipe_top_right', 5, 6)
tileset.define_tile('pipe_left', 4, 7)
tileset.define_tile('pipe_right', 5, 7)
tileset.define_tile('undefined', 4, 9)

# Player
player = Rectangle.new(
    x: TILE_SIZE * 2,
    y: TILE_SIZE * 11,
    width: TILE_SIZE,
    height: TILE_SIZE * 2,
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
            
            # Collision box
            blocks << Square.new(
                x: x * TILE_SIZE,
                y: y * TILE_SIZE,
                size: TILE_SIZE,
                color: [1, 0, 0, 0]
            )
            
            # Graphics tile
            if char == "#"
                tiles["dirt"] << { x: x * TILE_SIZE, y: y * TILE_SIZE }
            elsif char == "O"
                tiles["grass_top"] << { x: x * TILE_SIZE, y: y * TILE_SIZE }
            elsif char == "X"
                tiles["brick"] << { x: x * TILE_SIZE, y: y * TILE_SIZE }
            elsif char == "?"
                tiles["question_mark_block"] << { x: x * TILE_SIZE, y: y * TILE_SIZE }
            elsif char == "╒"
                tiles["pipe_top_left"] << { x: x * TILE_SIZE, y: y * TILE_SIZE }
            elsif char == "╕"
                tiles["pipe_top_right"] << { x: x * TILE_SIZE, y: y * TILE_SIZE }
            elsif char == "├"
                tiles["pipe_left"] << { x: x * TILE_SIZE, y: y * TILE_SIZE }
            elsif char == "┤"
                tiles["pipe_right"] << { x: x * TILE_SIZE, y: y * TILE_SIZE }
            else
                tiles["undefined"] << { x: x * TILE_SIZE, y: y * TILE_SIZE }
            end
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
    player.x += dx

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
    blocks.each do |block|
        # Vertical collisions
        if aabb_collision?(player, block)
            # Collision from falling
            if player_vy > 0 && player.y + player.height > block.y
                player.y = block.y - player.height
                player_vy = 0
                on_ground = true
            end

            # Collision from jumping
            if player_vy < 0 && player.y < block.y + block.height
                player.y = block.y + block.height
                player_vy = 0
            end
        end
        
        # Horizontal collisions
        if aabb_collision?(player, block)
            if dx > 0
                # Moving right — push player to the left edge of block
                player.x -= MOVE_SPEED
            elsif dx < 0
                # Moving left — push player to the right edge of block
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
        block.x -= camera_x
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
