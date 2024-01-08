Name:           orangehrm-aws-cli
Version:        0.0.2
Release:        2%{?dist}
Distribution:   Amazon Linux 2023
Summary:        CLI Utility for user-friendly installation and management of the OrangeHRM 5 on Amazon Linux 2023

License:        GPLv3
URL:            https://github.com/orangehrm/os-cloud
Source0:        orangehrm-aws-cli-0.0.2.tar.gz

Requires:       bash
Requires:       docker
Requires:       pwgen

BuildArch:      noarch

%description
The OrangeHRM AWS CLI allows you to easily install and manage your OrangeHRM 5 EC2 instance.
Some features of the CLI include guided installation, simple upgrade, backup creation and restoring, etc.
SSL certificate generation is also simplified by the inclusion and automation of Certbot.

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
/opt/orangehrm/scripts/helper_scripts/logo
/opt/orangehrm/scripts/ssl_scripts/ssl_help
/opt/orangehrm/scripts/ssl_scripts/enable
/opt/orangehrm/scripts/ssl_scripts/restore
/opt/orangehrm/scripts/ssl_scripts/renew
/opt/orangehrm/scripts/ssl_scripts/auto_renew
/etc/profile.d/login_orangehrm.sh
/opt/orangehrm/compose.yml

%changelog
* Mon Jan 08 2024 devishke-orange <devishke@orangehrmlive.com> - 0.0.2-2.amzn2023
- Addition of SSL commands
- Changed MIT License to GPLv3 License
* Mon Nov 20 2023 devishke-orange <devishke@orangehrmlive.com> - 0.0.1-1.amzn2023
- Package test
