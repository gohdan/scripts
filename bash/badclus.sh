#!/bin/sh
   
#http://forum.ru-board.com/topic.cgi?forum=84&topic=1723

ntfsinfo -i 8 <partition>
# где -i 8 указывает на служебный файл $BadClus, хранящий информацию о плохих кластерах
# <partition> = /dev/hda1, если диск ide, либо /dev/sda1, если диск sata
# как определить точно, с каким диском работать, я не знаю. я в юниксе не силён совсем. проще отключить на время все лишние винты. либо скажите команду, кто знает.
# записываем на бумажку строчку после Dumping attribute $Data (0x80)... в самом конце Allocated size: ... 10-значное число должно быть

ntfstruncate <partition> 8 0x80 '$Bad' 0
#   обнуляем атрибут 'Bad'
ntfstruncate <partition> 8 0x80 '$Bad' <ntfs_size>, <ntfs_size> из п.4
#   восстанавливаем атрибут 'Bad'
#грузимся в windows и запускаем проверку диска, т.к. ntfstruncate оставляет после себя ошибки.

