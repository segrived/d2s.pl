# Модуль возвращает количество новых писем
# Версия 0.1
# Автор: segrived, 2012
# Требуемые Perl модули: LWP::UserAgent

# Специфичные настройки модуля:
#   has_new_messages_color - Цвет, которым будет выделено количество новых сообщений, если их больше нуля.
#   |--- По умолчанию: colors.default
#   login - Логин для доступа к почте Gmail.
#   password - Пароль для доступа к почте Gmail.

use LWP::UserAgent qw( );

my $cdef = config::get("colors.default");
my $cdsb = config::get("colors.disabled");
my $na_text = config::get("main.na_text");

my $nmc = config::get("mod.gmail.has_new_messages_color", $cdef);
my $login = config::get("mod.gmail.login");
my $password = config::get("mod.gmail.password");

sub d2sf_get_gmail {
    my $url = "https://${login}:${password}\@mail.google.com/mail/feed/atom";
    my $ua = LWP::UserAgent->new;
    my $resp = $ua->get($url)->decoded_content;
    my $count = int $1 if $resp =~ m/<fullcount>(?<count>\d+)<\/fullcount>/;
    my $color = (defined $+{"count"}) ? (($count == 0) ? $cdef : $nmc): $cdsb;
    return ct($color, (defined $+{"count"}) ? $count : $na_text);
}

1;