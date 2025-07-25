# TMUX - Документация и руководство пользователя 🖥️

## Что такое TMUX

**TMUX** (Terminal Multiplexer) — это мощный инструмент для управления несколькими терминальными сессиями в одном окне. Он позволяет создавать, переключаться между сессиями, разделять окна на панели и работать в фоновом режиме.

### 🎯 Основные преимущества:

- **Сессии выживают при отключении** - работа продолжается даже после закрытия терминала
- **Разделение экрана** - множество панелей в одном окне
- **Удаленная работа** - продолжение работы через SSH
- **Организация проектов** - отдельные сессии для разных задач

## Конфигурация в вашем dotfiles

Ваша настройка tmux — это продвинутая конфигурация с множеством улучшений и плагинов.

### 🔧 Основные настройки

```bash
# Изменен префикс с Ctrl+b на Ctrl+a (как в screen)
set -g prefix C-a

# 256 цветов и true color поддержка
set -g default-terminal "screen-256color"
set -ga terminal-overrides ",xterm-256color:Tc"

# Нумерация окон и панелей начинается с 1
set -g base-index 1
setw -g pane-base-index 1

# Поддержка мыши включена
set -g mouse on
```

## 🎹 Биндинги клавиш

### Основной префикс: `Ctrl+A`

### 📋 Управление конфигурацией

| Комбинация          | Действие                        |
| ------------------- | ------------------------------- |
| `Ctrl+A` + `Ctrl+E` | Редактировать конфигурацию tmux |
| `Ctrl+A` + `Ctrl+R` | Перезагрузить конфигурацию      |

### 🪟 Управление окнами (Windows)

| Комбинация          | Действие                                  |
| ------------------- | ----------------------------------------- |
| `Ctrl+A` + `c`      | Создать новое окно (в текущей директории) |
| `Ctrl+A` + `r`      | Переименовать текущее окно                |
| `Ctrl+A` + `R`      | Переименовать сессию                      |
| `Ctrl+A` + `Ctrl+[` | Предыдущее окно                           |
| `Ctrl+A` + `Ctrl+]` | Следующее окно                            |
| `Ctrl+A` + `Tab`    | Последнее активное окно                   |
| `Ctrl+A` + `X`      | Закрыть окно                              |
| `Ctrl+A` + `Ctrl+X` | Закрыть все остальные окна                |

### 🔲 Управление панелями (Panes)

| Комбинация          | Действие                          |
| ------------------- | --------------------------------- |
| `Ctrl+A` + `\|`     | Разделить вертикально             |
| `Ctrl+A` + `_`      | Разделить горизонтально           |
| `Ctrl+A` + `[`      | Выбрать предыдущую панель         |
| `Ctrl+A` + `]`      | Выбрать следующую панель          |
| `Ctrl+A` + `+`      | Увеличить/уменьшить панель (zoom) |
| `Ctrl+A` + `x`      | Закрыть панель                    |
| `Ctrl+A` + `Ctrl+O` | Поменять панели местами           |

### 🔄 Управление сессиями

| Комбинация     | Действие                            |
| -------------- | ----------------------------------- |
| `Ctrl+A` + `d` | Отсоединиться от сессии             |
| `Ctrl+A` + `D` | Отсоединить других клиентов         |
| `Ctrl+A` + `Q` | Завершить сессию (с подтверждением) |

### 📋 Копирование и вставка

| Комбинация          | Действие                  |
| ------------------- | ------------------------- |
| `Alt+Up`            | Войти в режим копирования |
| `Ctrl+A` + `p`      | Вставить из буфера        |
| `Ctrl+A` + `Ctrl+P` | Выбрать буфер для вставки |

#### В режиме копирования (vi-style):

| Клавиша       | Действие                    |
| ------------- | --------------------------- |
| `Space`       | Начать выделение            |
| `Enter` / `y` | Скопировать выделенное      |
| `Y`           | Скопировать всю строку      |
| `D`           | Скопировать до конца строки |
| `A`           | Добавить к выделению        |
| `Esc`         | Выйти из режима копирования |

### 🖱️ Поддержка мыши

- **Клик** - выбор панели
- **Перетаскивание** - выделение текста
- **Колесо мыши** - прокрутка (по 2 строки)
- **Двойной клик** - выделение слова

### 📊 Мониторинг

| Комбинация     | Действие                                 |
| -------------- | ---------------------------------------- |
| `Ctrl+A` + `m` | Включить/выключить мониторинг активности |
| `Ctrl+A` + `M` | Настроить мониторинг тишины              |

### 🎨 Интерфейс

| Комбинация          | Действие                                 |
| ------------------- | ---------------------------------------- |
| `Ctrl+A` + `Ctrl+S` | Скрыть/показать статус-бар               |
| `F12`               | Режим вложенных сессий (передача команд) |

## 🔌 Плагины

Ваша конфигурация использует **TPM** (Tmux Plugin Manager) и множество полезных плагинов:

### Основные плагины:

1. **tmux-battery** - индикатор заряда батареи
2. **tmux-prefix-highlight** - подсветка активного префикса
3. **tmux-online-status** - индикатор подключения к интернету
4. **tmux-sidebar** - файловый браузер в боковой панели
5. **tmux-copycat** - улучшенный поиск и копирование
6. **tmux-open** - открытие файлов и URL
7. **tmux-plugin-sysstat** - системная статистика (CPU, память)
8. **tmux-colors-solarized** - тема Solarized

### Биндинги плагинов:

| Комбинация          | Действие (плагин)                  |
| ------------------- | ---------------------------------- |
| `Ctrl+A` + `t`      | Открыть файловый браузер (sidebar) |
| `Ctrl+A` + `T`      | Фокус на файловом браузере         |
| `Ctrl+A` + `/`      | Поиск по regex (copycat)           |
| `Ctrl+A` + `Ctrl+F` | Поиск файлов (copycat)             |
| `Ctrl+A` + `Ctrl+U` | Поиск URL (copycat)                |
| `Ctrl+A` + `o`      | Открыть выделенное (open)          |

## 🎨 Внешний вид и тема

### Цветовая схема:

- **Основной цвет**: Оранжевый (#166)
- **Вторичный**: Фиолетовый (#134)
- **Фон**: Черный
- **Статус-бар**: Вверху экрана

### Информация в статус-баре:

**Слева**: Название сессии  
**Справа**: CPU | Память | Загрузка | Пользователь@хост | Дата/время | Батарея | Онлайн-статус

### Индикаторы:

- 🔋 **Зеленый** - высокий заряд батареи / низкая нагрузка
- 🟡 **Желтый** - средние значения
- 🔴 **Красный** - критические значения
- 🟢 **●** - подключение к интернету
- 🔴 **●** - нет подключения

## 💡 Практические советы

### 🚀 Быстрый старт

#### 1. Создание и управление сессиями

```bash
# Создать новую сессию
tmux new-session -s project-name

# Подключиться к существующей
tmux attach -t project-name

# Список сессий
tmux list-sessions

# Использование алиасов из .aliases:
t          # Подключиться или создать новую
ta work    # Подключиться к сессии "work"
tc blog    # Создать сессию "blog"
tl         # Список сессий
mux        # Tmuxinator (для комплексных настроек)
```

#### 2. Организация рабочего пространства

**Типичная структура сессии:**

```
Сессия "development"
├── Окно 1: "editor" (vim/code)
├── Окно 2: "server"
│   ├── Панель 1: Веб-сервер
│   └── Панель 2: База данных
├── Окно 3: "monitoring"
│   ├── Панель 1: htop
│   ├── Панель 2: logs
│   └── Панель 3: git status
└── Окно 4: "testing"
```

#### 3. Рекомендуемые рабочие процессы

**Для веб-разработки:**

```bash
# Сессия проекта
tc myproject

# Окно 1: Редактор
Ctrl+A c  # создать окно
r         # переименовать в "editor"

# Окно 2: Сервер (разделить на панели)
Ctrl+A c
r         # переименовать в "server"
Ctrl+A |  # разделить вертикально
# В левой панели: npm start
# В правой панели: npm run db

# Окно 3: Git и мониторинг
Ctrl+A c
r         # переименовать в "git"
Ctrl+A _  # разделить горизонтально
# Верхняя панель: git status --porcelain | head -20
# Нижняя панель: tail -f logs/app.log
```

### 🛠️ Продвинутые техники

#### 1. Вложенные сессии (SSH)

При работе через SSH используйте `F12` для переключения режимов:

- **F12** - отключить локальные биндинги (передача команд на удаленный tmux)
- **F12** еще раз - включить локальные биндинги

#### 2. Копирование между панелями

```bash
# Выделить текст в одной панели
Alt+Up  # войти в режим копирования
Space   # начать выделение
Enter   # скопировать

# Переключиться на другую панель
Ctrl+A ]  # выбрать панель

# Вставить
Ctrl+A p
```

#### 3. Использование мыши

- **Прокрутка колесом** автоматически входит в режим копирования
- **Выделение мышью** копирует в буфер tmux
- **Средняя кнопка мыши** вставляет из буфера

#### 4. Мониторинг активности

```bash
# Включить мониторинг активности в окне
Ctrl+A m

# Настроить мониторинг тишины (например, 60 секунд)
Ctrl+A M
# Ввести: 60

# В статус-баре появятся индикаторы при изменениях
```

### 📝 Tmuxinator для комплексных проектов

Создайте файл `~/.tmuxinator/project.yml`:

```yaml
name: myproject
root: ~/projects/myproject

windows:
  - editor: vim
  - server:
      layout: even-horizontal
      panes:
        - npm run dev
        - npm run db
  - monitoring:
      layout: even-vertical
      panes:
        - htop
        - tail -f logs/app.log
  - git: git status
```

Запуск: `mux start myproject`

## 🔧 Настройка под себя

### Изменение биндингов

Отредактируйте `~/.tmux.conf`:

```bash
# Например, изменить разделение панелей
bind h split-window -h -c "#{pane_current_path}"
bind v split-window -v -c "#{pane_current_path}"
```

### Добавление плагинов

```bash
# В ~/.tmux.conf добавить:
set -g @plugin 'plugin-name'

# Перезагрузить конфигурацию:
Ctrl+A Ctrl+R

# Установить плагины:
Ctrl+A I
```

### Кастомизация статус-бара

```bash
# Добавить свои виджеты в status-right
set -g status-right "#{prefix_highlight} #(uptime | cut -d: -f4-) | %Y-%m-%d %H:%M"
```

## 🐛 Решение проблем

### Проблемы с цветами

```bash
# Проверить поддержку цветов
echo $TERM
tmux info | grep Tc

# Если проблемы, добавить в .zshrc:
export TERM=screen-256color
```

### Проблемы с копированием

```bash
# На macOS может потребоваться:
brew install reattach-to-user-namespace

# Настройка уже есть в конфигурации
```

### Восстановление сессий

```bash
# Сессии автоматически сохраняются
# Для восстановления после перезагрузки:
tmux attach  # или используйте алиас 't'
```

## 📚 Полезные команды

### Информационные

```bash
tmux info                    # Информация о tmux
tmux show-options -g         # Глобальные опции
tmux list-keys              # Все биндинги
tmux list-commands          # Все команды
```

### Управление из командной строки

```bash
tmux send-keys -t session:window 'command' Enter
tmux new-window -t session -n window-name
tmux kill-session -t session-name
```

## 🎯 Заключение

Ваша конфигурация tmux — это мощная и продуманная настройка для профессиональной работы в терминале. Она включает:

✅ **Эргономичные биндинги** - измененный префикс и логичные сочетания  
✅ **Визуальные улучшения** - красивая тема и информативный статус-бар  
✅ **Мониторинг системы** - CPU, память, батарея, сеть  
✅ **Улучшенное копирование** - vi-style навигация и умное копирование  
✅ **Поддержка плагинов** - расширяемость через TPM  
✅ **Вложенные сессии** - работа через SSH

Используйте эту документацию как справочник и не забывайте экспериментировать с настройками под свои потребности!

---

_Быстрая помощь: `Ctrl+A ?` покажет все доступные биндинги_
