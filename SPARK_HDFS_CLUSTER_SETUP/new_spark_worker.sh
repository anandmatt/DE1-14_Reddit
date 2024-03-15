#!/bin/bash

# Define variables
MASTER_IP="your_master_ip_here"
SPARK_VERSION="spark-3.5.1"
HADOOP_VERSION="hadoop3"
JAVA_VERSION="java-17-openjdk-amd64"
SPARK_DOWNLOAD_URL="https://dlcdn.apache.org/spark/spark-3.5.1/${SPARK_VERSION}-bin-${HADOOP_VERSION}.tgz"

# Update package list
echo "Updating package list..."
sudo apt update

# Install OpenJDK 17
echo "Installing OpenJDK 17..."
sudo apt install -y openjdk-17-jdk

# Set JAVA_HOME Globally
echo "Setting JAVA_HOME environment variable..."
echo "JAVA_HOME=\"/usr/lib/jvm/${JAVA_VERSION}\"" | sudo tee -a /etc/environment > /dev/null
source /etc/environment
echo "JAVA_HOME set to $JAVA_HOME"

# Download Apache Spark
echo "Downloading Apache Spark..."
wget -q ${SPARK_DOWNLOAD_URL}

# Extract and Move Spark
echo "Installing Apache Spark..."
tar xvf ${SPARK_VERSION}-bin-${HADOOP_VERSION}.tgz
sudo mv ${SPARK_VERSION}-bin-${HADOOP_VERSION} /opt/spark

# Configure Spark environment
echo "Configuring Spark environment..."
echo "export SPARK_HOME=/opt/spark" >> ~/.bashrc
echo "export PATH=\$PATH:\$SPARK_HOME/bin:\$SPARK_HOME/sbin" >> ~/.bashrc
source ~/.bashrc

# Configure spark-env.sh
cp /opt/spark/conf/spark-env.sh.template /opt/spark/conf/spark-env.sh
echo "export JAVA_HOME=${$JAVA_HOME}" >> /opt/spark/conf/spark-env.sh
echo "export SPARK_MASTER_HOST=${MASTER_IP}" >> /opt/spark/conf/spark-env.sh

# Start Spark worker
echo "Starting Spark worker..."
/opt/spark/sbin/start-worker.sh spark://${MASTER_IP}:7077

echo "Spark worker has been started and connected to the master at spark://${MASTER_IP}:7077"