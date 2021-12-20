# Table of contents

1. [Install Kubernetes](#install-kubernetes)
2. [Set environment variables](#set-environment-variables)
3. [Create a namespace for ArmoniK](#create-a-namespace-for-armonik)
4. [Create Kubernetes secrets](#create-kubernetes-secrets)
    3. [Redis storage secret](#redis-storage-secret)
    4. [ActiveMQ storage secret](#activemq-storage-secret)

# Install Kubernetes <a name="install-kubernetes"></a>

Instructions to install Kubernetes on local Linux machine.

You can use [K3s Lightweight Kubernetes](https://rancher.com/docs/k3s/latest/en/) on Linux OS.

Install K3s as follows:

```bash
curl -sfL https://get.k3s.io | sh -
```

***Warning:*** If you want use host's Docker rather than containerd use `--docker` option:

```bash
curl -sfL https://get.k3s.io | sh -s - --docker
```

After the K3s installation, you initialize the configuration file of Kubernetes:

```bash
sudo chmod 644 /etc/rancher/k3s/k3s.yaml
mkdir -p ~/.kube
cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
```

# Set environment variables <a name="set-environment-variables"></a>

The project needs to define and set environment variables for deploying the infrastructure. The main environment
variables are:

```buildoutcfg
# Armonik namespace in the Kubernetes
export ARMONIK_NAMESPACE=<Your namespace in kubernetes>

# Directory path of the object storage credentials
export ARMONIK_OBJECT_STORAGE_CERTIFICATES_DIRECTORY=<Your directory path of the certificates for the object storage>
    
# Directory path of the object storage credentials
export ARMONIK_OBJECT_STORAGE_SECRET_NAME=<You kubernetes secret for the object storage>

# Directory path of the queue storage credentials
export ARMONIK_QUEUE_STORAGE_CREDENTIALS_DIRECTORY=<Your directory path of the credentials for the queue storage>
    
# Directory path of the queue storage credentials
export ARMONIK_QUEUE_STORAGE_SECRET_NAME=<You kubernetes secret for the queue storage>
```

**Mandatory:** To set these environment variables, for example:

1. position yourself in the current directory `localhost/`:

2. copy the [template file](../utils/envvars.conf) in the [current directory](../../localhost):

```bash
cp utils/envvars.conf ./envvars.conf
```

2. modify the values of variables if needed in `./envvars.conf`

3. Source the file of configuration :

```bash
source ./envvars.conf
```

# Create a namespace for ArmoniK <a name="create-a-namespace-for-armonik"></a>

**Mandatory:** Before deploring the ArmoniK resources, you must first create a namespace in the Kubernetes cluster for
ArmoniK:

```bash
kubectl create namespace $ARMONIK_NAMESPACE
```

You can see all active namespaces in your Kubernetes as follows:

```bash
kubectl get namespaces
```

# Create Kubernetes secrets <a name="create-kubernetes-secrets"></a>

## Redis storage secret <a name="redis-storage-secret"></a>

In this project, we use Redis as object storage for Armonik. Redis uses SSL/TLS support using certificates. In order to
support TLS, Redis is configured with a X.509 certificate (`cert.crt`) and a private key (`cert.key`). In addition, it
is necessary to specify a CA certificate bundle file (`ca.crt`) or path to be used as a trusted root when validating
certificates. A SSL certificate of type `PFX` is also used (`certificate.pfx`).

Execute the following command to create the object storage secret in Kubernetes based on the certificates created and
saved in the directory `$ARMONIK_OBJECT_STORAGE_CERTIFICATES_DIRECTORY`. In this project, we have certificates for test
in [credentials](../credentials) directory. Create a Kubernetes secret for the ArmoniK object storage:

```bash
kubectl create secret generic $ARMONIK_OBJECT_STORAGE_SECRET_NAME \
        --namespace=$ARMONIK_NAMESPACE \
        --from-file=cert_file=$ARMONIK_OBJECT_STORAGE_CERTIFICATES_DIRECTORY/cert.crt \
        --from-file=key_file=$ARMONIK_OBJECT_STORAGE_CERTIFICATES_DIRECTORY/cert.key \
        --from-file=ca_cert_file=$ARMONIK_OBJECT_STORAGE_CERTIFICATES_DIRECTORY/ca.crt \
        --from-file=certificate_pfx=$ARMONIK_OBJECT_STORAGE_CERTIFICATES_DIRECTORY/certificate.pfx
```

## ActiveMQ storage secret <a name="activemq-storage-secret"></a>

In this project, we use ActiveMQ as queue storage for Armonik. ActiveMQ use a file `jetty-realm.properties`. This is the
file which stores user credentials and their roles in ActiveMQ. It contains custom usernames and passwords and replace
the file present by default inside the container.

Execute the following command to create the queue storage secret in Kubernetes based on the `jetty-realm.properties`
created and saved in the directory `$ARMONIK_QUEUE_STORAGE_CREDENTIALS_DIRECTORY`. In this project, we have a file of
name `jetty-realm.properties` in [credentials](../credentials) directory. Create a Kubernetes secret for the ArmoniK
queue storage:

```bash
kubectl create secret generic $ARMONIK_QUEUE_STORAGE_SECRET_NAME \
        --namespace=$ARMONIK_NAMESPACE \
        --from-file=$ARMONIK_QUEUE_STORAGE_CREDENTIALS_DIRECTORY/jetty-realm.properties
```