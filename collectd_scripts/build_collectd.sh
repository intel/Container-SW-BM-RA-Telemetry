export COLLECTD_DEPS="build-essential autoconf automake flex bison libtool libltdl-dev pkg-config python-yaml"

export COLLECTD_REPO="https://github.com/collectd/collectd.git"
export CADVISOR_COLLECTD_REPO="https://github.com/maier/cadvisor-collectd.git"

export ROOT_INSTALL_DIR="/opt"
export COLLECTD_DIR="/opt/collectd"
export CADVISOR_COLLECTD_DIR="/opt/cadvisor-collectd"

export COLLECTD_SCRIPT="/opt/collectd_scripts"

export COLLECTD_CONF="/etc/collectd"

rm -rf $COLLECTD_DIR

# clone and build collectd
sudo apt-get install -y $COLLECTD_DEPS

echo "STEP_SETUP: Cloning collectd repo";
mkdir -p /opt
cd $ROOT_INSTALL_DIR
git clone $COLLECTD_REPO collectd

# patch collectd with snmp agent multiple index support
cp $COLLECTD_SCRIPT/patch/snmp_agent.patch $COLLECTD_DIR
cd $COLLECTD_DIR
git apply snmp_agent.patch

cd $ROOT_INSTALL_DIR/collectd
echo "STEP_SETUP: Build collectd";
./build.sh

echo "STEP_SETUP: Configure collectd";
JAVA_HOME="" ./configure --enable-syslog --enable-logfile --enable-python --disable-perl --without-libdpdk

echo "STEP_SETUP: Make install collectd";
PERL5LIB="" sudo make -j4 install

# clone cadvisor-collectd
rm -rf $CADVISOR_COLLECTD_DIR

echo "STEP_SETUP: Cloning cadvisor-collectd repo";
cd $ROOT_INSTALL_DIR
git clone $CADVISOR_COLLECTD_REPO cadvisor-collectd

# patch cadvisor-collectd
cp $COLLECTD_SCRIPT/patch/cadvisor-collectd.patch $CADVISOR_COLLECTD_DIR
cd $CADVISOR_COLLECTD_DIR
git apply cadvisor-collectd.patch

# install cadvisor-collectd dependencies
pip install docker-py
pip install docker

mkdir $COLLECTD_DIR/python
touch $COLLECTD_DIR/python/__init__.py
cp $CADVISOR_COLLECTD_DIR/src/cadvisor/cadvisor-cli $COLLECTD_DIR/
cp $CADVISOR_COLLECTD_DIR/src/cadvisor/python/cadvisor.py $COLLECTD_DIR/python/
cp $CADVISOR_COLLECTD_DIR/src/cadvisor/python/cadvisor-metrics.py $COLLECTD_DIR/python/
cp $CADVISOR_COLLECTD_DIR/src/cadvisor/cadvisor-types.db $COLLECTD_DIR/

chown nobody $COLLECTD_DIR/cadvisor-cli
chmod +x $COLLECTD_DIR/cadvisor-cli

mkdir -p $COLLECTD_CONF
cp $COLLECTD_SCRIPT/conf/cadvisor.yaml $COLLECTD_CONF/
cp $COLLECTD_SCRIPT/conf/collectd.conf $COLLECTD_CONF/
mkdir -p $COLLECTD_CONF/conf.d
cp $COLLECTD_SCRIPT/conf/cadvisor.conf $COLLECTD_CONF/conf.d/
cp $COLLECTD_SCRIPT/conf/write_csv.conf $COLLECTD_CONF/conf.d/
