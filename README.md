# A [Docker image](https://hub.docker.com/r/koddr/github-backup-automation) to backup automation for your GitHub accounts (repositories, gists, organizations)

> ☝️ This is a more usable fork of [`umputun/github-backup-docker`](https://github.com/umputun/github-backup-docker) image with some extra features, like gzip compression of your backup files and ready to work with Ansible playbook.

## Usage

I recommend to use this Docker image with Ansible playbook:

- [useful-playbooks/github_backup](https://github.com/truewebartisans/useful-playbooks/blob/master/docs/github_backup.md)

It's a better way to create and deploy container to your remote server with no worries and no manual work.

```
version: "2"

services:
  github-backup:
    build: https://github.com/yves-chevallier/github-backup-automation.git
    container_name: "github-backup"
    hostname: "github-backup"
    restart: always

    logging:
      driver: json-file
      options:
        max-size: "10m"
        max-file: "5"

    environment:
      - GID=100
      - UID=1026
      - USERS=username org:organization
      - GITHUB_TOKEN=SECRET
      - TZ=Europe/Zurich
    volumes:
      - /volume1/docker/github:/srv/var/github-backup
```

## ⚠️ License

MIT &copy; [Vic Shóstak](https://github.com/koddr).
