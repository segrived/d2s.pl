# Модуль возвращает уровень яркости
# Версия 0.1
# Автор: segrived, 2012

# Специфичные настройки модуля:
#   dev - Устройство (ls /sys/class/backlight)
#   |--- По умолчанию: acpi_video0

my $dev = config::get("mod.brightness.dev", "acpi_video0");

sub d2sf_get_brightness {
    open F, "< /sys/class/backlight/$dev/brightness";
    chomp(my $brightness =<F>);
    return $brightness;
}

1;