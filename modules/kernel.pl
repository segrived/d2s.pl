# Модуль возвращает версию ядра
# Версия 0.1
# Автор: segrived, 2012
# Требуемое ПО: uname

sub d2sf_get_kernel {
    chomp(my $kernel = `uname -r`);
    return $kernel;
}

1;