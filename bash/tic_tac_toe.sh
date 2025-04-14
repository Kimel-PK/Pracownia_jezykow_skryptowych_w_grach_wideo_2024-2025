#!/bin/bash

current_player=0
board=(" " " " " " " " " " " " " " " ")

print_board() {
    printf "%s\n" "   1   2   3"
    printf "A  %s | %s | %s\n" "${board[0]}" "${board[1]}" "${board[2]}"
    printf "%s\n" "  ---+---+---"
    printf "B  %s | %s | %s\n" "${board[3]}" "${board[4]}" "${board[5]}"
    printf "%s\n" "  ---+---+---"
    printf "C  %s | %s | %s\n\n" "${board[6]}" "${board[7]}" "${board[8]}"
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
        if [[ "$i" == " " ]]; then return 1; fi
    done
    return 0
}

cell_to_number() {
    local input="$1"
    local row=${input:0:1}
    local col=${input:1:1}

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

while true; do
    print_board
    echo "Player $((current_player + 1))"
    echo "Choose cell (ex. A1):"
    read -r cell_input
    cell=$(cell_to_number $cell_input)
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
        echo "Player $((current_player + 1)) wins!"
        break
    elif check_draw; then
        print_board
        echo "Draw"
        break
    fi

    if [[ $current_player == 0 ]]; then
        current_player=1
    else
        current_player=0
    fi
done
