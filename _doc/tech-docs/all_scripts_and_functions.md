# Tecnical description of DevBox scripts and functions

---------------------

## tools/main.ps1 (Windows) or tools/main.sh (MacOs, Linux)

### Description
Main script to handle main project operations 

### Function list

#### Public functions:

```start_devbox_project ([string]$_selected_project): void``` 
Start project entrypoint function. 

```stop_devbox_project([string]$_selected_project): void```
Stop project entrypoint function.

```down_devbox_project([string]$_selected_project): void``` 
Down project entrypoint function.

```down_and_clean_devbox_project([string]$_selected_project): void``` 
Down and clean project entrypoint function.

```stop_devbox_all(): void```
Stop all projects entrypoint function.

```down_devbox_all(): void```
Down all projects entrypoint function.

```down_and_clean_devbox_all(): void```
Down and clean all projects entrypoint function.

```docker_destroy(): void```
Destroy docker data entrypoint function.

```update_docker_images_if_required(): void```
Function to perform monthly updates of docker images with ':latest' tags

#### Local functions: -

---------------------

## tools/sync-main.ps1 (Windows) or tools/sync-main.ps1 (MacOs, Linux)

### Description
Main script to handle main project operations

### Function list

#### Public functions:
```start_sync([string]$_selected_project): void```
Start synchronization into containers entrypoint function.

```stop_sync([string]$_selected_project): void```
Stop synchronization into containers entrypoint function.

```restart_sync([string]$_selected_project): void```
Restart synchronization into containers entrypoint function.

```purge_and_restart_sync([string]$_selected_project): void```
Purge stored container files and restart synchronization into containers entrypoint function.

```open_log_window([string]$_selected_project, [string list | 'all']$_selected_sync_names): void```
Open synchronization log window entrypoint function.
$_selected_sync_names

#### Local functions: -

---------------------

## tools/devbox/devbox-state.ps1 (Windows) or tools/devbox/devbox-state.sh (MacOs, Linux)

### Description

This script handles the operations around devbox state, it means processing of some dynamic state variables.
It used for storing of date of last image update but could be extended with any new params if required. 


### Function list

#### Public functions:

```devbox_state_has_param([string]$_param_name): bool```
Check is devbox state file has the parameter.

```devbox_state_get_param_value([string]$_param_name): string```
Retrieved the parameter from the devbox state file.

```devbox_state_set_param_value([string]$_param_name, [string]$_param_value): void```
Write a pair parameter + value into the devbox state file.

``` get_devbox_state_docker_images_updated_at(): string```
Get timestamp value of the state parameter 'docker_images_updated_at'.

``` set_devbox_state_docker_images_updated_at([string]$_value): void```
Write the state parameter 'docker_images_updated_at'.

``` get_devbox_state_docker_images_updated_at_diff(): int```
Calculate the diff between current timestamp and timestamp in the state file.

#### Local functions: -


``` devbox_state_init_file(): void```
Create state file if does not exist.

``` devbox_state_ensure_param_is_readable([string]$_param_name): void```
Ensure incoming arguments as param name and file name are valid.

``` get_devbox_state_file_path(): string```
Retrieve the full path of the state file.

``` is_devbox_state_file_exists(): bool```
Check if the state file exist.

---------------------

## tools/docker/docker.ps1 (Windows) or tools/docker/docker.sh (MacOs, Linux)

### Description

The script to handle base operations with docker containers, e.g. starting, stopping, state validation, etc.

### Function list

#### Public functions:

``` get_docker_container_state([string]$_container_name): string```
Get state of docker container using 'docker ps'.
Native docker state values: 'created', 'restarting', 'running', 'paused', 'exited', 'dead'

``` is_docker_container_running([string]$_container_name, [bool]$_find_exact_match = true): bool```
Check if container has 'running' state.
$_find_exact_match - true for strict regexp search like "^name$", false - for soft search by part of given container name. 

``` is_docker_container_exist([string]$_container_name, [bool]$_find_exact_match = true): bool```
Check if container(s) exist.
$_find_exact_match - true for strict regexp search like "^name$", false - for soft search by part of given container name.

``` stop_container_by_name([string]$_container_name, [bool]$_find_exact_match = true): void```
Stop the container(s) by name.
$_find_exact_match - true for strict regexp search like "^name$", false - for soft search by part of given container name.

``` kill_container_by_name([string]$_container_name, [string]$_signal = 'SIGKILL' , [bool]$_find_exact_match = true): void```
Kill the container(s) by name, also using stopsignal
$_find_exact_match - true for strict regexp search like "^name$", false - for soft search by part of given container name.


``` rm_container_by_name([string]$_container_name, [bool]$_force = false, [bool]$_find_exact_match = true): void```
Remove the container(s) by name.
$_force = true, use '--force' docker rm option
$_find_exact_match - true for strict regexp search like "^name$", false - for soft search by part of given container name.


``` destroy_all_docker_services(): void```
Stop all working containers, kill all not stopped containers, remove all existing containers.
As well as prune volumes and prune system docker runtime data. 

#### Local functions: -



---------------------

## tools/docker/docker-compose.ps1 (Windows) or tools/docker/docker-compose.sh (MacOs, Linux)

### Description

The script to handle base operations with docker-compose.

### Function list

#### Public functions:

``` docker_compose_up([string]$_compose_filepath, [string]$_env_filepath = "$project_up_dir/.env", [string]$_log_level = $docker_compose_log_level): void```
Start container(s) from the given $_compose_filepath using the dotenv file at path $_env_filepath and with docker log level $_log_level.

``` docker_compose_stop([string]$_compose_filepath, [string]$_env_filepath = "$project_up_dir/.env", [string]$_log_level = $docker_compose_log_level): void```
Stop container(s) from the given $_compose_filepath using the dotenv file at path $_env_filepath and with docker log level $_log_level.

``` docker_compose_down([string]$_compose_filepath, [string]$_env_filepath = "$project_up_dir/.env", [bool]$_clean_volumes = false, [string]$_log_level = $docker_compose_log_level): void```
Down container(s) from the given $_compose_filepath using the dotenv file at path $_env_filepath and with docker log level $_log_level.
Volumes will be removed or not based on flag $_clean_volumes.

``` docker_compose_down_and_clean([string]$_compose_filepath, [string]$_env_filepath = "$project_up_dir/.env", [string]$_log_level = $docker_compose_log_level): void```
Down container(s) and remove volumes from the given $_compose_filepath using the dotenv file at path $_env_filepath and with docker log level $_log_level.

``` docker_compose_up_all_directory_services([string]$_working_directory, [string]$_env_filepath = "$_working_directory/.env", [string]$_log_level = $docker_compose_log_level): void```
--------------------------------.
Start containers from all docker-compose-*.yml files in directory $_working_directory  using the dotenv file at path $_env_filepath and with docker log level $_log_level.

``` docker_compose_stop_all_directory_services([string]$_working_directory, [string]$_env_filepath = "$_working_directory/.env", [string]$_log_level = $docker_compose_log_level): void```
--------------------------------.
Stop containers from all docker-compose-*.yml files in directory $_working_directory  using the dotenv file at path $_env_filepath and with docker log level $_log_level.

``` docker_compose_down_all_directory_services([string]$_working_directory, [string]$_env_filepath = "$_working_directory/.env", [string]$_log_level = $docker_compose_log_level): void```
--------------------------------.
Down containers from all docker-compose-*.yml files in directory $_working_directory  using the dotenv file at path $_env_filepath and with docker log level $_log_level.

``` docker_compose_down_and_clean_all_directory_services([string]$_working_directory, [string]$_env_filepath = "$_working_directory/.env", [string]$_log_level = $docker_compose_log_level): void```
Down containers and remove volumes from all docker-compose-*.yml files in directory $_working_directory  using the dotenv file at path $_env_filepath and with docker log level $_log_level.

#### Local functions: -


---------------------

## tools/docker/docker-image.ps1 (Windows) or tools/docker/docker-image.sh (MacOs, Linux)

### Description

The script to pull docker image updates with tags ':latest' as not fixed version.

### Function list
#### Public functions:

``` refresh_existing_docker_images(): void```
Find all docker images with tag ':latest' and pull the latest image updates.

``` docker_image_pull([string]$_image_name): void```
Execute docker pull for the given image name.

#### Local functions: -


---------------------

## tools/docker/docker-sync.ps1 (Windows) or tools/docker/docker-sync.sh (MacOs, Linux)

### Description

The script to handle base operations with 3rd part side 'docker-sync' package.
Related links:
http://docker-sync.io/
https://docker-sync.readthedocs.io/en/latest/

Each sync process requires unique sync-name in the corresponding config file docker-sync-*.yml.
Docker-sync creates separate sync container with own volume and with independent unison process to sync for non-native strategy.
Sync-name equals to container name to store copied data.

### Function list
#### Public functions:

```docker_sync_start([string]$_config_file, [string]$_sync_name = "", [bool]$_show_logs = true, [bool]$_with_health_check = true): void```
Start docker-sync daemon for the $_config_file. If $_sync_name arg passed - start sync for this process only, start all file syncs otherwise.
If $_show_logs true - open log window for syncs mentioned in the file option 'devbox_show_logs_for_syncs'.
If $_with_health_check true - start detached sync health-checker process in the end for non-'native' strategies. 

```docker_sync_stop([string]$_config_file, [bool]$_kill_service_processes = true): void```
Stop docker-sync processes for all syncs from $_config_file.
If $_kill_service_processes true - also stop health-checker process and try to close log window for processes with non-'native' strategy.

```docker_sync_clean([string]$_config_file, [string]$_sync_name = ""): void```
Remove the data (mirrored docker data) from the related volume(s) from docker-sync config $_config_file.
If $_sync_name is given - clean given volume,  otherwise clean all config file volumes. 

```docker_sync_start_all_directory_volumes([string]$_configs_directory, [bool]$_show_logs = true, [bool]$_with_health_check = true): void```
Start docker-sync daemons for all docker-sync-*.yml files in the $_configs_directory.
If $_show_logs true - open log window for syncs mentioned in the file option 'devbox_show_logs_for_syncs'.
If $_with_health_check true - start detached sync health-checker process in the end for non-'native' strategies.

```docker_sync_stop_all_directory_volumes([string]$_configs_directory, [bool]$_kill_service_processes = true): void```
Stop docker-sync daemons for all docker-sync-*.yml files in the $_configs_directory.
If $_kill_service_processes true - also stop health-checker processes and try to close log windows for processes with non-'native' strategy.

```docker_sync_clean_all_directory_volumes([string]$_configs_directory): void```
Remove the data (mirrored docker data) from the related volumes for all docker-sync-*.yml files in the $_configs_directory.

```get_config_file_sync_names([string]$_config_file): string```
Read names of sync processes from the section "syncs" of the given $_config_file
Return array(WinOs) ot newline-separated string(Linux,MacOs) with results.

```get_config_file_working_dir([string]$_config_file): string```
Retrieve working directory for log files and PID-files based on $_config_file location.
Value evaluated as subdirectory 'docker-sync/' in the parent directory of docker-sync-*.yml.

``` get_directory_sync_names([string]$_configs_directory): string```
Retrieve all sync names (equals to volume names) from all config files of the given directory.
Return array(WinOs) ot coma-separated string(Linux,MacOs) with results.

``` get_config_file_by_directory_and_sync_name([string]$_configs_directory, [string]$_sync_name): void```
Scans the given config directory to find the corresponding config file by the given $_sync_name. 

#### Local functions: -

``` show_sync_logs_window([string]$_config_file, [string]$_sync_name): void```
Open the terminal window with realtime updated sync logs.

``` close_sync_logs_window([string]$_config_file, [string]$_sync_name): void```
Close the terminal window with sync logs.

``` start_background_health_checker([string]$_config_file): void```
Start health-checker as a detached process. It monitors unison is working as expected and restarts it in case unison fails or hangs. 

``` stop_background_health_checker([string]$_config_file): void```
Stop health-checker process.

``` kill_unison_orphan_processes([string]$_project_dir): void```
Kill all orphaned project related unison processes.

``` get_config_file_option([string]$_config_file, [string]$_option_name): void```
Read the given option from the yml section 'options' of the given file.

``` get_config_file_sync_strategy([string]$_config_file): void```
Read the param 'sync_strategy' from the given config file $_config_file.


---------------------

## tools/docker/docker-sync-health-checker.ps1 (Windows) or tools/docker/docker-sync-health-checker.sh (MacOs, Linux)

### Description

The health-check script which observes unison sync is working as expected and restarts it in case unison fails or hangs.
Works as standalone and detached process for each sync thread (for each docker-sync config file). 
It requires the docker-sync configuration file as a first script call argument to be properly initialized.

### Function list
#### Public functions:
All functions of this file called just inside health-checker script. 

#### Local functions: -

``` start_watch([string]$--------------------): void```
Main function of health-checker watching implementation.
It checks if sync daemon PID file exist and restarts corresponding sync process.
Also it cleans log file in case its size becomes greater that 10mB.

``` is_main_healthchecker_process([string]$--------------------): void```
Checks if current sync health-checker instance is the main process, it means first it was started first.
This is required to avoid single handling of hanging unison processes. 

``` handle_hanging_unison_proceses([string]$--------------------): void```
This function tries to detect is unison process hanging.
After the first detection of high CPU utilization by unison process it is marked as reset candidate.
High utilization means CPU usage greater than threshold 95% for one core as unison is single-core process.
The final reset decision will be made based on 3 cycles by 3 controls checks during 30 seconds.
In case all control checks show CPU utilization then checked unison process will be killed, related pid file will be removed 
and sync will be restarted by the nearest pid-file check.  


---------------------

## tools/docker/infrastructure.ps1 (Windows) or tools/docker/infrastructure.sh (MacOs, Linux)

### Description

This script handles common DevBox infrastructure operations, e.g. start/stop/down portainer, reverse-proxy, mailer, adminer containers.
Infrastructure starting performed prior project starting. Stopping/downing performed in the end of stopping of all projects (stop/down all menu actions).

### Function list
#### Public functions:

``` start_infrastructure([string]$_dotenv_filepath = $dotenv_infra_filepath): void```
Create internal docker network for projects.
Also start infrastructure services: , check ports are available and start portainer, nginx-reverse-proxy, mailer, adminer. 

``` stop_infrastructure([string]$_dotenv_filepath = $dotenv_infra_filepath): void```
Stop infrastructure services of portainer, nginx-reverse-proxy, mailer, adminer. Remove nginx-reverse-proxy container configs.

``` down_infrastructure([string]$_dotenv_filepath = $dotenv_infra_filepath): void```
Stop infrastructure services of portainer, nginx-reverse-proxy, mailer, adminer. Remove nginx-reverse-proxy container configs.
Also remove internal docker network created on starting.

#### Local functions: -



---------------------

## tools/docker/network.ps1 (Windows) or tools/docker/network.sh (MacOs, Linux)

### Description

Handle docker network base operations: create and remove. 
All DevBox projects will be associated with this network.

### Function list
#### Public functions:

``` create_docker_network(): void```
Create internal docker network name.

``` remove_docker_network(): void```
Remove internal docker network name.

``` get_docker_network_name(): string```
Return internal docker network name.

#### Local functions: -



---------------------

## tools/docker/nginx-reverse-proxy.ps1 (Windows) or tools/docker/nginx-reverse-proxy.sh (MacOs, Linux)

### Description

The script handles common actions with infrastructure nginx-reverse-proxy container, for example adding/removal of website configs, certificates.

### Function list
#### Public functions:

``` nginx_reverse_proxy_restart(): void```
Restart nginx-reverse-proxy container.

``` nginx_reverse_proxy_add_website([string]$_website_config_path, [string]$_crt_file_name, [string]$_key_file_name = ""): void```
Add new website configuration for reverse proxy. It adds the website conf file into nginx configuration directory.
Also can add the given SSL certificate file paths for HTTPS. 

``` nginx_reverse_proxy_remove_project_website([string]$_website_host_name, [string]$_crt_file_name): void```
Removes website configuration from nginx reverse proxy by the website domain name and cert file name. 

#### Local functions: -

``` nginx_reverse_proxy_prepare_common_folders([string]$--------------------): void```
Creates required nginx-reverse-proxy runtime directories and set the proper permissions.
Directories: nginx-reverse-proxy/run/conf.d/, nginx-reverse-proxy/run/logs/, nginx-reverse-proxy/run/ssl/.

``` nginx_reverse_proxy_add_website_config([string]$_website_config_path): void```
Copy the given full path of website conf into the working nginx 'nginx-reverse-proxy/run/conf.d/' directory.

``` nginx_reverse_proxy_remove_website_config([string]$_website_config_filename): void```
Remove the website config by file name from 'nginx-reverse-proxy/run/conf.d/'.

``` nginx_reverse_proxy_add_website_ssl_cert([string]$_source_crt_path, [string]$_source_key_path = ''): void```
Copy SSL certificate file path into 'nginx-reverse-proxy/run/ssl/'.
If $_source_key_path is empty - try to copy *.key file with the same basename as for *.crt. Or ignore if missing.  

``` nginx_reverse_proxy_remove_website_ssl_cert([string]$_crt_file_name, [string]$_key_file_name): void```
Remove the certificate file by file name from 'nginx-reverse-proxy/run/ssl/'.
If $_key_file_name is empty - try to remove *.key file with the same basename as for *.crt. Or ignore if missing. 

``` nginx_reverse_proxy_remove_website_logs([string]$_website_host_name): void```
Remove website log files from 'nginx-reverse-proxy/run/logs/' based on website host name.



---------------------

## tools/menu/abstract-select-menu.ps1 (Windows) or tools/menu/abstract-select-menu.sh (MacOs, Linux)

### Description

Common handling of interactive DevBox menus.

### Function list
#### Public functions:

``` select_menu_item([string|array]$_options_string): void```
Draw interactive menu based on the given option list.
Supports number-based and narrow-based navigation

``` draw_menu_header([string]$--------------------): void```
Draw menu header.

``` draw_menu_footer([string]$--------------------): void```
Draw menu footer.

#### Local functions: -



---------------------

## tools/menu/select-down-type.ps1 (Windows) or tools/menu/select-down-type.sh (MacOs, Linux)

### Description

Show main menu of down-devbox entrypoint with shutdown options. 
Menu list is static, items:
"Stop 1 project"
Stop ALL projects
Down 1 project
Down all projects
Down and clean 1 project
Down and clean all projects
Destroy docker data[for emergency case]
[Exit]

### Function list
#### Public functions:

``` select_down_type_menu(): string```
Show down type menu and return the chosen item.

#### Local functions: -

---------------------

## tools/menu/select-project.ps1 (Windows) or tools/menu/select-project.sh (MacOs, Linux)

### Description

Show menu with the list of all active projects.
List generated automatically based on directories in the {devbox_root}/proejcts/

### Function list
#### Public functions:

``` select_project_menu(): string```
Show project menu and return the chosen item.

#### Local functions: -

---------------------

## tools/menu/select-project-sync-name.ps1 (Windows) or tools/menu/select-project-sync-name.sh (MacOs, Linux)

### Description

Show menu with the list of all projects sync names.
List generated automatically based on sync names of all docker-sync-*.yml files in the project 'docker-up' directory.
Used for sync-actions entrypoint.

### Function list
#### Public functions:

``` select_project_sync_name_menu(): string```
Show sync names menu and return the chosen item.

#### Local functions: -


---------------------

## tools/menu/select-sync-action.ps1 (Windows) or tools/menu/select-sync-action.sh (MacOs, Linux)

### Description

Show menu with the actions with docker syncs.
Used for sync-actions entrypoint.
List is static, items:
[Exit]
Start sync
Stop sync
Restart sync
Purge data and restart re-sync
Show logs

### Function list
#### Public functions:

``` select_sync_action_menu(): string```
Show sync actions menu and return the chosen item.

#### Local functions: -


---------------------

## tools/print/print-project-info.ps1 (Windows) or tools/print/print-project-info.sh (MacOs, Linux)

### Description

Print the table with the summary project info and credentials at the end of project starting.

### Function list
#### Public functions:

``` print_info(): string```
Show the summary table.

``` get_website_urls(): string```
Get the coma-separated list of all website domains for the info table.

#### Local functions: -


---------------------

## tools/project/all-projects.ps1 (Windows) or tools/project/all-projects.sh (MacOs, Linux)

### Description

Script with common operations or checks across all projects.

### Function list
#### Public functions:

``` get_project_list([string]$_delimiter = ','): string```
Return the coma-separated list of all active projects.
The directory 'archived_projects' is excluded as a special directory for not active proejcts.

``` is_project_started([string]$_selected_project, [bool]$_fast_check = false): bool```
Check if the selected proejct name is already running based on checking of main files, e.g. .env, 'docker-up/*.yml' configs, etc.
Also can check running docker containers if $_fast_check is false.

``` ensure_project_configured([string]$_selected_project): void```
Ensure project directory has main '.env' file and it has at least 'PROJECT_NAME' param. Otherwise return error. 

``` is_project_configured([string]$_selected_project): bool```
Checks if the project directory has main '.env' file and it has at least 'PROJECT_NAME' param.

#### Local functions: -


---------------------

## tools/project/docker-up-configs.ps1 (Windows) or tools/project/docker-up-configs.sh (MacOs, Linux)

### Description

The script which prepares all project specific configuration files based on .env param values and collect all these configs in the 'docker-up' directory. 

### Function list
#### Public functions:

``` prepare_project_docker_up_configs(): void```
Main preparation function. It calls all required certain preparation functions.

``` cleanup_project_docker_up_configs([string]$--------------------): void```
Remove from the proejct 'docker-up' directory all files 'docker-compose-\*.yml' and "docker-sync-\*.yml".
Also remove directories 'docker-up/configs/', 'docker-up/docker-sync/', 'docker-up/nginx-reverse-proxy/'
This cleanup called when you do full down of your project.


#### Local functions: -

``` prepare_website_configs(): void```
Generate web container related configs: docker-compose-website.yml, docker-sync-*.yml for public_html, composer cache and node_modules.
Also prepare website specific nginx config, php configs and bash configs.

``` prepare_website_nginx_configs(): void```
Prepare website nginx configs into 'docker-up/configs/nginx/conf.d/${WEBSITE_HOST_NAME}.conf'

``` prepare_website_php_configs(): void```
Prepare website PHP configs into 'docker-up/configs/php/*'.

``` prepare_website_bash_configs(): void```
Prepare website bash configs into 'docker-up/configs/bash/*'. Also initialize bash history file.

``` prepare_mysql_configs(): void```
Prepare MySql main files 'docker-up/docker-compose-mysql.yml' and 'docker-up/docker-sync-mysql.yml' config
and also related configs into 'docker-up/configs/mysql/*'.  

``` prepare_varnish_configs(): void```
Prepare Varnish main file 'docker-up/docker-compose-varnish.yml' config and also related configs into 'docker-up/configs/varnish/*'.

``` prepare_elasticsearch_configs(): void```
Prepare Elasticsearch main files 'docker-up/docker-compose-elasticsearch.yml' and 'docker-up/docker-sync-elasticsearch.yml' config
and also related configs into 'docker-up/configs/elasticsearch/*'.

``` prepare_redis_configs(): void```
Prepare Redis main file 'docker-up/docker-compose-redis.yml' config and also related configs into 'docker-up/configs/redis/*'.

``` prepare_blackfire_configs(): void```
Prepare Blackfire main file 'docker-up/docker-compose-blackfire.yml' config and also related configs into 'docker-up/configs/blackfire/*'.

``` prepare_postgres_configs(): void```
Prepare Postgres main file 'docker-up/docker-compose-postgres.yml' config and also related configs into 'docker-up/configs/postgres/*'.

``` prepare_mongodb_configs(): void```
Prepare MongoDb main file 'docker-up/docker-compose-mongodb.yml' config and also related configs into 'docker-up/configs/mongodb/*'.

``` prepare_rabbitmq_configs(): void```
Prepare RabbitMq main file 'docker-up/docker-compose-rabbitmq.yml' config and also related configs into 'docker-up/configs/rabbitmq/*'.

``` prepare_custom_configs(): void```
Prepare custom file 'docker-up/${CUSTOM_COMPOSE}' config and also related configs into 'docker-up/configs/custom/*'.


---------------------

## tools/project/nginx-reverse-proxy-configs.ps1 (Windows) or tools/project/nginx-reverse-proxy-configs.sh (MacOs, Linux)

### Description

Prepare project specific configuration for the infrastructure nginx-reverse-proxy container.

### Function list
#### Public functions:

``` prepare_project_nginx_reverse_proxy_configs(): void```
Generate project specific nginx config file for nginx-reverse-proxy.
If required generate and install SSL certificate.

``` cleanup_project_nginx_reverse_proxy_configs(): void```
Remove project specific nginx config file and certificate for nginx-reverse-proxy.

#### Local functions: -

``` prepare_website_ssl_certificate(): void```
Copy existing certificate from the project directory or generate new.


---------------------

## tools/project/platform-tools.ps1 (Windows) or tools/project/platform-tools.sh (MacOs, Linux)

### Description

Small script to run commands from platform_tools package.

### Function list
#### Public functions:

``` fix_web_container_permissions(): void```
Call permissions expanding inside web container.

``` run_platform_tools(): void```
Call platform_tools package inside web container. Called in the end of proejct starting.

#### Local functions: -


---------------------

## tools/project/project-dotenv.ps1 (Windows) or tools/project/project-dotenv.sh (MacOs, Linux)

### Description

Prepare the main runtime project configuration file 'docker-up/.env' based on initial '.env'.   

### Function list
#### Public functions:

``` prepare_project_dotenv_variables([bool]$_force = false): void```
Generate runtime 'docker-up/.env' and export all its params as global/env variables.
If $_force false - skip generation if the file already exists. 

#### Local functions: -

``` prepare_project_dotenv_file([bool]$_force = false): void```
Main preparation function. 
Copy the initial project file .env as 'docker-up/.env' and call other functions below one by one to get copied runtime file ready to work.

``` apply_backward_compatibility_transformations([string]$_env_filepath = "${project_up_dir}/.env"): void```
Transform some params from the previous DevBox version.

``` merge_defaults([string]$_env_filepath = "${project_up_dir}/.env"): void```
Combine the runtime 'docker-up/.env' file with the file of default values to collect all existing params.
This is usefull if you want to keep the initial file clean and small.

``` ensure_exposed_container_ports_are_available([string]$_env_filepath = "${project_up_dir}/.env"): void```
Ensure static ports mentioned in the .env are available or throw an error to prevet starting.

``` add_computed_params([string]$_env_filepath = "${project_up_dir}/.env"): void```
Check if static ports mentioned in the .env are available or generate new dynamic ports to use.
Also update some docker-sync params.

``` add_static_dir_paths_for_docker_sync([string]$_env_filepath = "${project_up_dir}/.env"): void```
Append the generated full paths of main project dirs into 'docker-up/.env' for proper docker-sync path resolving.

``` evaluate_expression_values([string]$_env_filepath = "${project_up_dir}/.env"): void```
Evaluate param values which are presented through other params.
For example 'PARAM_1=${PARAM_2}_$PARAM_3' will be evaluated based on PARAM_2 and PARAM_3 from same file to get PARAM_1=VALUE_4



---------------------

## tools/project/project-main.ps1 (Windows) or tools/project/project-main.sh (MacOs, Linux)

### Description

Main script to perform high-level project related operations. Mainly calls other required functions.

### Function list
#### Public functions:

``` start_project(): void```
Start current project. 
Has the following external function calls: check that it is still not running, prepare runtime 'docker-up/.env' file, create base directories,
prepare all required 'docker-up/' configs, start syncs and containers, add reverse-proxy configs, add records to 'hosts' file
and update project state file.

``` stop_current_project([string]$--------------------): void```
Stop current project.
Has the following external function calls: stop syncs and containers, removes reverse proxy configs and update project state file.

``` down_current_project([string]$--------------------): void```
Down current project.
Has the following external function calls: down syncs and containers, removes reverse proxy configs, removes 'docker-up/*' files,
removes records from 'hosts' file, and drop the generated 'docker-up/.env'.

``` down_and_clean_current_project([string]$--------------------): void```
The same as down but with docker volumes cleaning.

#### Local functions: -

``` init_selected_project([string]$_selected_project): void```
Initialize base project directories and its related few global variables.

``` is_simplified_start_available(): bool```
Check is fast start is available for the current project. Usually after simple proejct stopping without any .env changes.
In case '.env' md5 hash was changed since last run of proejct state is not valid - return false. 

``` create_base_project_dirs(): void```
Create all required project directories and set required permissions.




---------------------

## tools/project/project-state.ps1 (Windows) or tools/project/project-state.sh (MacOs, Linux)

### Description

Handler of the file to store project state variables.

### Function list
#### Public functions:

``` is_state_file_exists([string]$_state_filepath = "${project_up_dir}/project.state"): bool```
Check if project state file exist.

``` get_state_dotenv_hash([string]$_state_filepath = "${project_up_dir}/project.state"): string```
Read the last md5 hash of .env from the state file.

``` set_state_dotenv_hash([string]$_value, [string]$_state_filepath = "${project_up_dir}/project.state"): void```
Write new md5 hash of .env into the state file.

``` get_state_last_project_status([string]$_state_filepath = "${project_up_dir}/project.state"): string```
Read the last project state from the state file.

``` set_state_last_project_status([string]$_value, [string]$_state_filepath = "${project_up_dir}/project.state"): void```
Write current project state line into the state file.

``` remove_state_file([string]$_state_filepath = "${project_up_dir}/project.state"): void```
Remove state file.

#### Local functions: -


``` state_has_param([string]$_param_name, [string]$_state_filepath = "${project_up_dir}/project.state"): bool```
Check if the given param is presented in the state file.

``` state_get_param_value([string]$_param_name, [string]$_state_filepath = "${project_up_dir}/project.state"): string```
Read param value from the project state file.

``` state_set_param_value([string]$_param_name, [string]$_param_value, [string]$_state_filepath = "${project_up_dir}/project.state"): void```
Write the param value into the project state file.

``` init_state_file([string]$_state_filepath = "${project_up_dir}/project.state"): void```
Create state file if doesn't exist.

``` state_ensure_param_is_readable([string]$_param_name, [string]$_state_filepath = "${project_up_dir}/project.state"): void```
Ensure file exist and param name is not empty or throw and error.


---------------------

## tools/system/constants.ps1 (Windows) or tools/system/constants.sh (MacOs, Linux)

Main configuration file with base constants of the project

### Function list

#### Public functions: -
#### Local functions: -


---------------------
## tools/system/check-bash-version (MacOs and Linux only)

### Description
Script which validates the used system 'bash' version is not too old (v1 / v2) and update it if you want

### Function list

#### Public functions:
``` check_bash_version(): void```
Check the installed bash version and update it

``` confirm_bash_updating(): int```
Ask for updating confirmation

#### Local functions: -


---------------------

## tools/system/dependencies-installer.ps1 (Windows) or tools/system/dependencies-installer.sh (MacOs, Linux)

### Description
This the installer of all require software dependencies, e.g. docker, unison, other system packages which DevBox needs for his work.

### Function list

#### Public functions:

``` install_dependencies(): void```
Install all required software, has calls for other installation functions.
Called every time on start devbox.
All software function have checks if installation/updating is required.

#### Local functions: -

``` install_docker(): void```
Checks docker and versions and installs the corresponding one if required and set the required permissions.

``` install_docker_sync(): void```
Install docker-sync ruby package which is a wrapper for most popular 'unison' syncing.
In this case unison handled by docker-sync package and we don't need to control it now.
DevBox will just perform health-checks and restart docker-sync daemon in case unison fails or hangs.
The package is multi-platform for all 3 OSs. But for linux version it switched to legacy syncing and docker-sync skips all related steps.

``` install_unison(): void```
Install unison synchronization package to the host system. It will be handles by docker-sync package mentioned above.

``` install_git(): void```
--------------------------------.
Install git package to the host system.

``` install_composer(): void```
Install git package to the host system.

``` install_extra_packages(): void```
Install other packages like openssl, etc..

``` register_devbox_scripts_globally(): void```
Makes main entrypoint scripts callable and adds DevBox directory to the system PATH to have a possibility to run docker from any directory.

``` add_directory_to_env_path([string] $_bin_dir): void```
Writes the given directory to the system PATH.

``` set_flag_terminal_restart_required(): void```
Set internal flag variable to restart terminal after updating of PATH by any package to reread updated env variables.

``` unset_flag_terminal_restart_required(): void```
Unset internal flag variable to restart terminal.


---------------------

## tools/system/dotenv.ps1 (Windows) or tools/system/dotenv.sh (MacOs, Linux)

### Description
Contains a common logic related to work with any dot-env files.
It is used as a basic for separate handlers of project .env and infra.env files.

### Function list

#### Public functions:

``` dotenv_export_variables([string]$_env_filepath = ""): void```
Export pairs param=value from to the any given dot-env file.

``` dotenv_unset_variables([string]$_env_filepath = ""): void```
Unsets params from to the any given dot-env file.

``` dotenv_has_param([string]$_param_name, [string]$_env_filepath = $current_env_filepath): bool```
Check if line with param is presented in the given got-env file.

``` dotenv_has_param_value([string]$_param_name, [string]$_env_filepath = $current_env_filepath): bool```
Check if line with param is presented in the given got-env file and value is not empty.

``` dotenv_get_param_value([string]$_param_name, [string]$_env_filepath = $current_env_filepath): string```
Returns the param value from the dot-env file or empty string if no value.

``` dotenv_set_param_value([string]$_param_name,[string]$_param_value, [string]$_env_filepath = $current_env_filepath): void```
Write the param value to the dot-env file.
Value will be added to the end of file as new param line or current value will be replaced if param exist.

``` replace_file_patterns_with_dotenv_params([string]$_filepath, [string]$_env_filepath = $current_env_filepath): bool```
Substitute all placeholders in the file $_filepath with corresponding dot-env values from the file $_env_filepath.
Placeholder should look like {{MY_PARAM}} and line 'MY_PARAM=123' should exist in the dot-env file.
Error will be thrown if at least one unprocessed placeholder left in the file as the control check.

``` replace_directory_files_patterns_with_dotenv_params([string]$_dir_path, [string]$_env_filepath = $current_env_filepath): bool```
Scans all files in the given directory and replaces all param placeholders in each file using the function above.

#### Local functions: -

``` dotenv_ensure_param_is_readable([string]$_param_name, [string]$_env_filepath = $current_env_filepath): void```
Check param and path exist and are not empty. Moved to the separate function just to avoid duplication of the same validation.


---------------------

## tools/system/file.ps1 (Windows) or tools/system/file.sh (MacOs, Linux)

### Description
Contains a common logic related to deal with files, their content and also directories.


### Function list

#### Public functions:

``` copy_path([string]$_from_path, [string]$_to_path): void```
System wrapper to copy $_from_path to $_to_path considering type of the source and destination.

``` copy_path_with_project_fallback([string]$_source_path, [string]$_target_path,[bool]$_strict_mode = true): void```
Copy sources from the global directory paths, then copy files from the project directory with the same structure.
Implemented to have a possibility to override global devbox configs with the project specific files without conflicts with global code.
Project files could be comited into the project repo together with .env and .env-project.json if required.

``` replace_value_in_file([string]$_filepath, [string]$_needle, [string]$_replacement): void```
A wrapper of value replacing with additional validations incoming data are valid and not empty.

``` replace_file_line_endings([string]$_filepath): void```
Replace Windows specific line endings '\r\n' with unix compatible '\n' to use inside docker containers.

``` get_file_md5_hash([string]$_filepath): string```
Evaluate md5 hash of the given file. Used to detect file content changes.

``` sed_in_place([string]$_sed_expression, [string]$_filepath): void```
MacOs/Linux specific. Replace value in the file 'in place' without temp intermediate file creation.


#### Local functions: -

---------------------

## tools/system/free-port.ps1 (Windows) or tools/system/free-port.sh (MacOs, Linux)

### Description

Contains the logic for dynamic evaluation and validation of system ports could be allocated by docker containers.

### Function list

#### Public functions:

``` get_available_mysql_port(): string```
Evaluate next free port for MySQL container based on system ports info and existing container port info starting from default port 3400.

``` get_mysql_port_from_existing_container([string]$_container_name): string```
Retrieve assigned MySQL port from metadata of already existing container.

``` ensure_mysql_port_is_available([string]$_checked_port): void```
Ensure static MySQL port is available to be allocated before usage. Otherwise, throw an error.

``` get_available_elasticsearch_port(): string```
Evaluate next free port for Elasticsearch container based on system ports info and existing container port info starting from default port 9200.

``` get_elasticsearch_port_from_existing_container([string]$_container_name): string```
Retrieve assigned Elasticsearch port from metadata of already existing container.

``` ensure_elasticsearch_port_is_available([string]$_checked_port): void```
Ensure static Elasticsearch port is available to be allocated before usage. Otherwise, throw an error.

``` get_available_website_ssh_port(): string```
Evaluate next free port for ssh connection of web container based on system ports info and existing container port info starting from default port 2300.

``` get_website_ssh_port_from_existing_container([string]$_container_name): string```
Retrieve assigned for ssh connection of web container from metadata of already existing container.

``` ensure_website_ssh_port_is_available([string]$_checked_port): void```
Ensure static ssh connection of web container is available to be allocated before usage. Otherwise, throw an error.

``` ensure_port_is_available([string]$_checked_port): void```
Common function to ensure the given port is available to be allocated before usage. Otherwise, throw an error.

``` get_process_info_by_allocated_port([string]$_checked_port): string```
Retrieve extended info about the process which allocated the given port.
Info includes string with PID, process name and optionally docker container name.

``` find_port_across_docker_containers([string]$_checked_port, [string]$_container_name = ""): void```
Scans containers metadata to find the given port. Also filter by certain container name if given



#### Local functions: -

``` find_port_by_regex([string]$_port_mask): string```
Common system wrapper to find if the given port is currently allocated.
Return port number is allocated, empty string if available.
Called by other functions in this script.

``` get_port_full_search_mask([string]$_port_mask): string```
Prepare the full regex mask including ip adresses to filter system ports


---------------------

## tools/system/hosts.ps1 (Windows) or tools/system/hosts.sh (MacOs, Linux)

### Description
Common handler of system 'hosts' file to add and remove website domains.


### Function list

#### Public functions:

``` add_website_domain_to_hosts([coma separated string]$_domains, [string]$_ip_address = "127.0.0.1"): void```
Add the given domain(s) records to the hosts file.

``` delete_website_domain_from_hosts([coma separated string]$_domains, [string]$_ip_address = "127.0.0.1"): void: void```
Delete the given domain(s) records to the hosts file.

#### Local functions: -

---------------------

## tools/system/output.ps1 (Windows) or tools/system/output.sh (MacOs, Linux)

### Description
Common handler of showing different messages including colored.

### Function list

#### Public functions:

``` show_error_message([string]$_message, [string|int]$_hierarchy_lvl = 0): void```
Show error message in red.

``` show_warning_message([string]$_message, [string|int]$_hierarchy_lvl = 0): void```
Show error message in yellow.

``` show_success_message([string]$_message, [string|int]$_hierarchy_lvl = 0): void```
Show error message in green.

``` show_message([string]$_message, [string|int]$_hierarchy_lvl = 0): void```
Show error message in default color.

``` show_info_value_message([string]$_message, [string]$_value): void```
Show semicolon delimited pair of param in green plus value in default color.
Used to draw the final project info after project starting.

``` print_section_header([string]$_header): void```
Print long header line filled by "=" chars and with the message in the middle

``` print_section_footer(): void```
Print long header line filled by "=" chars.


#### Local functions:

``` print_filled_line([string]$_string, [string|int]$_total_length = 80, [char]$_filler_char = "="): void```
Print line filled by $_filler_char chars with length $_total_length and with the message $_string in the middle

``` get_hierarchy_lvl_prefix(): void```
Prepares message prefix depending on the givel level to graw messages as a tree.

---------------------

## tools/system/require-once.ps1 (Windows) or tools/system/require-once.sh (MacOs, Linux)

### Description

See function 'require_once' explanation below.

### Function list

#### Public functions:

``` require_once([string]$_included_path): void```
Function to provide with pseudo-package structure.
Actually bash and powershell loads all included scripts into the one namespace.
This function implemented to provide more explicitness of what dependencies on other scripts has the certain script to work.
And in case we don't use this approach of once loading all imported functions and variables might be overriden in runtime by other include calls.

#### Local functions: -


---------------------

## tools/system/ssl.ps1 (Windows) or tools/system/ssl.sh (MacOs, Linux)

### Description

The handler of common system operations with SSL certificates.


### Function list

#### Public functions:

``` ssl_import_new_system_certificate([string]$_cert_source_path): void```
Import the new certificate file.

``` ssl_disable_system_certificate([string]$_cert_source_path): void```
Deactivate the certificate file.

``` ssl_generate_domain_certificate([string]$_website_namem, [string]$_target_crt_path, [string]$_target_key_path = ""): void```
Generate certificate files for the domain using openssl system package.

#### Local functions:

``` add_system_ssl_certificate([string]$_cert_source_path): void```
Add SSL certificate to the system storage.

``` ssl_remove_system_certificate([string]$_file_name): void```
Remove SSL certificate from the the system storage.
