# DevBox File Structure

```bash
{devbox_root}
    ├── _doc                                           # current dir
    ├── configs                                        # devbox configuration file
    │   ├── bash                                       # available config providers for bash configs
    │   │   ├── akeneo                                      
    │   │   ├── default                                   
    │   │   └── magento2
    │   ├── docker-compose                             # docker-compose configurations for all pre-defined docker services
    │   │   ├── docker-compose-blackfire.yml
    │   │   ├── docker-compose-elasticsearch.yml
    │   │   ├── docker-compose-mongodb.yml
    │   │   ├── docker-compose-mysql.yml
    │   │   ├── docker-compose-postgres.yml
    │   │   ├── docker-compose-rabbitmq.yml
    │   │   ├── docker-compose-redis.yml
    │   │   ├── docker-compose-varnish.yml
    │   │   └── docker-compose-website.yml
    │   ├── docker-sync                                # docker-sync configurations
    │   │   ├── composer                               # available docker-sync config providers for composer cache
    │   │   │   ├── global                                     
    │   │   │   └── local
    │   │   ├── elasticsearch                          # available docker-sync config providers for elasticsearch
    │   │   │   ├── native                                     
    │   │   │   └── unison                                     
    │   │   ├── mysql                                  # available docker-sync config providers for mysql
    │   │   │   ├── native                                     
    │   │   │   └── unison  
    │   │   ├── node_modules                           # available docker-sync config providers for node_modules directory
    │   │   │   └── default  
    │   │   └── website                                # available docker-sync config providers for website
    │   │       ├── akeneo3
    │   │       ├── akeneo4
    │   │       ├── default
    │   │       ├── magento1
    │   │       └── magento2
    │   ├── infrastructure                             # available infrastructure services
    │   │   ├── docker-compose-adminer.yml                      
    │   │   ├── docker-compose-exim4.yml
    │   │   ├── docker-compose-mailhog.yml
    │   │   ├── docker-compose-nginx-reverse-proxy.yml
    │   │   ├── docker-compose-portainer.yml
    │   │   ├── exim4
    │   │   ├── infra.env
    │   │   └── nginx-reverse-proxy
    │   ├── mysql                                      # available config providers for mysql configs
    │   │   └── default
    │   ├── nginx                                      # available config providers for website nginx configs
    │   │   ├── akeneo3
    │   │   ├── akeneo4
    │   │   ├── default
    │   │   ├── drupal
    │   │   ├── joomla
    │   │   ├── laravel
    │   │   ├── magento1
    │   │   ├── magento2
    │   │   ├── no-php
    │   │   └── wordpress
    │   ├── nginx-reverse-proxy                        # available config providers for website nginx-reverse-proxy configs
    │   │   └── default
    │   ├── php                                        # available config providers for php configs
    │   │   └── default
    │   ├── rabbitmq                                   # available config providers for website rabbitmq configs
    │   │   └── default
    │   ├── ssl                                        # available config providers for common ssl certificates
    │   │   ├── default
    │   │   └── readme.txt
    │   ├── varnish                                    # available config providers for website varnish configs
    │   │   ├── default
    │   │   └── magento2
    │   └── project-defaults.env                       # base .env file with all default values
    ├── down-devbox.sh                                 # script entrypoint to stop or shutdown project 
    ├── projects                                       # directory for all projects sources
    │   ├── my_project_1                               # your project named my_project_1
    │   │   ├── docker-up                              # directory for generated configs and runtime data of project 
    │   │   ├── public_html                            # project code sources
    │   │   ├── share                                  # shared directory, will be mounted inside container
    │   │   ├── sysdumps                               # storage for mysql, es, etc. data  
    │   │   ├── .env                                   # main project config which defines which preconfigured docker services will handle your project
    │   │   └── .env-project.json                      # main platform-tools configuration file
    │   ├── archived_projects                          # service folder for invisible or archived projects with fast access 
    │   │   ├── my_project_9
    │   │   ├── my_project_10
    │   └── info.txt
    ├── start-devbox.sh                                # script entrypoint to start project
    ├── sync-actions.sh                                # script entrypoint to restart project sync and open sync logs
    ├── tools                                          # devbox code
    │   └── ...
    └── vendor
        ├── ...
        ├── ewave                                      # platform-tools entrypoints
        │   ├── devbox-akeneo2-scripts
        │   ├── devbox-core-scripts
        │   ├── devbox-m1-scripts
        │   └── devbox-m2-scripts
        └── ...
       

```
