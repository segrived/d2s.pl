#! /usr/bin/perl
# -------------------------------------
# d2spl script for Dzen2 (Perl version)
# Author: Holden Cox, 2011-2012
# E-mail: segrived@gmail.com
# Version 2.00 Beta 13


#====================================#
#============== CONFIG ==============#
#====================================#
package config;

# Хэш с конфигурацией
my %configs = ();

# Регулярное выражение парсинга конфига
my $conf_re = qr {
    (?<k>[0-9a-z._]+) # Ключ
    (?:[\s]*\:[\s]*)  # Разделитель
    (?<v>[\S\s]+$)    # Значение
}osx;

# Поочерёдно загружает настройки из файлов, переданных параметром
sub load_files {
    (-e $_) ? load_file($_) : next foreach (@_);
}

# Загружет настройки из файла, переданного параметром
sub load_file {
    open my $cfgfile, '<', $_[0];
    chomp(my @lines = <$cfgfile>);
    foreach $config_line (@lines) {
        set($+{k}, $+{v}) if ($config_line =~ $conf_re);
    }
    close($cfgfile);
}

# Устанавливает значение параметра конфигурации
sub set {
    $configs{$_[0]} = $_[1];
}

# Возвращает значение параметра конфигурации
sub get {
    return $configs{$_[0]} //= $_[1];
}



#====================================#
#=============== MAIN ===============#
#====================================#
package main;

use strict;
use warnings;
use IO::Handle;
use Cwd;


# Загрузка файлов конфигурации
config::load_files(
    "/etc/d2spl/main.conf",
    "$ENV{'HOME'}/.config/d2spl/main.conf"
);

# Выводит текст заданным цветом
sub ct {
    my ($color, $text) = (shift, shift);
    my $cdef = config::get("colors.default");
    return "^fg($color)$text^fg($cdef)";
}

# Парсит строку со временем в секунды
sub parse_time {
    my %scale_mul = ('m' => 60, 'h' => 3600);
    shift =~ m/^(?<t>\d+)\s*(?<s>\S*)$/;
    my $scale = chr ord $+{"s"} if defined $+{"s"};
    return int $+{"t"} * ($scale_mul{$scale} //= 1);
}


# Ожидание перед запуском
sleep parse_time(config::get("main.start_delay", 0));

# Список включённых модулей
my @enabled_modules = split(/\s+/, config::get("main.enabled"));

# Директории, где будет выполняться поиск модулей
my @mod_pathes = (
    getcwd . "/modules",
    "/usr/share/d2spl/modules",
    "$ENV{'HOME'}/.config/d2spl/modules",
);

# Загрузка необходимых модулей
foreach my $mod (@enabled_modules) {
    foreach (@mod_pathes) {
        require "$_/$mod.pl" && last if(-e "$_/$mod.pl");
    }
}

# Инициализация необходимых переменных
my ($counter, %mod_data, %generated_content, %d2c) = (0, (), (), ());

# Настройки Dzen2
$d2c{"bin"} = config::get("dzen2.path", "/usr/bin/dzen2");
$d2c{"position"} = substr(config::get("dzen2.position", "right"), 0, 1);
$d2c{"font"} = config::get("dzen2.font", "fixed");
$d2c{"background"} = config::get("dzen2.background", "#000000");
$d2c{"events"} = config::get("dzen2.events", "");
$d2c{"width"} = config::get("dzen2.width", 0);

my $command = sprintf("%s -ta %s -fn %s -bg '%s' -e \"%s\" -w %d",
    $d2c{bin}, $d2c{position}, $d2c{font}, $d2c{background}, $d2c{events}, $d2c{width}
);

open(DZEN2, "|-", $command);
DZEN2->autoflush(1); # Небуферизированный вывод

foreach my $mod (@enabled_modules) {
    # Интервал между обновлениями значения
    $mod_data{$mod}{"updint"} = parse_time(config::get("mod.$mod.upd", 1));
    
    # Надпись или иконка
    my ($lp, $lc, $lblpart) = (config::get("ui.label_padding"), config::get("colors.label"), "");
    if (config::get("ui.use_icons")) {
        my ($icon, $path) = (config::get("mod.$mod.icon", 0), config::get("main.icons_path"));
        $lblpart = ($icon) ? "^i(${path}/${icon})" : "";
    } else {
        my $label = config::get("mod.$mod.label", 0);
        $lblpart = ($label) ? "$label:" : "";
    }
    $mod_data{$mod}{"label"} = "^fg($lc)" . $lblpart . "^p($lp)";
    
    # Цвет иконки или надписи
    $mod_data{$mod}{"color"} = config::get("mod.$mod.color", config::get("colors.default"));
    
    # Расстояние между индикаторами
    $mod_data{$mod}{"padding"} = config::get("mod.$mod.padding", config::get("ui.padding", 20)); 
}

# Основной цикл
while(1) {
    my ($output, $mod_content) = ("", "");
    foreach my $mod (@enabled_modules) {
        # Обновление значение индикатора в случае надобности
        my($upd_int, $is_upd) = ($mod_data{$mod}{"updint"}, $mod_data{$mod}{"is_updated"});
        if (($upd_int && !($counter % $upd_int)) || (!$upd_int && !$is_upd)) {
            # Обновление индикатора
            $mod_data{"$mod"}{"data"} = &{\&{"d2sf_get_$mod"}}();
            $mod_data{"$mod"}{"is_updated"} = 1;
            # Генерация строки с контентом
            $mod_content = "$mod_data{$mod}{label}";
            $mod_content .= "^fg($mod_data{$mod}{color})";
            $mod_content .= "$mod_data{$mod}{data}";
            $mod_content .= "^p($mod_data{$mod}{padding})";
            $generated_content{$mod} = $mod_content;
        }
        # Вывод результата
        $output .= $generated_content{$mod};
    }
    print DZEN2 "$output\n"; undef $output;
    $counter++; sleep 1;
}

1;