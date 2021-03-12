# How to create a new project

Project preparation includes several simple steps to build project containers based on a number of predefined configuration files:
- First of all you need to create a project directory in 'project' directory (so called "project root") to store all your data 


- Prepare project '.env' file. To get this file configured you can copy 'configs/project-defaults.env' into your project
  dir with name '.env' and remove all you do not need, e.g. comments and not required params. 
  (see the article [How to configure project .env file](project_dotenv.md))


- Prepare project '.env-project.json' file. This file is required for platform-tools. Actually you can enrich project 
  with data manually, but we would recommend to use platform-tools package to do this easier and faster for you. 
  (see the article [How to configure .env-project.json](project_env_project_json.md))

  You can find popular examples here:
  (https://github.com/ewave-com/devbox-env-examples)


- [ optional step ] if you want to use ssh keys or composer authorization on the first start you can manually create also folders 
  `share/ssh` and `share/composer`, and copy required credentials keys inside. File `config` is optional and required 
  only in case some custom ssh/git sources configuration (https://www.ssh.com/ssh/config/). On the first container login (and also on initial 
  platform-tools start) files will be copied to corresponding folders inside container. Or you can start project without
  copying files, and put them later into prepared folders.

```bash
{devbox_root}
    ├── ...
    ├── configs
    │   └── project-defaults.env
    ├── projects
    │   ├── my_project
    │   │   ├── .env                # [required]
    │   │   ├-─ .env-project.json   # [required]
    │   │   └── share               # [optional]
    │   │       ├── composer
    │   │       │   └── auth.json
    │   │       └── ssh
    │   │           ├── my_project_id_rsa 
    │   │           ├── my_project_id_rsa.pub
    │   │           └── config
    │   └── ... 
    └── ...
       
```


- run `start-devbox.bat` (WinOs) or `bash start-devbox.sh` (MacOs/Lnux) from the devbox folder, and wait until all services are started. 
Also all required software like docker, unison, and other will be installed during the first run so no need to care about this.
  

- now your containers are ready to work but still empty. They should be enriched with source code, datadase storages 
  and other data. You can do this manually or automatically using our platform-tools package 
  ( see [DevBox Platform Tools](platform_tools.md) article). It helps to perform this for you for example clone project
  source code, import database, run popular platform commands.
