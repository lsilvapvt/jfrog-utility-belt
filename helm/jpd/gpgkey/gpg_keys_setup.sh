# requires the gpg tool installed on the client  -  brew install gpg (for Mac)

export JFROG_PROTOCOL="http"
export JFROG_URL=DOMAIN_OR_IP
export USER_ID=MY_USER_ID
export ENCRYPTED_PWD=MY_PWD

# generate the gpg key in non-interactive mode
# https://www.gnupg.org/documentation/manuals/gnupg-devel/Unattended-GPG-key-generation.html
# https://gist.github.com/woods/8970150
gpg --batch --generate-key <<EOF
  Key-Type: RSA
  Key-Length: 2048
  Subkey-Type: RSA
  Subkey-Length: 2048
  Name-Real: acmedist
  Name-Email: acme@jfrog.com
  Expire-Date: 0
  %no-ask-passphrase
  %no-protection
  %commit
  %echo done
EOF

# export Private Key
gpg --output acmedistkey.gpg --armor --yes --export-secret-keys acmedist

# export Public Key
gpg --output acmedistpub.gpg --armor --yes --export acmedist

# just in case, example to replace new line with \n and convert into a one liner
#      awk 'NF {sub(/\r/, ""); printf "%s\\n",$0;}' acmedistpub.gpg
# example on how to remove last empty line of the gpg files 
#     sed '${/^$/d;}' acmedistpub.gpg > tmppub.gpg 

export PUBLICKEY=$(cat acmedistpub.gpg)
export PRIVATEKEY=$(cat acmedistkey.gpg)
cat > acmegpgkey.json <<EOF
{
  "key": {
     "alias": "default-gpg-key",
     "public_key" : "$PUBLICKEY",
     "private_key": "$PRIVATEKEY"
  },
  "propagate_to_edge_nodes" : true,
  "fail_on_propagation_failure": false,
  "set_as_default": true
}  
EOF

## Upload GPG Signing Key for Distribution (api)

# API failed when using Access Token
# curl -H "Authorization: Bearer $JFROG_ACCESSTOKEN" -X POST $JFROG_PROTOCOL://$JFROG_URL/distribution/api/v1/keys/gpg/ -H 'Content-Type: application/json' -T acmegpgkey.json
# use basic auth instead 
curl -u $USER_ID:$ENCRYPTED_PWD \
 -X POST $JFROG_PROTOCOL://$JFROG_URL/distribution/api/v1/keys/gpg \
 -H "Accept: application/json" \
 -H 'Content-Type: application/json' \
 -T acmegpgkey.json

#  curl -u $USER_ID:$ENCRYPTED_PWD -X GET $JFROG_PROTOCOL://$JFROG_URL/distribution/api/v1/keys/ 
