# Модуль возвращает текущую частоту процессора
# Версия 0.1
# Автор: segrived, 2012
# Требуемое ПО: cpufreq-info

my $cdsb = config::get("colors.disabled");

sub d2sf_get_cpu_freq {
    chomp(my $out = `cpufreq-info -fm`);
    my ($freq, $scale) = split / /, $out;
    return $freq . ct($cdsb, uc($scale));
}

1;