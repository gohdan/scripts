#! /bin/bash
#
# Очень простая утилита для переименования файлов
#
#  Утилита "ren", автор Vladimir Lanin (lanin@csd2.nyu.edu),
#+ выполняет эти же действия много лучше.


ARGS=2
E_BADARGS=65
ONE=1                     # Единственное или множественное число (см. ниже).

if [ $# -ne "$ARGS" ]
then
  echo "Порядок использования: `basename $0` старый_шаблон новый_шаблон"
  # Например: "rn gif jpg", поменяет расширения всех файлов в текущем каталоге с gif на jpg.
  exit $E_BADARGS
fi

number=0                  # Количество переименованных файлов.


for filename in *$1*      # Проход по списку файлов в текущем каталоге.
do
   if [ -f "$filename" ]
   then
     fname=`basename $filename`            # Удалить путь к файлу из имени.
     n=`echo $fname | sed -e "s/$1/$2/"`   # Поменять старое имя на новое.
     mv $fname $n                          # Переименовать.
     let "number += 1"
   fi
done

if [ "$number" -eq "$ONE" ]                # Соблюдение правил грамматики.
then
 echo "$number файл переименован."
else
 echo "Переименовано файлов: $number."
fi

exit 0

