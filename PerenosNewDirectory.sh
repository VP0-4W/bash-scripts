#!/bin/bash
#Автор: pochinkov
#Дата создания скрипта: October 8,2021
#Описание: Скрипт предназначен для переноса созданных директорий с /var/stalker_storage/storage/ на SSD
#---------------------------------------------------------------------------------------
#Создаём переменную для текстового файла, в котором будут храниться каталоги
katalog=/var/stalker_storage/storage/Katalogi.txt
#Создаём текстовый файл
touch $katalog
#Выводим в файл все созданные каталоги в директории /var/stalker_storage/storage/
find /var/stalker_storage/storage/ -type d > $katalog
#Удаляем из полученного файла лишние символы, тестовую папку и первую пустую строку
sed -i -e '1d' -e '/test_test/d' -e 's/\/var\/stalker_storage\/storage\///g' $katalog
#---------------------------------------------------------------------------------------
#Записываем дату в переменную
date=$(date "+%d.%m.%Y-%H:%M")
#Создаём переменную для текстового файла, в котором будут храниться логи
logirovanie=/home/pochinkov/Loging/log-running-script-$date.txt
#Создаем файл для сохранения логов
touch $logirovanie
#---------------------------------------------------------------------------------------
#Проверям наличие наименований новых каталогов на $katalog
if [ -s $katalog ]
#Файл содержит данные
then
        #Добавляем копию наименований директорий в лог-файл
        find /var/stalker_storage/storage/ -type d > $logirovanie
        #Редактируем наименования и убираем исключения с лишними символами
        sed -i -e '1d' -e '/test_test/d' -e 's/\/var\/stalker_storage\/storage\///g' $logirovanie
        #Запускаем цикл на считывание наименований директорий из текстововго файла и перенос на SSD
        cat $katalog | while read var
        do
                echo -e "Перенос директории с /var/stalker_storage/storage на SSD." >> $logirovanie
                mv /var/stalker_storage/storage/$var /mnt/SSD/
                echo -e "mv /var/stalker_storage/storage/$var /mnt/SSD" >> $logirovanie
                echo -e "Создание символьной ссылки с /var/stalker_storage/storage на SSD. \n" >> $logirovanie
                ln -s /mnt/SSD/$var /var/stalker_storage/storage/
                echo -e "ln -s /mnt/SSD/$var /var/stalker_storage/storage/" >> $logirovanie
        done
        #Удаляем каталог в котором хранились наименования директорий, для того чтобы при повторном запуске скрипта не подбирались старые данные
        echo "rm $katalog" >> $logirovanie
        rm $katalog
        echo "Выставление прав на скачанные файлы 777 в папке 1new" >> $logirovanie
        chmod 777 /mnt/SSD/1new/*
        #Отправка отчета на почтовый ящик
        mail -s "TVSTORE2 | Transferring new directories from storage to SSD" pochinkov@redcom.ru < $logirovanie
else
        #Файл не содержит данные о имеющихся категориях.
        #Запись об отсутствии директорий на перенос в лог файл
        echo  -e "Новых директорий на /var/stalker_storage/storage не найдено.\n" >> $logirovanie
        #Удаляем каталог в котором нет наименований для переноса директорий
        echo "rm $katalog" >> $logirovanie
        rm $katalog
        #Отправка отчета на почтовый ящикПеренос новых каталогов с storage на SSD
        mail -s "TVSTORE2 | Transferring new directories from storage to SSD" pochinkov@redcom.ru < $logirovanie
fi
#---------------------------------------------------------------------------------------
#Конец скрипта
