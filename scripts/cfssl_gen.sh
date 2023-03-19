#!/bin/sh
# Example:
# ./cfssl_gen.sh worker-0:192.169.1,worker-1:192.169.2,worker-2:192.169.3

# Generate certificate authority certificate
echo "Generating certificate authority certificate..."
cfssl gencert \
      -initca ca_csr.json | cfssljson -bare ca
echo "Certificate authority certificate generated.\n\n"

# Generate admin client certificate
echo "Generating admin client certificate..."
cfssl gencert \
      -ca=ca.pem \
      -ca-key=ca-key.pem \
      -config=ca_config.json \
      -profile=kubernetes \
      admin_csr.json | cfssljson -bare admin
echo "Admin client certificate genreated.\n\n"

# Generate kubelet client certificates
c=0
limit=`echo $1 | sed 's/[^,]//g' | awk '{ print length + 1 }'`

while [ $c -lt $limit ]
do
    workerName=`echo $1 | cut -d"," -f$((c+1)) | cut -d":" -f1`
    ip=`echo $1 | cut -d"," -f$((c+1)) | cut -d":" -f2`

    echo "Generating $workerName certificate..."

    cat > "$workerName"-csr.json <<EOF
{
  "CN": "system:node:$workerName",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "France",
      "L": "Lille",
      "O": "system:nodes",
      "OU": "Kubernetes The Hard Way",
      "ST": "Nord"
    }
  ]
}
EOF
    cfssl gencert \
          -ca=ca.pem \
          -ca-key=ca-key.pem \
          -config=ca-config.json \
          -hostname=$ip \
          -profile=kubernetes \
          "$workerName"-csr.json | cfssljson -bare $workerName

    echo "$workerName certificate done\n\n"
    c=$((c + 1))
done

# Generate kube-controller-manager certificate
echo "Generating kube-controller-manager certificate..."
cfssl gencert \
      -ca=ca.pem \
      -ca=ca-key.pem \
      -config=ca_config.json \
      -profile=kubernetes \
      kube_controller_manager_csr.json | cfssljson -bare kube-controller-manager
echo "Kube-controller-manager certificate generated.\n\n"


# Generate kube-proxy certificate
echo "Generating kube-proxy certificate..."
cfssl gencert \
      -ca=ca.pem \
      -ca-key=ca-key.pem \
      -config=ca_config.json \
      -profile=kubernetes \
      kube_proxy_csr.json | cfssljson -bare kube-proxy
echo "kube-proxy certificate generated.\n\n"

# Generate kube-apiserver certificate
echo "Generating kube-apiserver certificate..."
cfssl gencert \
      -ca=ca.pem \
      -ca-key=ca-key.pem \
      -config=ca_config.json \
      -hostname=192.168.1.50,127.0.0.1,kubernetes,kubernetes.default,kubernetes.default.svc,kubernetes.default.svc.cluster,kubernetes.svc.cluster.local \
      -profile=kubernetes \
      kubernetes_csr.json | cfssljson -bare kubernetes
echo "kube-apiserver certificate generated.\n\n."

# Generate service account certificate
echo "Generating service account certificate..."
cfssl gencert \
      -ca=ca.pem \
      -ca-key=ca-key.pem \
      -config=ca-config.json \
      -profile=kubernetes \
      service_account_csr.json | cfssljson -bare service-account
echo "service account certificate generated."
