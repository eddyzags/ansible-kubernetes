#!/bin/sh

OUTPUT_FOLDER=./output/encryption
ENCRYPTION_KEY=$(head -c 32 /dev/urandom | base64)

if [ ! -d $OUTPUT_FOLDER ]
then
    echo "Creating $OUTPUT_FOLDER..."
    mkdir -p $OUTPUT_FOLDER
fi

cat > output/encryption/encryption-config.yaml <<EOF
kind: EncryptionConfig
apiVersion: v1
resources:
  - resources:
      - secrets
    providers:
      - aescbc:
          keys:
            - name: key1
              secret: ${ENCRYPTION_KEY}
      - identity: {}
EOF

echo "encryption-config.yaml file generated"
