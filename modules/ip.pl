# Модуль возвращает текущий внутрисетевой IP-адрес
# Версия 0.2
# Автор: segrived, 2012
# Требуемое ПО: ip или ifconfig

# Специфичные настройки модуля:
#   interface - Сетевой интерфейс.
#   |--- По умолчанию: eth0
#   use_ifconfig - Использовать ifconfig вместо ip для получения IP-адреса
#   |--- По умолчанию: false

my $iface = config::get("mod.ip.interface", "eth0");
my $useifc = config::get("mod.ip.use_ifconfig", 0);

sub d2sf_get_ip {
    $out = ($useifc) ? `ifconfig $iface` : `ip addr list $iface`;
    return $+{"ip"} if $out =~ m/inet\s+(?<ip>[\d.]+)/;
}

1;