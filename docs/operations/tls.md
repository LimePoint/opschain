# TLS (Transport Layer Security)

## Accessing the OpsChain API via HTTPS

To enable HTTPS access to the OpsChain API, specify a host name via the OPSCHAIN_API_HOST_NAME environment variable.

```shell
echo OPSCHAIN_API_HOST_NAME=opschain.my-company.com >> .env
opschain server configure
opschain server deploy
```

Configure a DNS entry for this host name to point to the external address of the opschain-ingress-proxy load balancer.

After you have deployed OpsChain, you can run the following command to obtain the external address:

```shell
kubectl get svc -n opschain opschain-ingress-proxy -o jsonpath='{.status.loadBalancer.ingress[]}'
```

Depending on your Kubernetes load balancer implementation, the command will either return an IP address or a host name that you can use to configure your DNS entry.

### API certificate

By default, OpsChain will issue a certificate for the HTTPS listener from the internal opschain-ca certificate authority.

To use a custom certificate for the HTTPS listener, create a [Kubernetes TLS secret](https://kubernetes.io/docs/concepts/configuration/secret/#tls-secrets) that contains your custom certificate and private key and set the value of OPSCHAIN_API_CERTIFICATE_SECRET_NAME to the name of your secret.

```shell
kubectl -n opschain create secret tls my-custom-certificate --cert=path/to/tls.cert --key=path/to/tls.key
echo OPSCHAIN_API_CERTIFICATE_SECRET_NAME=my-custom-certificate >> .env
opschain server configure
opschain server deploy
```

## Configure the OpsChain CLI to trust a certificate authority

If you want to the use the default certificate issued by the opschain-ca certificate authority or use a custom certificate that is signed by a private certificate authority, you will need to configure the OpsChain CLI to trust any certificates issued by the CA.

To do this, you can set the NODE_EXTRA_CA_CERTS environment variable to a file path that contains the CA certificate.

For example, to configure the CLI to trust the internal opschain-ca certificate authority, run the following:

```shell
kubectl -n opschain get secret opschain-ca-key-pair -o jsonpath="{.data.ca\.crt}" | base64 -d > opschain-ca.pem
export NODE_EXTRA_CA_CERTS=path/to/opschain-ca.pem
```

## Disable the insecure HTTP listener

Once the OpsChain API HTTPS listener has been successfully configured, you can disable the insecure HTTP listener so that OpsChain is only accessible via HTTPS. To disable the HTTP port, edit `.env` file and set `OPSCHAIN_INSECURE_HTTP_PORT_ENABLED` to `false`, apply the update by running the following:

```bash
opschain server configure
opschain server deploy
```
