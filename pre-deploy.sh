#!/bin/sh

APPNAME=komodo
TS_TAGS=tag:webserver,tag:komodo-core

# return code
RC=0

git submodule update --init --recursive

if [ ! -e .env ]; then
    touch .env
fi
chmod -f 600 .env

if ! grep -q "TS_AUTHKEY" .env; then
    if [ -z "$TS_API_CLIENT_ID" ]; then
        echo "ERROR: no tailscale oauth credentials provided"
        RC=1
    else
        echo "Adding TS_AUTHKEY to .env"
        {
            # add a newline to ensure there's one before this section
            echo ""
            echo "TS_AUTHKEY=$(get-authkey -tags "$TS_TAGS" -preauth)"
        } >>.env
    fi
fi

if ! grep -q "INFISICAL" .env; then
    if [ -z "$INFISICAL_TOKEN" ]; then
        echo "ERROR: no infisical token provided"
        RC=1
    else
        echo "Adding secrets from infisical to .env"
        {
            # add a newline to ensure there's one before this section
            echo ""
            echo "# BEGIN INFISICAL SECRETS"
            infisical export --env "${INFISICAL_ENV:-prod}" --path "/$APPNAME"
            echo "# END INFISICAL SECRETS"
        } >>.env
    fi
fi

exit $RC
