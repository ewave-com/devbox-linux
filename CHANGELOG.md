# Linux DevBox
http://devbox.ewave.com/

## Release 3.1.0
- Added CONTAINER_RABBITMQ_PORT env settings to specify port for RabbitMQ container.

## Release 3.0.2
- [Linux/MacOs] Added compatibility with Docker 4.2 and 4.3. As a result log-level option has been removed from 'docker compose' V2 commands due to docker parsing issue.

## Release 3.0.1
- Fixed repeated import of website SSL certificate which resulted in asking for admin privileges by every project starting/stopping with enabled HTTPS
- Reduced requesting of sudo commands. 
  You can allow netstat without password using visudo to avoid password requesting for regular work with project (start/stop).
  To do this add the line using visudo
  `_put_your_login_here_ ALL=NOPASSWD: /usr/bin/netstat`

## Release 3.0.0

### Main changes:
- DevBox structure aligned with Windows and MacOs implementations
- Global refactoring to improve stability and usability:
  - Project files were reorganized to have single responsibility, e.g. modules and packages
  - Updated system requirements, all required programs will be installed/updated automatically
  - Added fallback logic for project configs. Now you can override project specific config files. You need just to copy required config file structure from ${devbox_root}/configs to ${project_dir}/configs.
    You need just to copy required config file structure from ${devbox_root}/configs to ${project_dir}/configs. They will be used instead of global config file of certain config provider.
    For example "./configs/mysql/default/conf.d/custom.cnf" -> "./projects/my_project/configs/mysql/default/conf.d/custom.cnf"
- Added documentation for devbox and platform-tools configuration files and features. See [README.md](README.md)
- Files syncing [Windows/MacOS]:
  - Introduced docker-sync synchronization for mysql, elasticsearch, website data storages, now several independent syncs are available for project
    Each critical data source is mounted to project containers and has separate containerized volume with own supervisor
  - Added unison health-checker which restarts failed or stuck unison processes.
  - Initial syncing is performed for the container user id. So problem of insufficient permissions is solved. No need to run fix permissions command every time.  
  - Unison window doesn't affect unison syncing and could be closed is not needed anymore, it just shows runtime unison logs.
    By default, log window will be opened automatically just for public_html directory sync as previously, but you can change this behavior using custom docker-sync option 'devbox_show_logs_for_syncs'  
    you can find unison logs of all current sync processes at path {project_dir}/docker-up/docker-sync/*.log
  - Excluded files synchronization in case only permissions were changed
  - Added new root script 'sync-action' which allows restarting syncs and open logs of exact sync process.
  - Now data from MySql and Elasticsearch containers also are syncing to the host machine, supports native docker synchronization and also docker-sync with unison strategy
- Files syncing [Linux]:
  - Uses native docker sync as most suitable and fast solution.
  - Significantly reduced number of permissions problems caused by conflicts of host and docker users. Used linux 'facl' package to keep open permissions for new files of main project directories.
- Other:
  - All required configs are prepared within project docker-up directory (except common nginx-reverse-proxy)
  - Each service is started using a separate docker-compose file to be more flexible in project services infrastructure
  - Introduced cursor-based menu navigation in combination with to number-based menu
  - Common infrastructure params were moved to the separate .env file and used to start/stop common infrastructure docker services, located at path configs/infrastructure/infra.env
  - Added project-defaults.env with default values which will be merged to project .env file. See details: ./configs/project-defaults.env
  - All virtual env parameters in configs were replaced with patterns that will be replaced with correspondig value on project start
    in case any parameter was not replaced (param name is missing) error will be thrown
    this lets avoid cases when some used in config env variable was missed
  - Added base support of several domains of website
  - Added configurable docker image name and image versions for all project docker service configurations
  - Introduced 'project.state' file to store project status info and improve starting time
  - Added monthly automatical 'composer update' to pull last updated
  - Added monthly autopull of docker images with 'latest' tag (it mean exact version is not specified)
  - Added possibility to disable node_modules sync and new composer cache sync using empty parameters value
  - Evaluating of dynamic free port for Mysql, Elasticsearch and SSH connection now searches for possible port including docker containers including stopped to keep already allocated port is possible
  - Added supporting of Docker compose V2
  - [MacOs] Added supporting M1 chips with ARM64 docker images

Web container main changes:
- Default folder is changed to application dir on www-data login
- Added manageable 'bashrc' configs using .env param CONFIGS_PROVIDER_BASH
- Added composer cache synchronization to host machine, it could be synced to project dir or global host OS cache dir
- Added one-directional syncing for ssh/composer credentials. You can put required ssh keys and composer auth.json into {project_dir}/share/composer and {project_dir}/share/ssh
  They will be copied with required permissions to corresponding container folders on user login (see bashrc configs for details)
- Bash history is now shared to host container and is not cleaned on project shutdown
- Added git autocompletion inside container
- Added platform depended aliases, see examples in .bashrc files.
- Added supporting of php auto_prepend_file to perfom some actions without touching project repo code.
  This might be usefull for example to resolve Magento website codes, to pull media files of fly, or for whatever you need.
- Added composer downgrade in case project composer.lock is still not updated to use composer 2.0+
- Added xdebug 3.0 config. Debugger is ready to work with both <3.0 and 3.0+ versions.
- Folder node_modules location is configurable using .env param WEBSITE_NODE_MODULES_ROOT
- xdebug port is configurable using .env param WEBSITE_PHP_XDEBUG_PORT


Deprecation section:
- .env, WEBSITE_DOCUMENT_ROOT is obsolete, use WEBSITE_SOURCES_ROOT and WEBSITE_APPLICATION_ROOT instead (backward compatibility fix is included)
- .env, ElasticSearch parameters renamed ELASTIC_* -> ELASTICSEARCH_* (backward compatibility fix is included)

## Release 2.0
## Release 1.0
DevBox Changelog started from version 3.0.
DevBox is an application for development purposes which helps you to setup local environment using preconfigured images and setings in .env file. 
