## Description

A module for managing 3rd party certificates for FreeIPA.

## Setup

Define a hash in hiera:

```
1: 'https://www.tbs-x509.com/Comodo_AAA_Certificate_Services.crt'
2: 'https://www.tbs-x509.com/USERTrustRSAAAACertificateServices.crt'
3: 'https://comodo.tbs-certificats.com/SectigoRSADomainValidationSecureServerCA.crt'
```
Note: The order is critically important. Define it in order from root CA to intermediates to the end-of-chain.

Declare the class:

```
class {'::ipacerts':
  chainhash                  => $mychainhash,
  admin_password             => 'changeme',
  ipa_domain                 => 'MYIPA.EXAMPLE.COM',
  private_key_source         => puppet:///files/my.key,
  server_crt_source          => puppet:///files/my.crt,
  cert_nickname              => 'myipa.example.com',
}
```
See [init.pp](./manifest/init.pp) for more parameters and [common.yaml](./data/common.yaml) for defaults.

## Requirements

This module depends on easy_ipa modules and is meant to supplement it.

## Limitations

* Ensuring that CA certs and Webui certs are absent when they are currently present does not work. ca_force_absent is a stupid workaround.
* Minimally tested.
* Many others

## TODO

* Create rspec tests
* Allow multiple CA certificate chains and certificate/key pairs (with defines)
* Better documentation
* Certificate NSS nickames based on certificate subject
* Change CAs, certificates and keys on the fly
* Support removing/changing Webui and CA certificates at the same time
* Manage case where one any of the CAs AND/OR the webui cert/key has been changed
