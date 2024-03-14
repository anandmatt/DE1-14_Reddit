# Setup for Apache Spark cluster using Docker Swarm

This README is a detailed set of instructions to set up an Apache Spark cluster consisting of a master, workers and a driver on a Docker Swarm hosted on Linux (Ubuntu) Virtual Machines (VMs).

## Set up Docker images

Docker files for each of the required images can be found in this directory. 

The 'base' Dockerfile creates a basic environment with Spark, packages to get Spark like wget and all the dependencies required to run Spark such as Java and Scala installed. Basic Spark environment variables are also set.

The 'master' Dockerfile uses the 'base' as the starting point, installs certain dependencies like numpy, pandas etc and exposes ports 7077 and 8080. It also starts the command to launch the Spark Master when run.

The 'worker' Dockerfile uses the 'base' as the starting point, installs dependencies like numpy, pandas etc and exposes ports 8081-8085. It also starts the command to launch the Spark Worker and attach to the "sparkmaster" open on port 7077 when run.

The 'driver' Dockerfile uses the 'base' as the starting point, installs dependencies like numpy, pandas etc, installs Jupyterlab for analysis and exposes ports 4040 and 8888. 

The following commands are used to build the docker images:

    ```bash
    docker build -f Dockerfile_base -t anandmatt/spark_base
    docker build -f Dockerfile_master -t anandmatt/spark_master
    docker build -f Dockerfile_worker -t anandmatt/spark_worker
    docker build -f Dockerfile_driver -t anandmatt/spark_driver
    ```


For ease of deployment, the Docker images are built only once and pushed to Dockerhub. They can be pulled using the following command:

    ```bash
    docker pull anandmatt/spark_master
    docker pull anandmatt/spark_worker
    docker pull anandmatt/spark_driver
    ```

## Set up Docker Swarm

Docker Swarm follows a Leader-Worker architecture. One of the nodes is selected as the leader and the following command is executed to start the Swarm with this node as the Leader

    ```bash
    docker swarm init
    ```

This will result in a join token which is pasted in the other nodes which make them worker nodes in the swarm.

To verify nodes connected to the swarm, the following command can be executed in the Leader node

    ```bash
    docker node ls
    ```

This command doesnt work on worker nodes

An overlay network is then created to connect the Spark cluster over the network. Overlay networks enable containers to communicate with each other. On the leader node execute the following command:

    ```bash
    docker network create --driver overlay --attachable sparknet
    ```

To verify that the overlay network is created, the following command can be executed in the Leader node

    ```bash
    docker network ls
    ```

This command can be executed on worker nodes but will display the overlay network only if there is a container created that uses the overlay network.

## Run Containers

The Spark Master, Worker nodes and Driver can be run in separate containers using the following commands:

Spark Master command is executed on Swarm Leader.

    ```bash
    docker run -it --name spark-master --network sparknet -p 8080:8080 -p 7077:7077 --hostname sparkmaster anandmatt/spark_master:latest
    ```

Here, the container is named spark-master which is referenced later by the MASTER_CONTAINER_NAME environment variable of spark-driver. The conatiner is deployed in the "sparknet" overlay network. Exposed ports 8080 and 7077 are published to the VM so that the Web UI (8080) of Sparkmaster can be accessed in localhost of user machine if port forwarding is performed on the VM and Spark Master port (7077) is accessible by containers in other VMs on the network (Connection issues may occur if ip and hostname are not present in /etc/hosts). The Spark Master container is also set as "sparkmaster".

Spark Workers can be run on worker nodes with the following command:

    ```bash
    docker run -it --name spark-worker1 --network sparknet -p 8081:8081 anandmatt/spark_worker:latest
    ```

Here too, the "sparknet" overlay network is defined and exposed port 8081 is published for testing.

Spark Driver is run on one of the nodes using the following command:

    ```bash
    docker run -it --name spark-driver --network sparknet -p 4040:4040 -p 8888:8888 anandmatt/spark_driver:latest bash
    ```

The "sparknet" overlay network is referenced again. Exposed port 4040 is published to track jobs being run on the spark cluster and port 8888 is published for accessing JupyterLab to run jobs.

## Conclusion

The above steps presemt a systematic way to set up a Spark cluster connected by Docker Swarm. The process can be automated by using a docker-compose.yml file to define the different containers and execute the following command to deploy it as a stack of services.

    ```bash
    docker stack deploy --compose-file docker-compose.yml spark-stack
    ```

However, we ran into issues using the above method and so decided to continue with the method that worked. Future efforts may be taken to identify the cause and resolve the issues faced.
