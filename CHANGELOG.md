# Linux DevBox
http://devbox.ewave.com/

TODO complete changelog with all changes

## Release 3.0.0
### Fatures:
- Global refactoring to improve stability, 
- DevBox structure aligned with Windows and MacOs implementations 
- Added fallback logic for project configs. Now you can easily override project specific config files. 
  You need just to copy required config file structure from ${devbox_root}/configs to ${project_dir}/configs. They will be used instead of global config file of certain config provider. 
  For example "./configs/mysql/default/conf.d/custom.cnf" -> "./projects/my_project/configs/mysql/default/conf.d/custom.cnf"
- Added manageable 'bashrc' configs
- all required configs are prepared within project docker-up directory
- introduced cursor-based menu navigation in addition to number-based menu
- added project-defaults.env with default values which will be merged to project .env file
  see for details: ./configs/project-defaults.env
- default folder after www-data login is changed to application dir
- docker-sync added
- public_html is synced now
- .composer is synced now
- added base supporting of several domains
- bash history is saved permanently
- .env, added configurable docker image and image versions for missing docker services
- .env, WEBSITE_DOCUMENT_ROOT is obsolete, use WEBSITE_SOURCES_ROOT and WEBSITE_APPLICATION_ROOT instead (backward compatibility fix is included)
- .env, ElasticSearch parameters renamed (backward compatibility fix is included):
ELASTIC_ENABLE -> ELASTICSEARCH_ENABLE
CONTAINER_ELASTICSEARCH_NAME -> CONTAINER_ELASTICSEARCH_NAME
CONTAINER_ELASTICSEARCH_IMAGE -> CONTAINER_ELASTICSEARCH_IMAGE
CONTAINER_ELASTICSEARCH_VERSION -> CONTAINER_ELASTICSEARCH_VERSION
CONFIGS_PROVIDER_ELASTIC -> CONFIGS_PROVIDER_ELASTICSEARCH

### Bugfixes:




## Release 2.0
## Release 1.0
DevBox Changelog started from version 3.0.
DevBox is an application for development purposes which helps you to setup local environment using preconfigured images and setings in .env file. 
