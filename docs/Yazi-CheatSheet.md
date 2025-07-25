# Yazi CheatSheet - Полный справочник

Yazi - современный файловый менеджер для терминала, написанный на Rust. Быстрый, мощный и настраиваемый.

## Установка и запуск

```bash
# Установка через Homebrew (macOS)
brew install yazi

# Установка дополнительных инструментов для предпросмотра
brew install ffmpegthumbnailer unar jq poppler fd ripgrep fzf zoxide

# Запуск
yazi
```

## Навигация

### Основные перемещения

| Клавиша     | Действие                           |
| ----------- | ---------------------------------- |
| `h` или `←` | Переход в родительскую директорию  |
| `l` или `→` | Вход в директорию / открытие файла |
| `j` или `↓` | Перемещение вниз                   |
| `k` или `↑` | Перемещение вверх                  |
| `g`         | Переход в начало списка            |
| `G`         | Переход в конец списка             |
| `{`         | Переход к предыдущему sibling      |
| `}`         | Переход к следующему sibling       |

### Прыжки по страницам

| Клавиша                | Действие       |
| ---------------------- | -------------- |
| `Page Down` / `Ctrl+d` | Страница вниз  |
| `Page Up` / `Ctrl+u`   | Страница вверх |
| `Ctrl+f`               | Прыжок вперед  |
| `Ctrl+b`               | Прыжок назад   |

### Быстрые переходы

| Клавиша | Действие                      |
| ------- | ----------------------------- |
| `~`     | Переход в домашнюю директорию |
| `/`     | Переход в корневую директорию |
| `cd`    | Изменение рабочей директории  |
| `z`     | Переход с помощью zoxide      |
| `Z`     | Интерактивный выбор с zoxide  |

## Выделение и операции с файлами

### Выделение

| Клавиша  | Действие                             |
| -------- | ------------------------------------ |
| `Space`  | Переключить выделение файла          |
| `v`      | Инвертировать выделение в директории |
| `V`      | Выделить все файлы                   |
| `Ctrl+a` | Выделить все                         |
| `Ctrl+r` | Отменить выделение всех              |
| `o`      | Выделить только текущий файл         |

### Операции с файлами

| Клавиша | Действие                        |
| ------- | ------------------------------- |
| `y`     | Копировать выделенные файлы     |
| `x`     | Вырезать выделенные файлы       |
| `p`     | Вставить файлы                  |
| `P`     | Вставить файлы (перезаписывать) |
| `d`     | Удалить файлы в корзину         |
| `D`     | Удалить файлы навсегда          |
| `r`     | Переименовать файл              |
| `a`     | Создать файл                    |
| `A`     | Создать директорию              |

### Операции над выделенными файлами

| Клавиша | Действие                          |
| ------- | --------------------------------- |
| `;`     | Выполнить команду над выделенными |
| `:`     | Выполнить shell команду           |
| `!`     | Выполнить команду в фоне          |

## Поиск

| Клавиша | Действие                            |
| ------- | ----------------------------------- |
| `/`     | Поиск вперед                        |
| `?`     | Поиск назад                         |
| `n`     | Следующий результат поиска          |
| `N`     | Предыдущий результат поиска         |
| `f`     | Поиск по имени в текущей директории |
| `F`     | Поиск по содержимому                |

### Фильтрация

| Клавиша  | Действие                 |
| -------- | ------------------------ |
| `s`      | Интерактивная сортировка |
| `S`      | Настройки сортировки     |
| `Ctrl+s` | Отменить поиск/фильтр    |

## Просмотр файлов

### Предпросмотр

| Клавиша | Действие                       |
| ------- | ------------------------------ |
| `i`     | Просмотр информации о файле    |
| `I`     | Расширенная информация         |
| `Enter` | Открыть файл                   |
| `o`     | Открыть с помощью...           |
| `O`     | Интерактивный выбор приложения |

### Навигация в предпросмотре

| Клавиша | Действие                      |
| ------- | ----------------------------- |
| `u`     | Прокрутка предпросмотра вверх |
| `e`     | Прокрутка предпросмотра вниз  |
| `H`     | Скрыть/показать предпросмотр  |

## Вкладки и панели

### Управление вкладками

| Клавиша | Действие                           |
| ------- | ---------------------------------- |
| `t`     | Новая вкладка                      |
| `T`     | Новая вкладка в текущей директории |
| `1-9`   | Переключение на вкладку по номеру  |
| `[`     | Предыдущая вкладка                 |
| `]`     | Следующая вкладка                  |
| `{`     | Переместить вкладку влево          |
| `}`     | Переместить вкладку вправо         |

### Закрытие

| Клавиша | Действие                |
| ------- | ----------------------- |
| `q`     | Закрыть текущую вкладку |
| `Q`     | Выйти из yazi           |

## Архивы

| Клавиша | Действие                         |
| ------- | -------------------------------- |
| `Enter` | Войти в архив (как в директорию) |
| `e`     | Извлечь архив                    |
| `E`     | Извлечь архив в...               |

## Символические ссылки

| Клавиша | Действие                     |
| ------- | ---------------------------- |
| `l`     | Создать символическую ссылку |
| `L`     | Создать жесткую ссылку       |

## Права доступа

| Клавиша | Действие               |
| ------- | ---------------------- |
| `c`     | Изменить права доступа |
| `C`     | Изменить владельца     |

## Настройки и помощь

| Клавиша | Действие                   |
| ------- | -------------------------- |
| `~`     | Открыть настройки          |
| `g?`    | Помощь по горячим клавишам |
| `?`     | Общая справка              |

## Полезные команды из интеграции

### Функция yy() из конфигурации zsh

```bash
# Запуск yazi с изменением директории при выходе
yy
```

После выхода из yazi shell автоматически перейдет в последнюю открытую директорию.

## Дополнительные возможности

### Bulk операции

- Выделите несколько файлов с помощью `Space`
- Используйте любую операцию (копирование, перемещение, удаление)
- Операция применится ко всем выделенным файлам

### Плагины и предпросмотр

Yazi поддерживает предпросмотр для множества типов файлов:

- **Изображения**: превью в терминале
- **Видео**: миниатюры (требует ffmpegthumbnailer)
- **PDF**: первая страница (требует poppler)
- **Архивы**: содержимое (требует unar)
- **Код**: подсветка синтаксиса (требует bat)
- **JSON**: форматированный вывод (требует jq)

### Конфигурация

Файлы конфигурации располагаются в:

- **macOS**: `~/.config/yazi/`
- **Основной файл**: `yazi.toml`
- **Горячие клавиши**: `keymap.toml`
- **Темы**: `theme.toml`

### Полезные алиасы

```bash
# Быстрый запуск с переходом в директорию
alias y='yy'

# Yazi с sudo правами
alias sy='sudo yazi'

# Открыть текущую директорию в yazi
alias .='yazi .'
```

## Советы по продуктивности

1. **Используйте выделение**: выделяйте несколько файлов для bulk операций
2. **Изучите поиск**: `/` для быстрого поиска в текущей директории
3. **Вкладки**: работайте с несколькими директориями одновременно
4. **Предпросмотр**: включите предпросмотр для быстрого просмотра содержимого
5. **Интеграция с shell**: используйте функцию `yy()` для изменения директории

## Команды терминала

```bash
# Открыть конкретную директорию
yazi /path/to/directory

# Открыть файл для редактирования
yazi --choose-file

# Выбрать директорию
yazi --choose-dir

# Показать версию
yazi --version

# Показать помощь
yazi --help
```

## Интеграция с другими инструментами

### FZF

Можно использовать с fzf для еще более быстрой навигации:

```bash
# Найти файл и открыть в yazi
yazi "$(fd . | fzf)"
```

### Ripgrep

Поиск по содержимому файлов:

```bash
# Найти файлы с определенным содержимым
rg "pattern" | yazi
```

Yazi - это мощный инструмент, который значительно упрощает работу с файловой системой в терминале. Потратьте время на изучение горячих клавиш - это сэкономит много времени в долгосрочной перспективе!
