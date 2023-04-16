#!/bin/sh
# Example:
# ./certificates_gen.sh worker-0:192.169.1.0,worker-1:192.169.1.1,worker-2:192.169.1.2

OUTPUT_FOLDER=./output/certs/config


if [ ! -d $OUTPUT_FOLDER ]
then
    echo "Creating $OUTPUT_FOLDER..."
    mkdir -p $OUTPUT_FOLDER
fi

# Generate certificate authority certificate
echo "Generating certificate authority certificate..."

cat > output/certs/config/ca_csr.json <<EOF
{
    "CN": "Kubernetes",
    "key": {
        "algo": "rsa",
        "size": 2048
    },
    "names": [
        {
            "C": "FR",
            "L": "Lille",
            "O": "Kubernetes",
            "OU": "k8s",
            "ST": "Nord"
        }
    ]
}
EOF

cat > output/certs/config/ca_config.json <<EOF
{
  "signing": {
    "default": {
      "expiry": "8760h"
    },
    "profiles": {
      "kubernetes": {
        "usages": ["signing", "key encipherment", "server auth", "client auth"],
        "expiry": "8760h"
      }
    }
  }
}
EOF

cfssl gencert \
      -initca output/certs/config/ca_csr.json | output/cfssl/bin/cfssljson -bare -output output/certs ca
echo "Certificate authority certificate generated.\n\n"

# Generate admin client certificate
echo "Generating admin client certificate..."

cat > output/certs/config/admin_csr.json <<EOF
{
    "CN": "admin",
    "key": {
        "algo": "rsa",
        "size": 2048
    },
    "names": [
        {
            "C": "FR",
            "L": "Lille",
            "O": "system:masters",
            "OU": "k8s",
            "ST": "Nord"
        }
    ]
}
EOF

cfssl gencert \
      -ca=output/certs/ca.pem \
      -ca-key=output/certs/ca-key.pem \
      -config=output/certs/config/ca_config.json \
      -profile=kubernetes \
      output/certs/config/admin_csr.json | output/cfssl/bin/cfssljson -bare -output output/certs admin
echo "Admin client certificate genreated.\n\n"

# Generate kubelet client certificates
c=0
limit=`echo $1 | sed 's/[^,]//g' | awk '{ print length + 1 }'`;

while [ $c -lt $limit ]
do
    workerName=`echo $1 | cut -d"," -f$((c+1)) | cut -d":" -f1`
    ip=`echo $1 | cut -d"," -f$((c+1)) | cut -d":" -f2`

    echo "Generating $workerName certificate..."

    cat > output/certs/config/"$workerName"_csr.json <<EOF
{
  "CN": "system:node:$workerName",
  "key": {
    "algo": "rsa",
    "size": 2048
 },
  "names": [
    {
      "C": "FR",
      "L": "Lille",
      "O": "system:nodes",
      "OU": "k8s",
      "ST": "Nord"
    }
  ]
}
EOF
    cfssl gencert \
          -ca=output/certs/ca.pem \
          -ca-key=output/certs/ca-key.pem \
          -config=output/certs/config/ca_config.json \
          -hostname=$ip,$workerName \
          -profile=kubernetes \
          output/certs/config/"$workerName"_csr.json | output/cfssl/bin/cfssljson -bare -output output/certs $workerName

    echo "$workerName certificate done\n\n"
    c=$((c + 1))
done

# Generate kube-controller-manager certificate
echo "Generating kube-controller-manager certificate..."

cat > output/certs/config/kube_controller_manager_csr.json <<EOF
{
  "CN": "system:kube-controller-manager",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "FR",
      "L": "Lille",
      "O": "system:kube-controller-manager",
      "OU": "k8s",
      "ST": "Nord"
    }
  ]
}
EOF

cfssl gencert \
      -ca=output/certs/ca.pem \
      -ca-key=output/certs/ca-key.pem \
      -config=output/certs/config/ca_config.json \
      -profile=kubernetes \
      output/certs/config/kube_controller_manager_csr.json | output/cfssl/bin/cfssljson -bare -output output/certs kube-controller-manager
echo "Kube-controller-manager certificate generated.\n\n"


# Generate kube-proxy certificate
echo "Generating kube-proxy certificate..."

cat > output/certs/config/kube_proxy_csr.json <<EOF
{
  "CN": "system:kube-proxy",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "FR",
      "L": "Lille",
      "O": "system:node-proxier",
      "OU": "k8s",
      "ST": "Nord"
    }
  ]
}
EOF

cfssl gencert \
      -ca=output/certs/ca.pem \
      -ca-key=output/certs/ca-key.pem \
      -config=output/certs/config/ca_config.json \
      -profile=kubernetes \
      output/certs/config/kube_proxy_csr.json | output/cfssl/bin/cfssljson -bare -output output/certs kube-proxy
echo "kube-proxy certificate generated.\n\n"


echo "Generating kube-scheduler certificate..."

cat > output/certs/config/kube-scheduler-csr.json <<EOF
{
  "CN": "system:kube-scheduler",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "FR",
      "L": "Lille",
      "O": "system:kube-scheduler",
      "OU": "k8s",
      "ST": "Nord"
    }
  ]
}
EOF

cfssl gencert \
      -ca=output/certs/ca.pem \
      -ca-key=output/certs/ca-key.pem \
      -config=output/certs/config/ca_config.json \
      -profile=kubernetes \
      output/certs/config/kube-scheduler-csr.json | output/cfssl/bin/cfssljson -bare -output output/certs kube-scheduler

echo "kube-scheduler certificate generated...\n\n"

# Generate kube-apiserver certificate
echo "Generating kube-apiserver certificate..."

cat > output/certs/config/kubernetes_csr.json <<EOF
{
    "CN": "kubernetes",
    "key": {
        "algo": "rsa",
        "size": 2048
    },
    "names": [
        {
        "C": "FR",
        "L": "Lille",
        "O": "Kubernetes",
        "OU": "k8s",
        "ST": "Nord"
        }
    ]
}
EOF

cfssl gencert \
      -ca=output/certs/ca.pem \
      -ca-key=output/certs/ca-key.pem \
      -config=output/certs/config/ca_config.json \
      -hostname=192.168.1.50,10.0.2.1,127.0.0.1,yard-1,kubernetes,kubernetes.default,kubernetes.default.svc,kubernetes.default.svc.cluster,kubernetes.svc.cluster.local \
      -profile=kubernetes \
      output/certs/config/kubernetes_csr.json | output/cfssl/bin/cfssljson -bare -output output/certs kubernetes
echo "kube-apiserver certificate generated.\n\n"

# Generate service account certificate
echo "Generating service account certificate..."

cat > output/certs/config/service_account_csr.json <<EOF
{
  "CN": "service-accounts",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "FR",
      "L": "Lille",
      "O": "Kubernetes",
      "OU": "k8s",
      "ST": "Nord"
    }
  ]
}
EOF

cfssl gencert \
      -ca=output/certs/ca.pem \
      -ca-key=output/certs/ca-key.pem \
      -config=output/certs/config/ca_config.json \
      -profile=kubernetes \
      output/certs/config/service_account_csr.json | output/cfssl/bin/cfssljson -bare -output output/certs service-account
echo "service account certificate generated."
