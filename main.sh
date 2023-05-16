#! /bin/bash

# Array of arguments
arg=($@)

# Muestra la lista de panes con la informacion necesaria

list () {
    TAB=$'\t'
    NL=$'\n'
    tmux list-panes -a -F "#S${TAB}#{session_windows}${TAB}#{window_id}${TAB}#{window_panes}${TAB}#{window_layout}${TAB}#{pane_current_path}${TAB}"
}

show_list () {
    line_array=()
    list | \
    while IFS=$'\t' read  seccion num_window windowId numPanes windowLayout panePath;do
        #printf '%s\n' "$a"
        #echo $b

        #printf 'seccion: %s numwindows: %s window id: %s numPanes: %s windowLayout: %s panePath: %s \n' "$seccion" "$num_window" "$windowId" "$numPanes" "$windowLayout" "$panePath"

        #echo ${seccion}
        linea="seccion: $seccion  numwindows: $num_window window id: $windowId numPanes: $numPanes windowLayout: $windowLayout panePath: $panePath \n"


        #echo $linea
        local line_array=(${line_array[@]}  "seccion: $seccion  numwindows: $num_window window id: $windowId numPanes: $numPanes windowLayout: $windowLayout panePath: $panePath" )
        echo "${line_array[@]}" > 2
    done

    read -r line_array < 2
    echo "${line_array[1]}"
}

#list
#prueba

function numSession {
    i=0
    for x in $(tmux list-sessions -F "#S");
    do
        i=$(($i + 1))
    done
    echo $i
}

#function Prueba {
    #nSession=$(numSession)
    #echo "El numero de Sessions es: $nSession"
#}

function nameSession {

    arr=()
    for session in $(tmux list-sessions -F "#S");
    do
        arr+=("session:$session ")
    done

    printf '%s' "${arr[@]@Q}"
}

function infoWindow {
    TAB=$'\t'
    arr=()

    IFS=':' read -a arr <<< $(tmux list-windows -t $1 -f "#{==:#{window_index},$2}" -F "#{window_index}:#W:#{window_layout}:#{window_panes}")

    echo "${arr[@]@Q}"
   # echo "${#arr[@]}"

}

#function Prueba {
    #infoWindow TMUX 0
#}


#function Prueba {
#    session="$(nameSession)"
#    echo "$session"
#}

function createYAML {
    /bin/cat<<YAML
---
YAML

    for x in $(nameSession);do
        session=$(echo "$x" | cut -d ":" -f 2)
        /bin/cat<<YAML
  session:$session
YAML

        for index in $(tmux list-windows -t "$session" -F "#{window_index}");do
            arr=$(infoWindow $session $index)
            name=$(echo "$arr" | cut -d " " -f 2)
            layout=$(echo "$arr" | cut -d " " -f 3)
            panes=$(echo "$arr" | cut -d " " -f 4)

            /bin/cat<<YAML
    window:$index
      name:$name
      layout:$layout
      panes:
        cant:$panes
YAML
            for i in $(tmux list-panes -t "$session":"$window_index" -F "#{pane_current_path}");do
                /bin/cat<<YAML
          path:"$i"
YAML
            done # For Panes

        done # For Windows

    done # For Sessions
}  # End of CreateYAML


function saveYAML {
    createYAML > ~/.tmux-session
}


function sessionExit {
    #var="session:${arg[1]}"
    var="$1"
    echo "El argumento es $var"
    session="$(grep "$var" ~/.tmux-session)"
    echo "La session es: $session"
    if [ -z "$session" ];then
        echo ""
    else
        var=$(echo $session | cut -d ":" -f 2)
        echo "$var"
    fi
    #printf "%s\n" $session
}

function Prueba {
    arr=$(tmux list-sessions -F "#S" )
    arr=(${arr[@]} "100" "200")

    for i in "${arr[@]}";do

        echo $i
        session=$(sessionExit "$i")
        echo "${session}"

        if [ -z $session ];then
            echo "No existe"
        else
            echo "Existe"
        fi
    done
}



case "$1" in
    show_list | \
    list | \
    createYAML | \
    saveYAML | \
    sessionExit | \
    createArray | \
    Prueba | \
    numSession | \
    nameSession | \
    create | \
    infoWindow )
        $1
        ;;
    *)
        echo "valid comands: show_list, list, createYAML"
        exit 1
esac
