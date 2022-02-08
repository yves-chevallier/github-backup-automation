#!/bin/bash

set -e
if [[ -z "${VERBOSE}" ]]; then
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
    DATE=$(date +%Y-%m-%dT%Hh%Mm)

    for u in $(echo $USERS | tr "," "\n"); do
        echo "$(date) -> execute backup for ${u}, ${DATE}"
        github-backup ${u#"org:"} $(if [[ $u == org:* ]] ; then echo '--organization'; fi) \
            --token=$GITHUB_TOKEN \
            --all \
            --output-directory=/srv/var/github-backup/${DATE}/${u} \
            --private \
            --gists

        if [[ -z "${ARCHIVE}" ]]; then
            echo "$(date) -> compress backup"
            tar -zcvf /srv/var/github-backup/${DATE}/${u}.tar.gz /srv/var/github-backup/${DATE}/${u}

            echo "$(date) -> delete un-archived files"
            rm -rf /srv/var/github-backup/${DATE}/${u}
        fi
    done

    echo "$(date) -> cleanup"
    ls -d1 /srv/var/github-backup/* | head -n -${MAX_BACKUPS} | xargs rm -rf

    if [[ -z "${DELAY_TIME}" ]]; then
        echo "$(date) -> sleep for ${DELAY_TIME}"
        sleep ${DELAY_TIME}
        set -x
    else
        break
    fi
done
