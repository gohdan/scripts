#!/usr/bin/perl

# via http://searchengines.guru/showthread.php?t=136923

# указываем путь к HTML-файлу
$file = "file.html";

# читаем HTML-файл и пишем все в массив
open (FILE,"<$file"); @html=<FILE>; close(FILE);

# преобразуем массив строк HTML-страницы в строку
$html = join("",@html);

# выбираем все ссылки со страницы
@links= $html =~ m/<A[^>]+?HREF\s*=\s*["']?([^'" >]+?)[ '"].*?>/sig;

# выводим полученные ссылки, каждая - с новой строки
foreach (@links) {
print $_ . "\n";
}

#@anchors= $html =~ m/<A[^>]+?HREF\s*=\s*["']?[^'" >]+?[ '"].*?>([^<]+)/sig;
#foreach (@anchors) {
#print $_ . "\n";
#}


