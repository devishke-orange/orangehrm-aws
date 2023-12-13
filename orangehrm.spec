Name:           orangehrm
Version:        0.0.1
Release:        1%{?dist}
Summary:        CLI utility for managing an OHRM AWS Instance

License:        MIT
URL:            https://github.com/devishke-orange/orangehrm-aws
Source0:        orangehrm-0.0.1.tar.gz

Requires:       bash
Requires:       docker
Requires:       pwgen

BuildArch:      noarch

%description
CLI utility for managing an OrangeHRM AWS Instance

%prep
%setup -q

%install
mkdir -p %{buildroot}/%{_bindir}
install -m 0755 %{name} %{buildroot}/%{_bindir}/%{name}

mkdir -p %{buildroot}/opt/%{name}
cp -r assets %{buildroot}/opt/%{name}
cp -r scripts %{buildroot}/opt/%{name}
cp -r compose.yml %{buildroot}/opt/%{name}

mkdir -p %{buildroot}/etc/profile.d/
mv %{buildroot}/opt/%{name}/scripts/login_orangehrm %{buildroot}/etc/profile.d/login_orangehrm.sh

chown -R ec2-user:ec2-user %{buildroot}/opt/%{name}

%files
%{_bindir}/%{name}
%defattr(400, -, -, 400)

/opt/orangehrm/assets/maintenance.php
/opt/orangehrm/assets/license.txt
/opt/orangehrm/assets/ssl.conf
/opt/orangehrm/assets/ssl_renew.service
/opt/orangehrm/assets/ssl_renew.timer
/opt/orangehrm/scripts/backup
/opt/orangehrm/scripts/ssl
/opt/orangehrm/scripts/check_update
/opt/orangehrm/scripts/clean
/opt/orangehrm/scripts/get_logs
/opt/orangehrm/scripts/help
/opt/orangehrm/scripts/install
/opt/orangehrm/scripts/status
/opt/orangehrm/scripts/update
/opt/orangehrm/scripts/backup_scripts/backup_help
/opt/orangehrm/scripts/backup_scripts/clean
/opt/orangehrm/scripts/backup_scripts/create
/opt/orangehrm/scripts/backup_scripts/list
/opt/orangehrm/scripts/backup_scripts/restore
/opt/orangehrm/scripts/helper_scripts/countries
/opt/orangehrm/scripts/helper_scripts/logo
/opt/orangehrm/scripts/ssl_scripts/ssl_help
/opt/orangehrm/scripts/ssl_scripts/enable
/opt/orangehrm/scripts/ssl_scripts/restore
/opt/orangehrm/scripts/ssl_scripts/renew
/opt/orangehrm/scripts/ssl_scripts/configure_auto_renew
/etc/profile.d/login_orangehrm.sh
/opt/orangehrm/compose.yml

%changelog
* Mon Nov 20 2023 devishke-orange <devishke@orangehrmlive.com> - 0.0.1-1.amzn2023
- Package test
