#!/bin/bash

## Version 0.3 [Rearmada]
## Cambios de esta version:
## No se usan mas bucles
## Soporte de categorias
## Opcion de bajar wallpapers con solo pasar el link (a wallbase)
## Soporte de directorios corregido
##
## Se borro:
## El manejo de la cantidad por bucles
## El uso de funciones a medias

## Variables globales [Default]

walls=10 # Cantidad de wallpapers por default
categoria="high-resolution" # Aca puede ir 'high-resolution' 'rozne' 'manga-anime'
dir=$PWD # Directorio por default [A USAR]

## Variables del programa [Se recomienda no editarlas]
file1="cache1.txt"
file2="cache2.txt"
file3="cache3.txt"
wget_list="wget-list.txt"
option="normal"
cant=0

normal.reload() {
wget -O "$file1" "http://wallbase.cc/random" &>/dev/null
}

normal.extract2() {
code=$(cat $1 | grep jpg | grep "<img" | cut -d"'" -f2)
for i in $code; do
if [[ "$i" = *${categoria}* ]]; then
echo "URL: $i"
echo $i >> $wget_list
return 0
else
echo "URL: $i [Not downloading...]"
return 1
fi
done
}
normal.extract2l() {
code=$(cat $1 | grep jpg | grep "<img" | cut -d"'" -f2)
for i in $code; do
echo "URL: $i"
echo $i >> $wget_list
return 0

done
}


normal.extract() {
echo "WallBase Downloader [NORMAL] running.."
while true; do
normal.reload
wallpapers=$(cat $file1 | grep "<a href=" | grep wallpaper | cut -d"=" -f2 | cut -d"\"" -f2 | grep wallbase) #
for i in $wallpapers; do
[[ "$cant" = "$walls" ]] && break 2
wget -O "$file2" "$i" &>/dev/null
normal.extract2 $file2
result=$?
if [[ $result = 0 ]]; then
cant=$(expr $cant + 1)
fi
done
done
}

download_list() {
echo "Downloading list of files.."
for i in $(cat $wget_list); do # Leemos la lista
if [[ ! -e "$(basename $i)" ]]; then
wget -O "./$(basename $i)" $i # Bajamos el archivo si existe
else
echo "$i already downloaded.." # sino tiramos el "error"
fi
done
}

menu2.1() {
echo -en "Inserte la cantidad de wallpapers a bajar: "
read cantidad
[[ -z $cantidad ]] && exit 2
walls=$cantidad
if ! [[ "$walls" =~ ^[0-9]+$ ]] ; then
echo "Introduzca un numero positivo y sin coma.."
               exit 3
fi
normal.extract
}

menu2.2() {
echo -en "Inserte la url: "
read url
[[ -z $url ]] && exit 2
unset categoria
wget -O $file1 $url
result=$?
[[ $result != 0 ]] && exit 3
normal.extract2 $file1
}
menu2.3() {
echo "Que desea buscar?"
echo -en ">> "
read search
[[ -z $search ]] && exit 2
echo "Bajando la pagina de busquedas.."
wget -O "$file1" "http://wallbase.cc/search/_${search}_" &> /dev/null
echo "Cuantos resultados desea bajar?"
echo -en ">> "
read cantidad
if ! [[ "$cantidad" =~ ^[0-9]+$ ]] ; then
echo "Introduzca un numero positivo y sin coma.."
               exit 3
fi
cant=0
wallpapers=$(cat $file1 | grep "<a href=" | grep wallpaper | cut -d"=" -f2 | cut -d"\"" -f2 | grep wallbase) #
for i in $wallpapers; do
[[ "$cant" = "$cantidad" ]] && break 2
wget -O "$file2" "$i" &>/dev/null
normal.extract2l $file2
cant=$(expr $cant + 1)
done
return 0
}
menu() {
echo "WallBase downloader -> 0.3"
echo "Vamos a un directorio.."
if [[ "$1" = "-d" ]]; then
echo -en "Inserte el directorio: "
read path
cd $path
result=$?
if [[ $result != 0 ]]; then
echo "Hubo un error, compruebe que existe el directorio"
exit 3
fi
fi
echo "Que desea?"
echo "1- Bajar wallpapers al azar"
echo "2- Bajar un wallpaper especifico"
echo "3- Buscar wallpapers en Wallbase"
echo -en ">> "
read opt
[[ -z $opt ]] && exit 1
case $opt in
1)
menu2.1
;;
2)
menu2.2
;;
3)
menu2.3
;;
*)
echo "Opcion incorrecta"
exit 1
;;
esac
}
menu $@
download_list

