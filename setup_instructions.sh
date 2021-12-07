sudo apt-get update

wget https://www.dropbox.com/s/ibnl20duge85fy3/har-firefox-67.0-stable-image.tar.gz

sudo snap install docker

sudo docker load < har-firefox-67.0-stable-image.tar.gz

git clone https://github.com/andrewcchu/dns-measurement-suite.git

cd /home/vagrant/dns-measurement-suite/src/measure/dns-timing/debs

sudo apt install -y dns-root-data libcurl4-openssl-dev libssl-dev libev4 libev-dev libevent-2.1.6 libevent-core-2.1.6 libevent-openssl-2.1.6 libevent-dev libuv1 python3 python3-pip python3-dev postgresql postgresql-client dnsutils net-tools autoconf automake build-essential libtool uuid

sudo dpkg -i libgetdns10_1.5.1-1.1_amd64.deb

sudo dpkg -i libgetdns-dev_1.5.1-1.1_amd64.deb

cd ../..

pip3 install -r requirements.txt

sudo -u postgres psql
create database ddns_db;
create user ddns with encrypted password 'ddns';
grant all privileges on database ddns_db to ddns;

# ctrl-d

cd /home/vagrant/dns-measurement-suite/data

printf "[postgresql]\nhost=127.0.0.1\ndatabase=ddns_db\nuser=ddns\npassword=ddns\nhar_table=har\ndns_table=dns\n" > postgres.ini

cd /home/vagrant/dns-measurement-suite/src/measure/

python3 database.py ../../data/postgres.ini

cd /home/vagrant/dns-measurement-suite/src/measure/dns-timing

make

### DNS MEASUREMENT SETUP

cd ~

git clone https://github.com/noise-lab/ddns.git

sudo -s

ss -lp 'sport = :domain'
systemctl stop systemd-resolved
systemctl disable systemd-resolved

cd ddns/releases

tar -xf dnscrypt-proxy-linux_x86_64-dev.tar.gz

cd linux-x86_64

cp example-dnscrypt-proxy-<method>.toml dnscrypt-proxy.toml

apt-get remove resolvconf

cp /etc/resolv.conf /etc/resolv.conf.backup

printf "nameserver 127.0.0.1\noptions edns0\n" > /etc/resolv.conf

./dnscrypt-proxy -service install

./dnscrypt-proxy -service start

cd /home/vagrant/dns-measurement-suite/src/measure/

nohup ./measure.sh &

exit

exit


