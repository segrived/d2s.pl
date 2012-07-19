# Модуль возвращает количество новых писем, используя IMAP
# Версия 0.1
# Автор: segrived, 2012
# Требуемые Perl модули: IO::Socket::SSL (если используется SSL-подключение), Mail::IMAPClient

# Специфичные настройки модуля:
#   has_new_messages_color - Цвет, которым будет выделено количество новых сообщений, если их больше нуля.
#   |--- По умолчанию: colors.default
#   login - Логин для доступа к серверу IMAP
#   password - Пароль для доступа к серверу IMAP
#   use_ssl - Определяет, использовать ли SSL при подключении
#   |--- По умолчанию: True (1)
#   server - Адрес IMAP сервера
#   |--- По умолчанию: imap.gmail.com
#   port - Порт IMAP сервера
#   |--- По умолчанию: 993
#   folder - Проверяемая папка на сервере IMAP (чаще всего INBOX)
#   |--- По умолчанию: INBOX

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

sub d2sf_get_imap {
    my (%conf, $client, $result) = ((), "", "");
    $conf{'Server'} = $$imap_server;
    if($imap_use_ssl) {
        require IO::Socket::SSL;
        %prm = ('PeerAddr' => $imap_server, 'PeerPort' => $imap_port, 'Timeout'  => 2);
        $conf{'Socket'} = IO::Socket::SSL->new(%prm);
    }
    ($conf{'User'}, $conf{'Password'}) = ($login, $password);
    $client = Mail::IMAPClient->new(%conf);
    if ($client->IsAuthenticated()) {
        my $message_count = $client->select($imap_folder)->unseen_count || 0;
        my $color = ($message_count == 0) ? $cdef : $nmc;
        $result = ct($color, $message_count);
    } else {
        $result = ct($cdsb, $na_text);
    }
    return $result;
}

1;