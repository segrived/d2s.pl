#! /usr/bin/perl
# -------------------------------------
# d2spl script for Dzen2 (Perl version)
# Author: Holden Cox, 2011-2012
# E-mail: segrived@gmail.com
# Version 2.00 Beta 12

#== CONFIG ==============
package config;

# Хэш с конфигурацией
my %conf = ();

# Парсер файла конфигурации
sub load {
    foreach (@_) {
        next unless (-e $_);
        open(CFGFILE, "<", $_);
        chomp(my @lines = <CFGFILE>);
        close(CFGFILE);
        foreach (@lines) {
            if ($_ =~ m/(?<key>[0-9a-z._]+):(?:[\s]*)(?<value>[\S\s]+$)/) {
                $conf{$+{"key"}} = $+{"value"};
            }
        }
    }
}

sub set {
    $conf{"$_[0]"} = $+{"$_[1]"};
}

sub get {
    return (defined $conf{"$_[0]"}) ? $conf{"$_[0]"} : "$_[1]";
}


#== MAIN ================
package main;
use IO::Handle;
use strict;
use warnings;
use Cwd;

config::load(
    "/etc/d2spl/main.conf",
    "$ENV{'HOME'}/.config/d2spl/main.conf"
);

sub ct {
    my ($color, $text) = (shift, shift);
    my $cdef = config::get("colors.default");
    return "^fg($color)$text^fg($cdef)";
}

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

my ($counter, %mod_data, %d2c) = (0, (), ());

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

open(DZEN2, "|-", "$command");
DZEN2->autoflush(1);

# Основной цикл
while(1) {
    my $output = "";
    foreach my $module (@enabled_modules) {
        # Интервал между обновлениями значения
        unless(defined $mod_data{"$module"}{updint}) {
            $mod_data{"$module"}{updint} = parse_time(config::get("mod.$module.upd", 1));
        }
        
        # Надпись или иконка
        unless(defined $mod_data{"$module"}{label}) {
            my $label_padding = config::get("ui.label_padding");
            my $label_color = config::get("colors.label");
            if (config::get("ui.use_icons")) {
                my $icon = config::get("mod.$module.icon", 0);
                my $icons_path = config::get("main.icons_path");
                $mod_data{"$module"}{"label"} = ($icon)
                    ? "^fg(${label_color})^i(${icons_path}/${icon})^p(${label_padding})" : "";
            } else {
                my $label = config::get("mod.$module.label");
                $mod_data{"$module"}{"label"} = ($label)
                    ? "^fg(${label_color})$label:^p(${label_padding})" : "";
            }
        }
        
        # Цвет иконки или надписи
        unless(defined $mod_data{"$module"}{color}) {
            my $color = config::get("mod.$module.color", config::get("colors.default"));
            $mod_data{"$module"}{"color"} = $color;
        }
        
        # Расстояние между индикаторами
        unless(defined $mod_data{"$module"}{rpadding}) {
            my $padding = config::get("mod.$module.rpadding", config::get("ui.padding", 20));
            $mod_data{"$module"}{"rpadding"} = $padding;
        }
        
        # Обновление значение индикатора в случае надобности
        my($updint, $isupd) = ($mod_data{"$module"}{"updint"}, $mod_data{"$module"}{"is_updated"});
        if (($updint && !($counter % $updint)) || (!$updint && !$isupd)) {
            $mod_data{"$module"}{"data"} = &{\&{"d2sf_get_$module"}}();
            $mod_data{"$module"}{"is_updated"} = 1;
        }

        # Вывод результата
        $output .= "$mod_data{$module}{label}";        # Надпись или иконка
        $output .= "^fg($mod_data{$module}{color})";   # Цвет контента
        $output .= "$mod_data{$module}{data}";         # Контент
        $output .= "^p($mod_data{$module}{rpadding})"; # Отступ
    }
    print DZEN2 "$output\n";
    $counter++;
    sleep 1;
}

1;