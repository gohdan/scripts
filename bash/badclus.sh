#!/bin/sh
   
#http://forum.ru-board.com/topic.cgi?forum=84&topic=1723

ntfsinfo -i 8 <partition>
# ��� -i 8 ��������� �� ��������� ���� $BadClus, �������� ���������� � ������ ���������
# <partition> = /dev/hda1, ���� ���� ide, ���� /dev/sda1, ���� ���� sata
# ��� ���������� �����, � ����� ������ ��������, � �� ����. � � ������ �� ���� ������. ����� ��������� �� ����� ��� ������ �����. ���� ������� �������, ��� �����.
# ���������� �� ������� ������� ����� Dumping attribute $Data (0x80)... � ����� ����� Allocated size: ... 10-������� ����� ������ ����

ntfstruncate <partition> 8 0x80 '$Bad' 0
#   �������� ������� 'Bad'
ntfstruncate <partition> 8 0x80 '$Bad' <ntfs_size>, <ntfs_size> �� �.4
#   ��������������� ������� 'Bad'
#�������� � windows � ��������� �������� �����, �.�. ntfstruncate ��������� ����� ���� ������.

