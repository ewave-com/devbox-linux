# DevBox code structure

```bash
{devbox_root}
    ├──start-devbox.ps1[.sh]                                      # Main script to start devbox projects
    ├──down-devbox.ps1[.sh]                                       # Main script to stop/kill/clean devbox projects 
    ├──sync-actions.ps1[.sh]                                      # Main script to start/stop sync or open sync logs
    └──tools/                                                     # DevBox source codes
        ├── bin                                                   # Service binary files
        ├── devbox                                                # Common DevBox related scripts
        │     └── devbox-state.ps1[.sh]                           #     Handling of the DevBox state file
        ├── docker                                                #     Common DevBox related scripts
        │     ├── docker-compose.ps1[.sh]                         #     Handling of docker-compose operations
        │     ├── docker-image.ps1[.sh]                           #     Handling of docker image operations
        │     ├── docker.ps1[.sh]                                 #     Handling of docker container operations
        │     ├── docker-sync-health-checker.ps1[.sh]             #     Main file of docker-sync health checker
        │     ├── docker-sync.ps1[.sh]                            #     Handling of docker-sync operations
        │     ├── infrastructure.ps1[.sh]                         #     Handling of DevBox common infrastructure operations
        │     ├── network.ps1[.sh]                                #     Handling of docker network operations
        │     └── nginx-reverse-proxy.ps1[.sh]                    #     Handling of DevBxo nginx-reverse-proxy container operations
        ├── main.ps1[.sh]                                         # Main high-level handler of project operations
        ├── menu                                                  # DevBox menu handlers
        │     ├── abstract-select-menu.ps1[.sh]                   #     Common script to interact with menus
        │     ├── select-down-type.ps1[.sh]                       #     Project shutdown menu
        │     ├── select-project.ps1[.sh]                         #     Project list menu
        │     ├── select-project-sync-name.ps1[.sh]               #     Project sync name list menu
        │     └── select-sync-action.ps1[.sh]                     #     Project sync action list menu
        ├── print                                                 # Printable items
        │     ├── done.txt                                        #     'Done' static text image
        │     ├── logo.txt                                        #     'Logo' static text image
        │     └── print-project-info.ps1[.sh]                     #     Displaying of summary project information after starting 
        ├── project                                               # Project related scripts
        │     ├── all-projects.ps1[.sh]                           #     Handling of project lists and common project state
        │     ├── docker-up-configs.ps1[.sh]                      #     Preparing of project specific runtime files 
        │     ├── nginx-reverse-proxy-configs.ps1[.sh]            #     Preparing of project specific nginx configs
        │     ├── platform-tools.ps1[.sh]                         #     Running of platform-tools during project starting
        │     ├── project-dotenv.ps1[.sh]                         #     Preparing of project specific .env file
        │     ├── project-main.ps1[.sh]                           #     Detailed handler of project operations
        │     └── project-state.ps1[.sh]                          #     Handling of project state file
        ├── sync-main.ps1[.sh]                                    # Main high-level handler of project sync
        └── system                                                # System and common scripts scripts
            ├── check-bash-version.ps1[.sh]                       #     Checking of bash compatibility
            ├── constants.ps1[.sh]                                #     File of common DevBox constants
            ├── dependencies-installer.ps1[.sh]                   #     Software installer
            ├── dotenv.ps1[.sh]                                   #     Handling of common operations with .env files
            ├── file.ps1[.sh]                                     #     Handling of common operations text files
            ├── free-port.ps1[.sh]                                #     Evaluating and validating of allocated project ports
            ├── hosts.ps1[.sh]                                    #     Handling of actions with system 'hosts' file
            ├── output.ps1[.sh]                                   #     Displaying of different type of messages
            ├── require-once.ps1[.sh]                             #     Simulation of one time script loading
            └── ssl.ps1[.sh]                                      #     Handling of common SSL activities
```
