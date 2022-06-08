## Run Hadoop with hive, hbase, and spark Cluster within Docker Containers


### 3 Nodes Hadoop set (including hive, hbase, spark) Cluster

##### 1. pull docker image

```
sudo docker pull didadidaboom/hadoopset:1
sudo docker pull mysql
```

##### 2. clone github repository

```
git clone https://github.com/didadidaboom/hadoopset-cluster-docker.git
```

##### 3. create hadoop network

```
sudo docker network create --driver=bridge hadoop
```

##### 4. start container

```
cd hadoop-cluster-docker
sudo ./start-container.sh
```

**output:**

```
start hadoop-mysql container...
start hadoop-master container...
start hadoop-slave1 container...
start hadoop-slave2 container...
root@hadoop-master:~# 
```
- start 4 containers with 1 mysql, 1 master and 2 slaves
- you will get into the /root directory of hadoop-master container

##### 5. start hadoop

```
./start-hadoop.sh
```

##### 6. run wordcount

```
./run-wordcount.sh
```

**output**

```
input file1.txt:
Hello Hadoop

input file2.txt:
Hello Docker

wordcount output:
Docker    1
Hadoop    1
Hello    2
```

### Arbitrary size Hadoop cluster

##### 1. pull docker images and clone github repository

do 1~3 like section A

##### 2. rebuild docker image

```
sudo ./resize-cluster.sh 5
```
- specify parameter > 1: 2, 3..
- this script just rebuild hadoop image with different **slaves** file, which pecifies the name of all slave nodes


##### 3. start container

```
sudo ./start-container.sh 5
```
- use the same parameter as the step 2

##### 4. run hadoop cluster 

do 5~6 like section A

###  Start hive 

##### 1. Run hive metastore sevice

```
hive --sevice metastore
```

##### 2. Create initial database

```
schematool -dbType mysql -initSchema
```

##### 3. Test hive

```
hive
```

##### Noted: mysql runs in a container named hadoop-mysql with a default username(root) and password(hive).

### Start hbase

```
start-hbase.sh
hbase shell
```

### Start spark

##### 1. Start spark
```
sbin/spark-all.sh
```

##### 2. Check spark
Check whether installation is successful or not by "jps".  Having ***output*** in master node:
```
namenode
jps
secondarynamenode
resourcemanager
master
```

Having ***output*** in slave node:

```
jps
datanode
nodemanager
worker
```

or check by browsing web management page: http://hadoop-master:8080

##### 3.Run a example to test spark

```
./bin/spark-submit
--class org.apache.spark.examples.SparkPi 
--master yarn 
--deploy-mode cluster 
--driver-memory 1G 
--executor-memory 1G 
--executor-cores 1 /usr/local/spark/examples/jars/spark-examples_2.12-3.0.1.jar 30
```

### What are the differeces from https://github.com/kiwenlau/hadoop-cluster-docker:
1. including hive, hbase, and spark
2. ubuntu 18.04
