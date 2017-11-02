export SNMP_DEPS="snmp snmpd snmp-mibs-downloader libsnmp-dev"
export MIBS_DIR="/var/lib/mibs/ietf/"
export COLLECTD_SCRIPT="/opt/collectd_scripts"
export COLLECTD_CONF="/etc/collectd"

# install SNMP 
sudo apt-get -y install $SNMP_DEPS
mkdir -p $COLLECTD_CONF/conf.d
cp $COLLECTD_SCRIPT/snmp/Container-* $MIBS_DIR/
cp $COLLECTD_SCRIPT/snmp/Intel-* $MIBS_DIR/
cp $COLLECTD_SCRIPT/snmp/collectd_snmp_agent_containers.conf $COLLECTD_CONF/conf.d/
cp $COLLECTD_SCRIPT/snmp/snmpd.conf /etc/snmp/snmpd.conf

