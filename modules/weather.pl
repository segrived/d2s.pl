# Модуль возвращает текущую погоду
# Версия 0.1
# Автор: segrived, 2012
# Требуемые Perl модули: LWP::UserAgent

# Специфичные настройки модуля:
#   city - Город.
#   |--- По умолчанию: London (lol)
#   scale - Шкала измерения (c - Цельсий, f - Фаренгейт).
#   |--- По умолчанию: c

use LWP::UserAgent qw( );

my $city = config::get("mod.weather.city", "London");
my $scale = config::get("mod.weather.scale", "c");
my $na_text = config::get("main.na_text");
my $cdsb = config::get("colors.disabled");

sub d2sf_get_weather {
    my $ua = LWP::UserAgent->new(timeout => 3);
    my $cont = $ua->get("http://www.google.com/ig/api?weather=${city}")->decoded_content;
    $cont =~ m/<current_conditions>.*<temp_$scale data="(?<t>\d+)"\/>.*<\/current_conditions>/;
    return $+{"t"} . ct($cdsb, (defined $+{"t"}) ? "°" : $na_text);
}

1;