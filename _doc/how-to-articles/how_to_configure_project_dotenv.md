# How to configure project .env file

Project .env file defines structure of your docker services and used configuration files for your project.

You need to prepare proper .env file in your project directory before starting. 

You can find detailed description for each used param in the defaults file: 
[configs/project-defaults.env](../../configs/project-defaults.env)

> To prepare project .env just copy the file `{devbox_root}/configs/project-defaults.env` into your project directory, update params as you need and remove not needed params and comments as you wish. 

This defaults file will be combined with your project .env configuration to provide all required and optional parameters to start.
So you can keep in your project file only required params to have clean configuration. 
Also feel free to override the param values if you need.

Final generated file will be located at path `{project_dir}/docker-up/.env`. After project started it will contain all merged and generated parameters.

These parameters are used to replace value patterns in service configs for chosen config providers of docker containers.
So you can easily add new parameters into overridden service configs and put corresponding params to your project .env.  
