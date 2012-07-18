# Модуль возвращает количество занятой оперативной памяти
# Версия 0.2
# Автор: segrived, 2012

# Специфичные настройки модуля:
#   add_cache - Определяет, включать ли в результат память занимаемую буфером / кешем.
#   |--- По умолчанию: false (0)
#   percent_view - Отображать ли свободную память в процентном отношении
#   |--- По умолчанию: false (0)

my $add_cache = config::get("mod.memory.add_cache", 0);
my $percent_view = config::get("mod.memory.percent_view", 0);
my $cdsb = config::get("colors.disabled");

sub d2sf_get_memory {
    my ($total, $free, $re) = (0, 0, qr/:\s+?(\d+)/);
    open my $ram_fh, '<', '/proc/meminfo';
    while (defined(my $rl = <$ram_fh>)) {
        $total = int $1 / 1024 if $. == 1 and $rl =~ /$re/o;
        $free = int $1 / 1024 if $. == 2 and $rl =~ /$re/o;
        $free += int $1 / 1024 if !$add_cache and $. ~~ [3, 4] and $rl =~ /$re/o;
        last if $. == 4;
    }
    my ($used, $res) = ($total - $free, "");
    if ($percent_view) {
        $res = int(($used / $total) * 100) . ct($cdsb, "%");
    } else {
        $res = $used . ct($cdsb, "MB");
    }
    return $res;
}

1;