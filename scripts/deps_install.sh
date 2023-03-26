#!/bin/sh

git clone --branch feat/cfssljson-output git@github.com:eddyzags/cfssl.git output/cfssl
make -C output/cfssl bin/cfssljson
