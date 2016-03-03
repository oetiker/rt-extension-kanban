use inc::Module::Install;

RTx 'RT-Extension-KANBAN';
license  'gplv2';

githubmeta('github');

#requires_rt('4.2.4');

requires 'Encode';
requires 'JSON';
requires 'Module::Runtime';
requires 'namespace::autoclean';
requires 'Plack::Builder';
requires 'Scalar::Util';
requires 'Sub::Exporter';
requires 'Web::Machine' => '0.12';
requires 'Web::Simple';
requires 'Class::Method::Modifiers';
requires 'Plack::Middleware::RequestHeaders';
requires 'Plack::Middleware::ReverseProxyPath';
requires 'Module::Path';
#requires 'Pod::POM';

recommends 'JSON::XS';

sign;
WriteAll;
