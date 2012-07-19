# Модуль возвращает количество новых писем, используя IMAP
# Версия 0.1
# Автор: segrived, 2012
# Требуемые Perl модули: Mail::IMAPClient

# Специфичные настройки модуля:
#   has_new_messages_color - Цвет, которым будет выделено количество новых сообщений, если их больше нуля.
#   |--- По умолчанию: colors.default
#   login - Логин для доступа к почте Gmail.
#   password - Пароль для доступа к почте Gmail.

use Mail::IMAPClient;

my $cdef = config::get("colors.default");
my $cdsb = config::get("colors.disabled");
my $na_text = config::get("main.na_text");

my $nmc = config::get("mod.imap.has_new_messages_color", $cdef);
my $login = config::get("mod.imap.login");
my $password = config::get("mod.imap.password");
my $imap_use_ssl = config::get("mod.imap.use_ssl", 1);
my $imap_server = config::get("mod.imap.server", "imap.gmail.com");
my $imap_port = config::get("mod.imap.port", 993);
my $imap_folder = config::get("mod.imap.folder", "INBOX");

sub d2sf_get_gmail {
    my $client;
    if($imap_use_ssl) {
        my $socket = IO::Socket::SSL->new(
            PeerAddr => $imap_server,
            PeerPort => $imap_port
        );
        $client = Mail::IMAPClient->new(
            'Socket' => $socket,
            'User' => $login,
            'Password' => $password
        );
    } else {
        $client = Mail::IMAPClient->new(
            'Server' => $imap_server,
            'User' => $login,
            'Password' => $password
        );
    }
    my $result;
    if ($client->IsAuthenticated()) {
        $result = $client->select("INBOX")->unseen_count || 0;
    } else {
        $result = "#";
    }
    return $result;
    
    #my $url = "https://${login}:${password}\@mail.google.com/mail/feed/atom";
    #my $ua = LWP::UserAgent->new;
    #my $resp = $ua->get($url)->decoded_content;
    #my $count = int $1 if $resp =~ m/<fullcount>(?<count>\d+)<\/fullcount>/;
    #my $color = (defined $+{"count"}) ? (($count == 0) ? $cdef : $nmc): $cdsb;
    #return ct($color, (defined $+{"count"}) ? $count : $na_text);
}

1;