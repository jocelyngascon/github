/*libname setup xyz*/
option set=SAS_HADOOP_CONFIG_PATH="/caslibs/hadoopfiles/conf";
option set=SAS_HADOOP_JAR_PATH="/caslibs/hadoopfiles/lib";
options sastrace=',,,d' sastraceloc=saslog nostsuffix sql_ip_trace=(note,source) msglevel=i;
libname x hadoop url="jdbc:hive2://zk0-demode.btdl103xpygefdcqvg1iot005e.vx.internal.cloudapp.net:2181,zk1-demode.btdl103xpygefdcqvg1iot005e.vx.internal.cloudapp.net:2181,zk2-demode.btdl103xpygefdcqvg1iot005e.vx.internal.cloudapp.net:2181/;serviceDiscoveryMode=zooKeeper;zooKeeperNamespace=hiveserver2";

/*caslib setup*/
cas mySession sessopts=(caslib=casuser timeout=1800 locale="en_US");
caslib hdlib datasource=(srctype="hadoop", dataTransferMode="serial",
username="admin",
uri="jdbc:hive2://zk0-demode.btdl103xpygefdcqvg1iot005e.vx.internal.cloudapp.net:2181/;serviceDiscoveryMode=zooKeeper;zooKeeperNamespace=hiveserver2",
hadoopjarpath="/caslibs/hadoopfiles/lib",
hadoopconfigdir="/caslibs/hadoopfiles/conf",
schema="default");

proc casutil;
list files incaslib="hdlib";
run;
