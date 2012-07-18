# Модуль возвращает текущую дату
# Версия 0.1
# Автор: segrived, 2012

# Специфичные настройки модуля:
#   format - Формат вывода даты.
#   |--- По умолчанию: %Y-%m-%d

use POSIX qw(strftime);

sub d2sf_get_date {
    my $format = config::get("mod.date.format", "%Y-%m-%d");
    return POSIX::strftime($format, localtime);
}

1;