#!/bin/bash

# Prompt for adding worker nodes IPs or hostnames
read -p "Do you want to add worker nodes now? (yes/no): " add_workers_reply
if [[ $add_workers_reply == "yes" ]]; then
    read -p "Enter worker nodes' IPs or hostnames separated by space: " -a worker_ips
fi

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

# Setup spark-env.sh for Master
cp /opt/spark/conf/spark-env.sh.template /opt/spark/conf/spark-env.sh
echo "export JAVA_HOME=${JAVA_HOME}" >> /opt/spark/conf/spark-env.sh
# Set the master's IP or hostname
echo "SPARK_MASTER_HOST=${MASTER_IP} >> /opt/spark/conf/spark-env.sh

# Copy workers.template to workers and optionally add worker IPs or hostnames
cp /opt/spark/conf/workers.template /opt/spark/conf/workers
if [[ $add_workers_reply == "yes" && ${#worker_ips[@]} -gt 0 ]]; then
    for ip in "${worker_ips[@]}"; do
        echo $ip >> /opt/spark/conf/workers
    done
fi

# Start Spark master
echo "Starting Spark master..."
/opt/spark/sbin/start-master.sh

# Display Spark master UI address
echo "Apache Spark master setup completed."
echo "You can access the Spark master web UI at http://$(hostname -I | awk '{print $1}'):8080"
