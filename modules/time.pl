# Модуль возвращает текущее время
# Версия 0.1.1
# Автор: segrived, 2012

# Специфичные настройки модуля:
#   format - Формат вывода времени.
#   |--- По умолчанию: %H:%M

use POSIX qw(strftime);

my $format = config::get("mod.time.format", "%H:%M");

sub d2sf_get_time {
    return POSIX::strftime($format, localtime);
}

1;