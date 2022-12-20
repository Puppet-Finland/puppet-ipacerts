# ipacerts

## Description

A module for managing 3rd party certificates for FreeIPA.

## Setup

Define a hash, like

```
1: 'https://www.tbs-x509.com/Comodo_AAA_Certificate_Services.crt'
2: 'https://www.tbs-x509.com/USERTrustRSAAAACertificateServices.crt'
3: 'https://comodo.tbs-certificats.com/SectigoRSADomainValidationSecureServerCA.crt'
```
Note: The order is critically important. Define it in order from root CA to intermediates to the end-of-chain.

Then declare the class:

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
See manifests/init for more parameters and data/common.yaml for defaults.

### Requirements

This module depends on easy_ipa modules and is meant to supplement it.

## Limitations

* Setting 
Many for now. Minimally tested. I can think of many cases where it fails. Removing 

## TODO

* Create rspec tests
* Allow multiple CA certificate chains and certificate/key pairs (with defines)
* Better documentation
* Certificate NSS nickames based on certificate subject
* Change CAs, certificates and keys on the fly
* Support removing/changing Webui and CA certificates at the same time
