#!/bin/bash


echo "keycloak client name: idp-4-ocp"

export KEYCLOAK_CLIENT_CREDENTIALS=60642b2d-3719-4e01-a681-bb1f1e3db254

oc -n openshift-config create secret generic keycloak-client-secret --from-literal=clientSecret=${KEYCLOAK_CLIENT_CREDENTIALS}

oc -n openshift-ingress-operator get secret router-ca -o jsonpath="{ .data.tls\.crt }" | base64 -d > ca.crt

oc -n openshift-config create cm keycloak-ca --from-file=ca.crt




