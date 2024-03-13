
# Apache Spark and HDFS Cluster Setup Guide

This README provides detailed instructions for setting up a distributed Apache Spark cluster with Hadoop Distributed File System (HDFS) on Linux(Ubuntu). This setup is designed for a cluster of Linux machines, configuring one as the master and the rest as worker nodes.

## Prerequisites

- Several Linux machines (Ubuntu recommended) with SSH access and sudo privileges.
- Basic command-line, vim/nano, and SSH

## Java Installation

1. **Update Package List**
    ```bash
    sudo apt update
    ```

2. **Install OpenJDK 17**
    ```bash
    sudo apt install openjdk-17-jdk
    ```

3. **Set JAVA_HOME Globally**
    Edit the `/etc/environment` file:
    ```bash
    sudo vim /etc/environment
    ```
    Add:
    ```plaintext
    JAVA_HOME="/usr/lib/jvm/java-17-openjdk-amd64"
    ```
    Apply the changes:
    ```bash
    source /etc/environment
    ```

## Apache Spark Installation

1. **Download Apache Spark**
    ```bash
    wget https://dlcdn.apache.org/spark/spark-3.5.1/spark-3.5.1-bin-hadoop3.tgz
    ```

2. **Extract and Move Spark**
    ```bash
    tar xvf spark-3.5.1-bin-hadoop3.tgz
    sudo mv spark-3.5.1-bin-hadoop3 /opt/spark
    ```

3. **Configure Environment**
    Add Spark to `PATH` in `~/.bashrc` or `~/.profile`:
    ```bash
    echo 'export SPARK_HOME=/opt/spark' >> ~/.bashrc
    echo 'export PATH=$PATH:$SPARK_HOME/bin:$SPARK_HOME/sbin' >> ~/.bashrc
    source ~/.bashrc
    ```

4. **Configure Spark**
    - Spark Environment (`spark-env.sh`):
      ```bash
      cp /opt/spark/conf/spark-env.sh.template /opt/spark/conf/spark-env.sh
      echo 'export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64' >> /opt/spark/conf/spark-env.sh
      echo 'export SPARK_MASTER_HOST=MASTER_IP' >> /opt/spark/conf/spark-env.sh
      ```
    - Workers (`workers`):
      ```bash
      cp /opt/spark/conf/workers.template /opt/spark/conf/workers
      vim /opt/spark/conf/workers # Add the IPs or hostnames of the worker nodes
      ```

5. **Start Spark Services**
    - On the master node:
      ```bash
      /opt/spark/sbin/start-master.sh
      ```
    - On each worker node, replace `MASTER_IP` with the master node's IP address:
      ```bash
      /opt/spark/sbin/start-worker.sh spark://MASTER_IP:7077
      ```

## Hadoop (HDFS) Installation

1. **Download Hadoop**
    ```bash
    wget https://dlcdn.apache.org/hadoop/common/hadoop-3.3.6/hadoop-3.3.6.tar.gz
    ```

2. **Extract and Move Hadoop**
    ```bash
    tar xvf hadoop-3.3.6.tar.gz --directory /home/ubuntu/
    sudo mv hadoop-3.3.6 /usr/local/hadoop
    ```

3. **Configure Environment for Hadoop**
    Update `~/.bashrc` or `~/.profile`:
    ```bash
    echo 'export HADOOP_HOME=/usr/local/hadoop' >> ~/.bashrc
    echo 'export PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin' >> ~/.bashrc
    source ~/.bashrc
    ```

4. **Configure Hadoop**
    Edit the configuration files in `/usr/local/hadoop/etc/hadoop/` to set up HDFS, YARN, and MapReduce settings. Detailed configurations for `core-site.xml`, `hdfs-site.xml`, `mapred-site.xml`, and `yarn-site.xml` are needed can be found in this folder.
    Note: use `hdfs-site1.xml`for master node, `hdfs-site2.xml` for worker nodes.

5. **SSH Key Configuration**
	Enable passwordless SSH access among nodes:
	1. Generate an SSH key pair (skip if already done):
		```bash
	   ssh-keygen
	   ```
	1. Copy the public key to each worker node's `~/.ssh/authorized_keys`.

5. **Initialize and Start HDFS**
    - Format the HDFS namenode on the master node:
      ```bash
      hdfs namenode -format
      ```
    - Start HDFS and YARN services:
      ```bash
      start-dfs.sh
      start-yarn.sh
      ```

6. **Data Operations**
    Create a directory and upload data to HDFS:
    ```bash
    hdfs dfs -mkdir -p /user/ubuntu
    hdfs dfs -put /home/ubuntu/input /user/ubuntu
    ```


## Conclusion

This guide outlines the setup for a distributed Apache Spark and HDFS cluster for project. 
