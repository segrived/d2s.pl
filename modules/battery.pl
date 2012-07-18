# Модуль возвращает уровень зарядки батареи
# Версия 0.1
# Автор: segrived, 2012
# Требуемое ПО: acpi

my $cdef = config::get("colors.default");
my $cdsb = config::get("colors.disabled");

sub d2sf_get_battery {
    `acpi` =~ m/Battery (?:[\d]*)\: (?<status>\S+), (?<percent>\d+)%/;
    my($status, $perc) = ($+{"status"}, $+{"percent"});
    my $color = ($status eq "Charging" || $status eq "Full") ? $cdef : $cdsb;
    return ct($color, $+{"percent"}) . ct($cdsb, "%");
}

1;