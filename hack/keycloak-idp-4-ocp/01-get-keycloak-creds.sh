oc get secret -n keycloak credential-keycloak-sso -ojsonpath='{.data.ADMIN_PASSWORD}' | base64 --decode
oc get secret -n keycloak credential-keycloak-sso -ojsonpath='{.data.ADMIN_USERNAME}' | base64 --decode

