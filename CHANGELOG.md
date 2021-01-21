# Linux DevBox
http://devbox.ewave.com/

TODO complete changelog with all changes

## Release 3.0.0
### Fatures:
- Global refactoring to improve stability,
- project files were reorganized to have single responsibility, e.g. modules and packages
- DevBox structure aligned with Windows and MacOs implementations
- updated system requirements, all required programs will be updated automatically 
- Added fallback logic for project configs. Now you can override project specific config files. 
  You need just to copy required config file structure from ${devbox_root}/configs to ${project_dir}/configs. They will be used instead of global config file of certain config provider. 
  For example "./configs/mysql/default/conf.d/custom.cnf" -> "./projects/my_project/configs/mysql/default/conf.d/custom.cnf"
- each service is started using a separate docker-compose file to be more flexible in project services infrastructure
- Added manageable 'bashrc' configs
- now all required configs are prepared within project docker-up directory
- introduced cursor-based menu navigation in combination with to number-based menu
- common infrastructure params were moved to the separate .env file and used to start/stop common infrastructure docker services, located at path configs/infrastructure/infra.env
- added project-defaults.env with default values which will be merged to project .env file
  see for details: ./configs/project-defaults.env
- all virtual env parameters in configs were replaced with hard patterns
  all pattern will be replaced with real value on project starting
  in case any parameter was not replaced (param name is missing) error will be thrown
  this lets avoid cases when some used in config env variable was missed
- default folder is changed to application dir on www-data login
- introduced docker-sync synchronization for mysql, elasticsearch, website data storages, now several independent syncs are available for project
  now each critical data source is mounted to project containers and separate containerized volume with own supervisor 
- added unison health-checker which restarts failed unison processes for container unison and host unison
- initial syncing is performed for the container user id and disabled further unison update in case just permissions were changed 
- added half-duplex unison mode to improve sync stability on lange directories
- added .composer cache synchronization on project and global levels
- unison window is now not critical for syncing and could be closed is not needed anymore, it just shows runtime unison logs
  by default log window will be opened automatically just for public_html directory sync, but you can change this behavior using custom docker-sync option 'devbox_show_logs_for_syncs'  
  you can find unison logs of all current sync processes at path {project_dir}/docker-up/docker-sync/*.log
- added new root script 'sync-action' which allows restarting syncs and open logs of exact sync process
- added base support of several domains of website
- now you can put required ssh keys and composer auth.json into {project_dir}/share/composer and {project_dir}/share/ssh
  they will be copied with required permissions to corresponding container folders on user login (see bashrc configs for details)
- bash history is now shared to host container and is not cleaned on project shutdown
- project .env, added configurable docker image name and image versions for most of docker services
- .env, WEBSITE_DOCUMENT_ROOT is obsolete, use WEBSITE_SOURCES_ROOT and WEBSITE_APPLICATION_ROOT instead (backward compatibility fix is included)
- .env, ElasticSearch parameters renamed ELASTIC_* -> ELASTICSEARCH_* (backward compatibility fix is included):


### Bugfixes:




## Release 2.0
## Release 1.0
DevBox Changelog started from version 3.0.
DevBox is an application for development purposes which helps you to setup local environment using preconfigured images and setings in .env file. 
