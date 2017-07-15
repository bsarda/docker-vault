#!/bin/sh
touch /tmp/letitrun
echo "Starting the container"

# change the listener
if [ $ENABLE_SSL = "false" ]; then
  echo "Configuring listener without certificates"
  sed -i '/^listener/,/}/c listener "tcp" {\n  address = "0.0.0.0:8200"\n  tls_disable = 1\n}' /var/local/vault/vault.conf
  # export new url
  export VAULT_ADDR=http://127.0.0.1:8200
else
  echo "Configuring listener WITH certificates"
  #sed -i '/^listener/,/}/c listener "tcp" {\n  address = "0.0.0.0:8200"  tls_disable = 0\n  tls_cert_file = "\/data\/cert.pem"\n  tls_key_file = "\/data\/key.pem"\n  tls_require_and_verify_client_cert = "false"\n}' /var/local/vault/vault.conf
  sed -i '/^listener/,/}/c listener "tcp" {\n  address = "0.0.0.0:8200"\n  tls_disable = 0\n  tls_cert_file = "\/var\/local\/vault\/cert.pem"\n  tls_key_file = "\/var\/local\/vault\/key.pem"\n  tls_require_and_verify_client_cert = "false"\n}' /var/local/vault/vault.conf
  # export new url
  export VAULT_ADDR=https://127.0.0.1:8200
fi

# if already initialized or not
if [ ! -f /var/local/vault/init ]; then
    echo "This is the first launch - will init Vault"
    cp /var/local/vault/cert.pem /data/cert.pem && cp /var/local/vault/key.pem /data/key.pem
    # start server
    nohup vault server -config /var/local/vault/vault.conf &
    sleep 5
    # launch init
    vault init -tls-skip-verify > /tmp/vaultinit.out
    # find the keys and token
    unsealKey1=$(cat /tmp/vaultinit.out | grep "Unseal Key 1" | awk -F':' '{print $2}' | sed 's/ //')
    unsealKey2=$(cat /tmp/vaultinit.out | grep "Unseal Key 2" | awk -F':' '{print $2}' | sed 's/ //')
    unsealKey3=$(cat /tmp/vaultinit.out | grep "Unseal Key 3" | awk -F':' '{print $2}' | sed 's/ //')
    unsealKey4=$(cat /tmp/vaultinit.out | grep "Unseal Key 4" | awk -F':' '{print $2}' | sed 's/ //')
    unsealKey5=$(cat /tmp/vaultinit.out | grep "Unseal Key 5" | awk -F':' '{print $2}' | sed 's/ //')
    token=$(cat /tmp/vaultinit.out | grep "Initial Root Token" | awk -F':' '{print $2}' | sed 's/ //')
    rm /tmp/vaultinit.out
    # keep this info for reboots
    echo $unsealKey1 > /var/local/vault/unsealKey1
    echo $unsealKey2 > /var/local/vault/unsealKey2
    echo $unsealKey3 > /var/local/vault/unsealKey3
    echo $unsealKey4 > /var/local/vault/unsealKey4
    echo $unsealKey5 > /var/local/vault/unsealKey5
    # unseal for use
    vault unseal -tls-skip-verify $unsealKey1
    vault unseal -tls-skip-verify $unsealKey2
    vault unseal -tls-skip-verify $unsealKey3
    # create flag file
    touch /var/local/vault/init;
    echo "Vault Initialized. Note the token for use:"
    echo "================= TOKEN TO USE ================="
    echo $token
else
    echo "Vault Already initialized, unseal only"
    # start server
    nohup vault server -config /var/local/vault/vault.conf &
    sleep 5
    # read from files
    if [ ! -f /data/unsealKey1 ]; then
      # seems to be an update... moving to standard location
      mv /data/unsealKey1 /var/local/vault/unsealKey1
      mv /data/unsealKey2 /var/local/vault/unsealKey2
      mv /data/unsealKey3 /var/local/vault/unsealKey3
      mv /data/unsealKey4 /var/local/vault/unsealKey4
      mv /data/unsealKey5 /var/local/vault/unsealKey5
    fi
    unsealKey1=$(cat /var/local/vault/unsealKey1)
    unsealKey2=$(cat /var/local/vault/unsealKey2)
    unsealKey3=$(cat /var/local/vault/unsealKey3)
    # unseal for use
    vault unseal -tls-skip-verify $unsealKey1
    vault unseal -tls-skip-verify $unsealKey2
    vault unseal -tls-skip-verify $unsealKey3
fi

# wait in an infinite loop for keeping alive pid1
trap '/bin/sh -c "/usr/local/bin/stop.sh"' SIGTERM
while [ -f /tmp/letitrun ]; do sleep 1; done
exit 0;
