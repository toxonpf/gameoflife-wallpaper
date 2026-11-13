# Conway's Game of Life — живые обои для KDE Plasma

Настраиваемые живые обои на основе «Игры в жизнь» Конвея для KDE Plasma 6. Симуляция поддерживает единое полотно на нескольких мониторах, случайное появление фигур, интерактивное рисование и плавные визуальные эффекты.

## Возможности

- скорость поколений, размер клеток, начальная плотность и цвета;
- объединение мониторов в одно виртуальное полотно;
- смешанное появление одиночных клеток, облаков, глайдеров, кораблей и осцилляторов;
- фиксированный или случайный интервал появления;
- формы клеток: квадрат, скруглённый квадрат, круг и жидкие кляксы;
- жидкий режим с каплями, перемычками, деформацией и плавным ростом/исчезновением;
- отдельные анимации рождения и исчезновения: fade, flash, pulse, wave, pop, ripple, sparks и dissolve;
- рисование левой кнопкой по свободному месту рабочего стола и стирание правой кнопкой;
- кнопки случайного заполнения, очистки и восстановления параметров по умолчанию;
- сохранение параметров через стандартную панель настроек Plasma.

## Требования

- KDE Plasma 6;
- Qt 6 и Wayland или X11;
- установленный `kpackagetool6`.

## Установка

Из корня проекта выполните:

```bash
./install.sh
```

Скрипт устанавливает wallpaper-пакет в `~/.local/share/plasma/wallpapers/` и пользовательское переопределение desktop containment в `~/.local/share/plasma/plasmoids/`. После установки перезапускается `plasma-plasmashell.service`, чтобы Plasma загрузила изменения.

Затем откройте настройки рабочего стола и выберите тип обоев `Conway's Game of Life`. Для общего полотна на мониторах включите `Combine all monitors into one continuous field` и, при необходимости, `Использовать на всех экранах`.

## Структура

```text
plasma-wallpaper/org.kde.plasma.gameoflife/  пакет живых обоев
  contents/config/main.xml                  сохраняемые настройки
  contents/ui/config.qml                     панель настроек
  contents/ui/main.qml                       QML-рендерер и таймеры
  contents/ui/code/life.js                   симуляция и Canvas-отрисовка
plasmoid/org.kde.desktopcontainment/         передача кликов по пустому рабочему столу
install.sh                                   установка локальных пакетов
```

## Проверка перед коммитом

```bash
/usr/lib/qt6/bin/qmllint -I /usr/lib/qt6/qml \
  plasma-wallpaper/org.kde.plasma.gameoflife/contents/ui/main.qml \
  plasma-wallpaper/org.kde.plasma.gameoflife/contents/ui/config.qml

sed '/^\.pragma library$/d' \
  plasma-wallpaper/org.kde.plasma.gameoflife/contents/ui/code/life.js | node --check
```

`qmllint` может показывать предупреждения о незарегистрированных типах desktop containment; они относятся к системным QML-модулям KDE и не являются синтаксическими ошибками проекта.

## Лицензия

Исходный шаблон Plasma wallpaper содержит лицензию LGPLv2+. Изменения проекта распространяются на тех же условиях, если это требуется лицензией исходных файлов.
