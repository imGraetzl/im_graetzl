# The output of all these installation steps is noisy. With this utility
# the progress report is nice and concise.
# enable console colors
sed -i '1iforce_color_prompt=yes' ~/.bashrc

function install {
  echo installing $1
  shift
  apt-get -y install "$@" >/dev/null 2>&1
}

echo updating package information
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt trusty-pgdg main" >> /etc/apt/sources.list'
wget --quiet -O - http://apt.postgresql.org/pub/repos/apt/ACCC4CF8.asc | sudo apt-key add -
apt-add-repository -y ppa:brightbox/ruby-ng >/dev/null 2>&1
apt-get -y update >/dev/null 2>&1

install 'development tools' build-essential libgeos-dev libproj-dev
install Ruby ruby2.3 ruby2.3-dev
update-alternatives --set ruby /usr/bin/ruby2.3 >/dev/null 2>&1
update-alternatives --set gem /usr/bin/gem2.3 >/dev/null 2>&1

echo disable docs during gem install
echo 'gem: --no-rdoc --no-ri' >> ~/.gemrc

echo installing Bundler
gem install bundler -N >/dev/null 2>&1

install Git git
install Memcached memcached
install Curl curl libcurl4-openssl-dev
install zlib1g zlib1g-dev
install libssl libssl-dev
install Postgres postgresql-9.4-postgis-2.1 postgresql-contrib-9.4 libpq-dev
sudo -u postgres createuser --superuser vagrant
sudo -u postgres psql << EOF
  CREATE EXTENSION postgis;
  \q
EOF
install 'ExecJS runtime' nodejs

# Needed for docs generation.
update-locale LANG=en_US.UTF-8 LANGUAGE=en_US.UTF-8 LC_ALL=en_US.UTF-8

echo 'all set, rock on!'
