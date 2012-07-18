# Модуль возрашает список доступных рабочих столов
# Версия 0.1
# Автор: segrived, 2012
# Требуемое ПО: wmctrl

# Специфичные настройки модуля:
#   current_desk_color - Цвет, которым будет выделен текущий робочий стол.
#   |--- По умолчанию: colors.default
#   padding_between_desktops - Расстояние между номерами рабочих столов.
#   |--- По умолчанию: 5

my $current_desk_color = config::get("mod.desktops.current_desktop_color", "green");
my $desk_padding = config::get("mod.desktops.padding_between_desktops", 5);
my $cdef = config::get("colors.default");

sub d2sf_get_desktops {
    my $out = `wmctrl -d`;
    my $count = $out =~ tr/\n//;
    $out =~ m/(?<cur>\d+)\s+\*/;
    my $current = $+{"cur"} + 1;
    my $result = "";
    for(my $i = 1; $i <= $count; $i++) {
        my $color = ($i == $current) ? $current_desk_color : $cdef;
        $result .= ct($color, $i);
        $result .= "^p($desk_padding)" unless $i == $count;
    }
    return $result;
}

1;