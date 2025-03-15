requires 'Mojolicious', '7.60';

on test => sub {
    requires 'Test::More', '0.98';
    requires 'YAML::XS', '0';
};

# cpanm -n --installdeps --with-develop .
on develop => sub {
    requires 'Pod::Coverage::TrustPod', '0';
    requires 'Test::NoTabs', '0';
    requires 'Test::Pod', '1.41';
    requires 'Test::Pod::Coverage', '1.08';
};
