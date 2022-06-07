FROM ubuntu:18.04

MAINTAINER didadidaboom <chong.wu.sg@outlook.com>

WORKDIR /root

# install openssh-server, openjdk and wget
RUN apt-get -o Acquire::Check-Valid-Until=false -o Acquire::Check-Date=false update && \
    apt-get install -y openssh-server openjdk-8-jdk wget vim python3-pip && \
    pip3 install jupyter

# install hadoop 2.7.2 and hive
RUN wget https://github.com/kiwenlau/compile-hadoop/releases/download/2.7.2/hadoop-2.7.2.tar.gz && \
    tar -xzvf hadoop-2.7.2.tar.gz && \
    mv hadoop-2.7.2 /usr/local/hadoop && \
    rm hadoop-2.7.2.tar.gz && \
    wget https://archive.apache.org/dist/hive/hive-2.3.8/apache-hive-2.3.8-bin.tar.gz && \
    tar -xzvf apache-hive-2.3.8-bin.tar.gz && \ 
    mv apache-hive-2.3.8-bin /usr/local/hive && \
    rm apache-hive-2.3.8-bin.tar.gz && \
    wget https://repo1.maven.org/maven2/mysql/mysql-connector-java/5.1.47/mysql-connector-java-5.1.47.jar && \
    mv mysql-connector-java-5.1.47.jar /usr/local/hive/lib/mysql-connector-java-5.1.47.jar && \
    wget https://archive.apache.org/dist/hbase/1.4.7/hbase-1.4.7-bin.tar.gz && \
    tar -xzvf hbase-1.4.7-bin.tar.gz && \
    mv hbase-1.4.7 /usr/local/hbase && \
    rm hbase-1.4.7-bin.tar.gz && \ 
    wget https://archive.apache.org/dist/spark/spark-3.0.1/spark-3.0.1-bin-hadoop2.7.tgz && \
    tar -xzvf spark-3.0.1-bin-hadoop2.7.tgz && \
    mv spark-3.0.1-bin-hadoop2.7 /usr/local/spark && \ 
    rm spark-3.0.1-bin-hadoop2.7.tgz
     

# set environment variable
ENV JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-amd64 
ENV HADOOP_HOME=/usr/local/hadoop 
ENV PATH=$PATH:/usr/local/hadoop/bin:/usr/local/hadoop/sbin 
ENV HIVE_HOME=/usr/local/hive
ENV PATH=$PATH:/usr/local/hive/bin
ENV HBASE_HOME=/usr/local/hbase
ENV PATH=$PATH:/usr/local/hbase/bin
ENV SPARK_HOME=/usr/local/spark
ENV PATH=$PATH:/usr/local/spark/bin
ENV JRE_HOME=/usr/lib/jvm/java-1.8.0-openjdk-amd64/jre
ENV CLASSPATH=.:$JAVE_HOME/lib:$JRE_HOME/lib:$CLASSPATH

# ssh without key
RUN ssh-keygen -t rsa -f ~/.ssh/id_rsa -P '' && \
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

RUN mkdir -p ~/hdfs/namenode && \ 
    mkdir -p ~/hdfs/datanode && \
    mkdir $HADOOP_HOME/logs && \
    mkdir -p $HIVE_HOME/tmp/hive/java && \
    mkdir -p ~/hdfs/hbase

COPY config/* /tmp/

RUN mv /tmp/ssh_config ~/.ssh/config && \
    mv /tmp/hadoop-env.sh /usr/local/hadoop/etc/hadoop/hadoop-env.sh && \
    mv /tmp/hdfs-site.xml $HADOOP_HOME/etc/hadoop/hdfs-site.xml && \ 
    mv /tmp/core-site.xml $HADOOP_HOME/etc/hadoop/core-site.xml && \
    mv /tmp/mapred-site.xml $HADOOP_HOME/etc/hadoop/mapred-site.xml && \
    mv /tmp/yarn-site.xml $HADOOP_HOME/etc/hadoop/yarn-site.xml && \
    cp /tmp/slaves $HADOOP_HOME/etc/hadoop/slaves && \
    mv /tmp/start-hadoop.sh ~/start-hadoop.sh && \
    mv /tmp/run-wordcount.sh ~/run-wordcount.sh && \
    mv /tmp/hive-env.sh $HIVE_HOME/conf/hive-env.sh && \
    mv /tmp/hive-site.xml $HIVE_HOME/conf/hive-site.xml && \
    mv /tmp/hbase-env.sh $HBASE_HOME/conf/hbase-env.sh && \
    mv /tmp/hbase-site.xml $HBASE_HOME/conf/hbase-site.xml && \
    mv /tmp/regionservers $HBASE_HOME/conf/regionservers && \
    mv /tmp/spark-env.sh $SPARK_HOME/conf/spark-env.sh && \
    mv /tmp/slaves $SPARK_HOME/conf/slaves && \
    mv /tmp/start-all.sh ~/start-all.sh

RUN chmod +x ~/start-hadoop.sh && \
    chmod +x ~/run-wordcount.sh && \
    chmod +x $HADOOP_HOME/sbin/start-dfs.sh && \
    chmod +x $HADOOP_HOME/sbin/start-yarn.sh && \
    chmod +x ~/start-all.sh

# format namenode
RUN /usr/local/hadoop/bin/hdfs namenode -format

CMD [ "sh", "-c", "service ssh start; bash"]
