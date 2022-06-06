#!/bin/ksh

set -exu

echo 'set tty com0' >> /etc/boot.conf
echo 'permit nopass keepenv root' >> /etc/doas.conf

pkg_add -Dsnap -I bash curl rsync-- python3 step-ca step-cli
sed -i 's:^daemon_execdir.*$:daemon_execdir=/var/step-ca:' /etc/rc.d/step_ca

openssl rand -base64 32 > /var/step-ca/step-ca.pass
chown root:_step-ca /var/step-ca/step-ca.pass
chmod 640 /var/step-ca/step-ca.pass
doas -u _step-ca env STEPPATH=/var/step-ca /usr/local/bin/step ca init --deployment-type=standalone --name=homelab --dns=localhost --address=127.0.0.1:4242 --provisioner=homelab@bsd.ac --password-file=step-ca.pass > step.init 2>&1

rcctl enable step_ca
rcctl set step_ca flags --config=config/ca.json --password-file=step-ca.pass
