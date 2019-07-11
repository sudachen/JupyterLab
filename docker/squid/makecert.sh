
set -x
openssl=/usr/bin/openssl

# $openssl genrsa -out proxy-ca.key 2048
# $openssl genrsa -out proxy-int.key 2048

# $openssl req -x509 \
#     -new -nodes -key proxy-ca.key \
#     -sha256 \
#     -days 3600 \
#     -out proxy-ca.pem \
#     -subj '/C=CL/ST=None/O=Proxy/CN=Proxy Root CA/emailAddress=proxy@proxy.local'

# $openssl req \
#    -new -key proxy-int.key \
#     -out proxy-ca.csr \
#     -subj '/C=CL/ST=None/O=Proxy/CN=Proxy Intemediate CA/emailAddress=proxy@proxy.local'

# $openssl x509 -req \
#     -in proxy-int.csr -CA proxy-ca.pem -CAkey proxy-ca.key -CAcreateserial \
#     -sha256 \
#     -days 3600 \
#     -out proxy-int.pem 
#     -extfile proxy-int.txt
# cat proxy-int.pem proxy-ca.pem > proxy-chain.pem
# cat proxy-int.key proxy-int.pem proxy-ca.pem > proxy-int.crt


$openssl req \
    -new \
    -newkey rsa:2048 \
    -sha256 \
    -days 3650 \
    -nodes \
    -x509 \
    -extensions v3_ca \
    -keyout proxy-ca.key \
    -out proxy-ca.pem \
    -subj '/C=CL/ST=None/O=Proxy/CN=Proxy Root CA/emailAddress=proxy@proxy.local'

cat proxy-ca.key proxy-ca.pem > proxy-ca.crt
$openssl x509 -in proxy-ca.pem -outform DER -out proxy-ca.der

$openssl genrsa -out proxy-int.key 2048
$openssl req \
   -new -key proxy-int.key \
    -out proxy-ca.csr \
    -subj '/C=CL/ST=None/O=Proxy/CN=Proxy Intemediate CA/emailAddress=proxy@proxy.local'

$openssl x509 -req \
    -in proxy-int.csr -CA proxy-ca.pem -CAkey proxy-ca.key -CAcreateserial \
    -sha256 \
    -days 3600 \
    -out proxy-int.pem

cat proxy-int.key proxy-int.pem proxy-ca.pem > proxy-int.crt
