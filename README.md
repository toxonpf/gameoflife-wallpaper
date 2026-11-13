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

---

# Conway's Game of Life — configurable KDE Plasma wallpaper

Configurable Conway's Game of Life live wallpaper for KDE Plasma 6. The simulation supports a continuous canvas across multiple monitors, random pattern spawning, mouse interaction, fluid cells, and independent birth and death effects.

## Features

- configurable generation speed, cell size, initial density, and colors;
- one continuous simulation canvas across multiple monitors;
- mixed spawning of single cells, clouds, gliders, spaceships, and oscillators;
- fixed or random spawning intervals;
- square, rounded square, circle, and fluid blob cell shapes;
- fluid mode with droplets, bridges, deformation, and smooth growth/disappearance;
- independent birth and death animations: fade, flash, pulse, wave, pop, ripple, sparks, and dissolve;
- left-click drawing and right-click erasing on empty desktop space;
- random fill, clear field, and restore-default buttons;
- settings saved through the standard Plasma wallpaper configuration dialog.

## Requirements

- KDE Plasma 6;
- Qt 6 on Wayland or X11;
- `kpackagetool6`.

## Installation

From the project root, run:

```bash
./install.sh
```

The script installs the wallpaper package into `~/.local/share/plasma/wallpapers/` and the user-local desktop containment override into `~/.local/share/plasma/plasmoids/`. It then restarts `plasma-plasmashell.service` when available so Plasma loads the changes.

Open the desktop wallpaper settings and select `Conway's Game of Life`. To use one canvas across monitors, enable `Combine all monitors into one continuous field` and, if needed, `Use on all screens`.

## Project structure

```text
plasma-wallpaper/org.kde.plasma.gameoflife/  wallpaper package
  contents/config/main.xml                  persisted settings
  contents/ui/config.qml                     configuration UI
  contents/ui/main.qml                       QML renderer and timers
  contents/ui/code/life.js                   simulation and Canvas renderer
plasmoid/org.kde.desktopcontainment/         forwards clicks on empty desktop space
install.sh                                   local installation script
```

## Validation

```bash
/usr/lib/qt6/bin/qmllint -I /usr/lib/qt6/qml \
  plasma-wallpaper/org.kde.plasma.gameoflife/contents/ui/main.qml \
  plasma-wallpaper/org.kde.plasma.gameoflife/contents/ui/config.qml

sed '/^\.pragma library$/d' \
  plasma-wallpaper/org.kde.plasma.gameoflife/contents/ui/code/life.js | node --check
```

`qmllint` may report warnings about unresolved desktop-containment types. These types are provided by the KDE runtime and are not syntax errors in this project.

## License

The original Plasma wallpaper template is licensed under LGPLv2+. Project changes remain under the applicable license terms of the original files.
