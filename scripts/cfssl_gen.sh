#!/bin/sh

# Generate certificate authority private & public key
cfssl gencert \
      -init-ca ca_csr.json | cfssljson -bare ca

# Generate admin client certificate (public and private key)
cfssl gencert \
      -ca=ca.pem \
      -ca-key=ca-key.pem \
      -config-ca=ca_config.json \
      -profile=kubernetes \
      admin_csr.json | cfssljson -bare admin



