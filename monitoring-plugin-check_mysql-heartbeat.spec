%define		plugin	check_mysql-heartbeat
%define		php_min_version 5.0.0
%include	/usr/lib/rpm/macros.php
Summary:	Nagios plugin to check MySQL heartbeat
Name:		monitoring-plugin-%{plugin}
Version:	1.0
Release:	2
License:	GPL v2
Group:		Networking
Source0:	check_mysql-heartbeat.sh
Source1:	check_mysql-heartbeat.cfg
BuildRequires:	rpm-php-pearprov >= 4.4.2-11
Requires:	nagios-common
Requires:	nagios-plugins-libs
BuildArch:	noarch
BuildRoot:	%{tmpdir}/%{name}-%{version}-root-%(id -u -n)

%define		_sysconfdir	/etc/nagios/plugins
%define		plugindir	%{_prefix}/lib/nagios/plugins

%description
Nagios plugin to check MySQL heartbeat with maatkit or
percona-toolkit.

%prep
%setup -qTc
cp -p %{SOURCE0} .
cp -p %{SOURCE1} .

%install
rm -rf $RPM_BUILD_ROOT
install -d $RPM_BUILD_ROOT{%{_sysconfdir},%{plugindir}}
install -p %{plugin}.sh $RPM_BUILD_ROOT%{plugindir}/%{plugin}
cp -p %{plugin}.cfg $RPM_BUILD_ROOT%{_sysconfdir}/%{plugin}.cfg

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(644,root,root,755)
%attr(640,root,nagios) %config(noreplace) %verify(not md5 mtime size) %{_sysconfdir}/%{plugin}.cfg
%attr(755,root,root) %{plugindir}/%{plugin}
