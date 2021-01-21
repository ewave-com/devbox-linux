## How to start a new project

- First of all you need to create a project directory in 'project' directory to store all your data

- Then you need to prepare '.env' and '.env-project.json' files with configuration and put them to the project folder (so-called "project root")

You can find popular examples here:   
https://github.com/ewave-com/devbox-env-examples

To get '.env' file configured also you can copy 'configs/project-defaults.env' into your project dir with name '.env' 
and remove all you do not need, e.g. comments and not required params.

```bash
{devbox_root}
    ├── ...
    ├── configs
    │   └── project-defaults.env
    ├── projects
    │   ├── my_project
    │   │   ├── .env
    │   │   └── .env-project.json
    │   └── ... 
    └── ...
       
```
- run `start-devbox.bat` (WinOs) or `bash start-devbox.sh` (MacOs/Lnux) from the devbox folder, and wait until all services are started

- now your containers are ready to work but still empty. They should be enriched with source code, datadase storages and other data
  
in the end of process depending on chosen tools provider from .env you will be able to prepare all sources using [DevBox Platform Tools](platform_tools.md). It helps to perform this for you for example clone project source code, import database, run popular platform commands.
