# Модуль возвращает активную раскладку клавиатуры
# Версия 0.2
# Автор: segrived, 2012
# Требуемое ПО: xkb-switch

sub d2sf_get_layout {
    my $result;
    if(config::get("mod.layout.use_skb", 0)) {
        chomp($result = `skb -1`);
    } else {
        chomp($result = `xkb-switch`);
    }
    return uc($result);
}

1;