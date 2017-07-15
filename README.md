# docker-vault
Hashicorp Vault base container on *Alpine Linux*.  
Uses the file backend at the moment. the etcd and consul backend would come after.

 
## Usage
Run the container:  
`docker run  --cap-add=IPC_LOCK  -d -v vault:/data --name vault -p 8200:8200 bsarda/vault`
this container exports volume /data, which contains the flat file database.
The docker stop and docker start will keep the secrets (not in memory) and seal/unseal to keep it usable.  

Then note the token to use for operations:  
`docker logs vault`  
reports the token below the === TOKEN TO USE ===  
and use it as an header: X-Vault-Token = <value-noted>


## Options as environment vars
- ENABLE_SSL => default 'true'  
- SSL_COUNTRY => default 'FR'  
- SSL_STATE => default 'IDF'  
- SSL_LOCALITY => default 'Paris'  
- SSL_ORG => default 'Company'  
- SSL_OU => default 'IT'  


## REST Ops quick ref
Quick refs for rest operations  
get list of secrets  
`  GET https://192.168.63.5:8200/v1/secret/?list=true`  
post a new secret  
`  POST https://192.168.63.5:8200/v1/secret/foo  ,  body= {"value":"bar"}`  
get it  
```  GET https://192.168.63.5:8200/v1/secret/foo
  response: {
    "request_id": "63690b23-be23-b72e-b5b2-ecc53c8d7ded",
    "lease_id": "",
    "renewable": false,
    "lease_duration": 0,
    "data": {
      "keys": [
        "foo",
        "bsa"
      ]
    },
    "wrap_info": null,
    "warnings": null,
    "auth": null
  }
```

Sample for 1Password import-able:  
```
POST https://192.168.63.5:8200/v1/secret/srv01/username body: {"value":"admin"}  
POST https://192.168.63.5:8200/v1/secret/srv01/password body: {"value":"P@ssw0rd!s"}  
POST https://192.168.63.5:8200/v1/secret/srv01/notes body: {"value":"P@ssw0rd"}  
POST https://192.168.63.5:8200/v1/secret/srv01/url body: {"value":"http://srv01.corp.local:8443/ui"}  
GET https://192.168.63.5:8200/v1/secret/?list=true  
GET https://192.168.63.5:8200/v1/secret/srv01/?list=true  
GET https://192.168.63.5:8200/v1/secret/srv01/password  
```


## Misc
additionnaly, use a client cert for auth  
https://jovandeginste.github.io/2016/07/20/use-vault-with-client-certificates.html
