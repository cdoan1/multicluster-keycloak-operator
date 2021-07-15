#!/bin/bash

set -x

export HUB_BASEDOMAIN=$(oc cluster-info | grep running | cut -d':' -f2 | sed 's|//api.||g')

cat > 01-github-oauth-secret.yaml <<EOF
apiVersion: v1
kind: Secret
stringData:
  clientId: ${GITHUB_OAUTH_CLIENTID}
  clientSecret: ${GITHUB_OAUTH_CLIENTSECRET}
metadata:
  name: github-oauth-credentials
  namespace: keycloak
type: Opaque
EOF

cat > 03-sso-ad.yaml <<EOF
apiVersion: keycloak.open-cluster-management.io/v1alpha1
kind: AuthorizationDomain
metadata:
  name: sso-ad
  namespace: keycloak
spec:
  identityProviders:
  - type: github
    secretRef: github-oauth-credentials
  issuerURL: "https://keycloak-keycloak.${HUB_BASEDOMAIN}/auth/realms/sso-ad"
  issuerCertificate:
    configMapRef: ca-config-map
EOF

export CONSOLE_URL=$(oc get routes -A | grep console-openshift-console | awk '{print $3}')
openssl s_client -showcerts -servername $CONSOLE_URL -connect $CONSOLE_URL:443 </dev/null 2>/dev/null | openssl x509 -outform PEM | base64 > console-crt.encoded.pem

if [ ! -f console-crt.encoded.pem ]; then
  echo "no cert file consle-crt.encoded.pem found ..."
  exit 1
fi

cat > 02-hub-ca-trust-cert.yaml <<EOF
apiVersion:
kind: ConfigMap
metadata:
  name: ca-config-map
  namespace: keycloak
data:
  ca.crt: |
    $(cat console-crt.encoded.pem | base64 --decode)
EOF
