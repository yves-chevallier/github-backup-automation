#!/bin/bash

set -e
if [[ -v VERBOSE ]]; then
    set -x
fi

TZ=${TZ:=UTC}
echo "timezone=${TZ}"

cp /usr/share/zoneinfo/${TZ} /etc/localtime
echo "${TZ}" > /etc/timezone

if [[ -z "${DELAY_TIME}" ]]; then
    echo "$(date) -> start a backup scheduler"
else 
    echo "$(date) -> start one time snapshot"
fi

while :; do
    DATE=$(date +%Y-%m-%dT%H%M)

    for u in $(echo $USERS | tr "," "\n"); do
        ORGNAME=${u#"org:"}
        echo "$(date) -> execute backup for ${u}, ${DATE}"
        github-backup ${ORGNAME} $(if [[ $u == org:* ]] ; then echo '--organization'; fi) \
            --token=$GITHUB_TOKEN \
            --all \
            --output-directory=/srv/var/github-backup/${DATE}/${ORGNAME} \
            --private \
            --gists

        if [[ -v ARCHIVE ]]; then
            echo "$(date) -> compress backup"
            tar -zcvf /srv/var/github-backup/${DATE}/${ORGNAME}.tar.gz /srv/var/github-backup/${DATE}/${ORGNAME}

            echo "$(date) -> delete un-archived files"
            rm -rf /srv/var/github-backup/${DATE}/${ORGNAME}
        fi
    done

    echo "$(date) -> cleanup"
    ls -d1 /srv/var/github-backup/* | head -n -${MAX_BACKUPS} | xargs rm -rf

    if [[ -v DELAY_TIME ]]; then
        echo "$(date) -> sleep for ${DELAY_TIME}"
        sleep ${DELAY_TIME}
        set -x
    else
        break
    fi
done
