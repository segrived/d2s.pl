# Модуль возвращает текущий аптайм
# Версия 0.1
# Автор: segrived, 2012

sub d2sf_get_uptime {
    open F, "< /proc/uptime";
    my ($uptime, undef) = split / /, <F>;
    my $hours = int($uptime / 60 / 60);
    my $minutes = $uptime / 60 % 60;
    return sprintf("%02d:%02d", $hours, $minutes);
}

1;