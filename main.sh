#! /bin/bash

# Array of arguments
arg=($@)


function list () {
: << DOC
Descripcion:
    Muestra la lista de TODOS los panes activos.
Tipo:
    Funcion
Parametros:
    Ninguno
Salida:
    Stdout de:
      - Nombre de la session
      - Numero de ventanas
      - Id de la ventana.
      - Numero de panes.
      - Window Layout.
      - Path de los panes.
DOC
    TAB=$'\t'
    NL=$'\n'
    tmux list-panes -a -F "#S${TAB}#{session_windows}${TAB}#{window_id}${TAB}#{window_panes}${TAB}#{window_layout}${TAB}#{pane_current_path}${TAB}"
}

function numSession () {
: << DOC
Descripcion:
    Devuelve el numero de sessiones activas.
Tipo:
    Funcion
Parametros:
    Ninguno
Salida:
   Stdout de numero.

DOC
    i=0
    for x in $(tmux list-sessions -F "#S");
    do
        i=$(($i + 1))
    done
    echo $i
}

function nameSession () {
: << DOC
Descripcion:
    Devuelve "arreglo" con los nombre de las sessiones activas
Tipo:
    Funcion
Parametros:
    Ninguno
Salida:
    Stdout del array con los nombres.
DOC

    arr=()
    for session in $(tmux list-sessions -F "#S");do
        arr+=("session:$session ")
    done

    printf "%s" "${arr[@]}"
}


function infoWindow () {
: << DOC
Descripcion:
Tipo:
Parametros:
Salida:

DOC

    TAB=$'\t'
    arr=()

    IFS=':' read -a arr <<< $(tmux list-windows -t $1 -f "#{==:#{window_index},$2}" -F "#{window_index}:#W:#{window_layout}:#{window_panes}")

    echo "${arr[@]}"
}


function PruebaInfoWindow {
: << DOC
Descripcion:
Tipo:
Parametros:
Salida:

DOC
    infoWindow TMUX 0
}



function createYAML () {
: << DOC
Descripcion:
    Funcion que busca las sessiones abierta, las compara con las guardadas y genera un archivo YAML para guardar los cambios.
Tipo:
    Funcion
Parametros:
    Ninguno
Salida:
    Stdout del archivo YAML
DOC

    /bin/cat<<YAML
---
YAML

    for x in $(nameSession);do
        session=$(echo "$x" | cut -d ":" -f 2)
        session=$(sessionExit $session) #Verifica que la session exite
        if [ -z $session ];then
            echo "Entonces la crea"
        else
            echo "Pregunta si desea modificarla"
        fi # Fin if sessionExit


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
: << DOC
Descripcion:
Tipo:
Parametros:
Salida:

DOC
    createYAML > ~/.tmux-session
}


function sessionExit {
: << DOC
Descripcion:
Tipo:
Parametros:
Salida:

DOC
    #var="session:${arg[1]}"
    var="session:$1"

    if [ -f ~/.tmux.session ];then
        echo "ENTRO"
        session="$(grep "$var" ~/.tmux-session)"
    fi

    if [ -z "$session" ];then
        echo ""
    else
        var=$(echo $session | cut -d ":" -f 2)
        echo "$var"
    fi
    #printf "%s\n" $session
}


function Prueba {
: << DOC
Descripcion:
Tipo:
Parametros:
Salida:

DOC
    arr=$(tmux list-sessions -F "#S" )
    arr=(${arr[@]} "100" "200")

    for i in "${arr[@]}";do

        #echo $i
        session=$(sessionExit "$i")
        echo "La session es:${session}"

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
    infoWindow | \
    PruebaInfoWindow )
        $1
        ;;
    *)
        echo "valid comands: show_list, list, createYAML"
        exit 1
esac

