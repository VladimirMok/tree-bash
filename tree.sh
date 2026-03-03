#!/bin/bash

# tree.sh — аналог команды tree из cmd для bash
# Использование: ./tree.sh [путь] [-d глубина] [-a]


usage() {
    echo "Использование: $0 [путь] [-d глубина] [-a]"
    echo "  -d <число>  — ограничить глубину вывода"
    echo "  -a        — показать скрытые файлы (.files)"
    exit 1
}

# Параметры
PATH_TO_SHOW="."
MAX_DEPTH=10
SHOW_HIDDEN=false

# Разбор аргументов
while [[ $# -gt 0 ]]; do
    case $1 in
        -d)
            MAX_DEPTH="$2"
            shift 2
            ;;
        -a)
            SHOW_HIDDEN=true
            shift
            ;;
        -*)
            usage
            ;;
        *)
            PATH_TO_SHOW="$1"
            shift
            ;;
    esac
done

# Проверка пути
if [[ ! -d "$PATH_TO_SHOW" ]]; then
    echo "Ошибка: каталог '$PATH_TO_SHOW' не существует."
    exit 1
fi

# Цвета
DIR_COLOR="\033[1;34m"  # Синий, жирный
FILE_COLOR="\033[0;37m" # Белый
RESET="\033[0m"          # Сброс цвета

# Рекурсивная функция вывода
print_tree() {
    local dir="$1"
    local prefix="$2"
    local depth="$3"

    # Превышена глубина?
    if (( depth > MAX_DEPTH )); then
        return
    fi

    # Список элементов
    local items=()
    if $SHOW_HIDDEN; then
        items=( "$dir"/.* "$dir"/* )
    else
        items=( "$dir"/* )
    fi

    # Фильтруем несуществующие (пустые * при отсутствии файлов)
    items=($(for i in "${items[@]}"; do [[ -e "$i" ]] && echo "$i"; done))

    local total=${#items[@]}
    local counter=1

    for item in "${items[@]}"; do
        # Имя файла/папки
        local name=$(basename "$item")

        # Пропускаем . и ..
        [[ "$name" == "." || "$name" == ".." ]] && continue

        # Определяем тип
        if [[ -d "$item" ]]; then
            local type="dir"
            local color="$DIR_COLOR"
        else
            local type="file"
            local color="$FILE_COLOR"
        fi

        # Линия соединения
        if (( counter == total )); then
            local connector="└── "
        else
            local connector="├── "
        fi

        # Выводим
        echo -e "${prefix}${connector}${color}${name}${RESET}"

        # Если это папка — рекурсия
        if [[ "$type" == "dir" ]]; then
            local new_prefix="${prefix}    "
            if (( counter < total )); then
                new_prefix="${prefix}│   "
            else
                new_prefix="${prefix}    "
            fi
            print_tree "$item" "$new_prefix" $((depth + 1))
        fi

        ((counter++))
    done
}

# Запуск
echo "$PATH_TO_SHOW"
print_tree "$PATH_TO_SHOW" "" 1
