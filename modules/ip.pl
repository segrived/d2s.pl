# Модуль возвращает текущий внутрисетевой IP-адрес
# Версия 0.1
# Автор: segrived, 2012
# Требуемое ПО: ip

# Специфичные настройки модуля:
#   interface - Сетевой интерфейс.
#   |--- По умолчанию: eth0

my $interface = config::get("mod.ip.interface", "eth0");

sub d2sf_get_ip {
    my $out = `ip addr list $interface`;
    $out =~ m/inet\s+(?<ip>[\d.]+)\//;
    return $+{"ip"}
}