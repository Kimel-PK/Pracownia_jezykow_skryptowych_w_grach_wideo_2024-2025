#!/bin/bash

current_player=0
board=(" " " " " " " " " " " " " " " " " ")

print_board() {
    echo "   1   2   3"
    echo "A  ${board[0]} | ${board[1]} | ${board[2]}"
    echo "  ---+---+---"
    echo "B  ${board[3]} | ${board[4]} | ${board[5]}"
    echo "  ---+---+---"
    echo "C  ${board[6]} | ${board[7]} | ${board[8]}"
}

check_win() {
    for i in 0 3 6; do
        if [[ "${board[$i]}" == $(player_to_symbol) && "${board[$i+1]}" == $(player_to_symbol) && "${board[$i+2]}" == $(player_to_symbol) ]]; then
            return 0;
        fi
    done
    for i in 0 1 2; do
        if [[ "${board[$i]}" == $(player_to_symbol) && "${board[$i+3]}" == $(player_to_symbol) && "${board[$i+6]}" == $(player_to_symbol) ]]; then
            return 0;
        fi
    done
    if [[ "${board[0]}" == $(player_to_symbol) && "${board[4]}" == $(player_to_symbol) && "${board[8]}" == $(player_to_symbol) ]]; then
        return 0;
    fi
    if [[ "${board[2]}" == $(player_to_symbol) && "${board[4]}" == $(player_to_symbol) && "${board[6]}" == $(player_to_symbol) ]]; then
        return 0;
    fi
    return 1
}

check_draw() {
    for i in "${board[@]}"; do
        if [[ "$i" == " " ]]; then
            return 1;
        fi
    done
    return 0
}

cell_to_number() {
    local cell="$1"
    local row=${cell:0:1}
    local col=${cell:1:1}

    local cell_index
    case "$row" in
        A) cell_index=0 ;;
        B) cell_index=3 ;;
        C) cell_index=6 ;;
        *) return 1 ;;
    esac

    if [[ $col =~ [1-3] ]]; then
        ((cell_index += $((col - 1))))
    else
        return 1
    fi

    echo $cell_index
    return $cell_index
}

player_to_symbol() {
    if [[ $current_player -eq 0 ]]; then
        echo "X"
    else
        echo "O"
    fi
}

save_game() {
    game_state=$current_player
    for i in "${board[@]}"; do
        if [[ "$i" == " " ]]; then
            game_state+="-"
        else
            game_state+=$i
        fi
    done
    echo -e "\033[32mGame saved:\033[0m"
    echo -e "\033[32m$game_state\033[0m"
    echo -e "\033[32mUse this string to load game later\033[0m"
    echo ""
}

load_game() {
    echo "Insert game state string:"
    read -r input
    current_player=${input:0:1}
    local cells=${input:1:9}
    for (( i=0; i<${#cells}; i++ )); do
        char="${cells:$i:1}"
        if [[ "$char" == "-" ]]; then
            board[$i]=" "
        else
            board[$i]=$char
        fi
    done
    echo "Game loaded"
    echo ""
}

while true; do
    print_board
    echo "Player $((current_player + 1))"
    echo "S - save game, L - load game\n"
    echo "Choose cell (ex. A1):"
    read -r input
    
    if [[ "$input" == "S" ]]; then
        save_game
        continue
    elif [[ "$input" == "L" ]]; then
        load_game
        continue
    fi
    
    cell=$(cell_to_number $input)
    if ! [[ "$cell" =~ ^[0-9]$ ]]; then
        echo "Cell does not exists"
        continue
    fi
    if [[ "${board[$cell]}" != " " ]]; then
        echo "Cell is already taken"
        continue
    fi
    board[$cell]=$(player_to_symbol)

    if check_win; then
        print_board
        echo ""
        echo -e "\033[32mPlayer $((current_player + 1)) wins!\033[0m"
        break
    elif check_draw; then
        print_board
        echo ""
        echo -e "\033[33mDraw\033[0m"
        break
    fi

    if [[ $current_player == 0 ]]; then
        current_player=1
    else
        current_player=0
    fi
done
