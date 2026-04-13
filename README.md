## GITOPS with KOMODO

A Komodo environment to orchestrate container-based infrastructure for dev, staging and production environments.

### GOALS

* This project attempts to listen on git server webhooks and detect commits, to trigger infrastructure change.
* The intent is to make a single node self-reliant in lifecycling docker compose infrastructure
* The environment should run in selinux enforcing VMs (bottlerocket) where tight restrictions of OS access are in place
* Attempt to minimise the differences in hosting dev, staging and production and architecure ARM & X86

### COMPONENTS:

* **Komodo** a Web UI, API & CLI for orchestration of containers on a single node
* **Periphery** is the layer that interacts with host-base docker instance
* **Mongodb** the persistence layer containing Komodo configuration
* **aws-cli-backup** short lived aws-cli container to write to s3 bucket
* **aws-cli-restore** short-lived aws-cli container to read from s3 bucket
* **cli** a minimal komodo CLI instance that executes to restore komodo config to mongodb then exit

### START KOMODO

run:
```docker compose up```

open:
```http://localhost:9120```

The process will:
1. start mongodb
2. run an AWS CLI process to acquire config backup stored in an s3 bucket
3. run a Komodo CLI session to restore data from step #2 into mongodb
4. start komodo web service on port 9120
5. komodo-periphery which needs access to docker.sock of native docker daemon running this script

Each running instance uses docker-compose, and runs in a **komodo** namespace, it is suggested that a different namespace be allocated to each piece of infra outside this script 

### Maintaing Persistence

The only persistence comes from Komodo backup either user-initiated, cron, UI or API

The infra will do a restore of configs from the **komodo_backups** volume each time on startup (and fail if backup does not exist). Users can maintain persistence by running **Schedule -> backup core database** in the web UI of Komodo (http://localhost:9120).

```docker compose up aws-cli-backup```

There are no AWS creds, but one can populate configs externally into this project via .env file. Comment out ENTRYPOINT replace with COMMAND, once the .env file has been created with an AWS credential.

Clear away any persistence and start containers from without local config:

```docker compose down -v```

Will delete all running containers and attached volumes. All config will go bye bye.

### Issues
mongodb v8 seems to error (segfault) Fedora 44 for reasons unknown, downgraded to v7
