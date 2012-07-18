# Модуль возвращает текущую громкость (ALSA)
# Версия 0.1
# Автор: segrived, 2012
# Требуемое ПО: amixer

# Специфичные настройки модуля:
#   device - Устройство вывода.
#   |--- По умолчанию: Master

my $dev = config::get("mod.volume.device", "Master");
my $cdef = config::get("colors.default");
my $cdsb = config::get("colors.disabled");

sub d2sf_get_volume {
    `amixer get $dev` =~ m/\[(?<level>\d+)\%\].*\[(?<muted>on|off)\]/;
    my ($level, $muted) = ($+{"level"}, $+{"muted"});
    my $label_color = ($muted eq "on") ? $cdef : $cdsb;
    return ct($label_color, $level) . ct($cdsb, "%");
}

1;