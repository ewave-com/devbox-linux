# How to configure .env-project.json

Project file `.env-project.json` defines configuration for DevBox [platform-tools](platform_tools.md) helper.

You can find detailed description of all params below in this doc. 
Combined config example provided in the end of this doc. 

Common structure of this file looks like this:
```json
{
    "base_params": {
        "working_directories": {...},
        "temp_storage": {...}
    },
    "configuration": {
        "node_modules": {...}
    },
    "sources": {
        "code": {...},
        "db": {...},
        "media": {...},
        "files_mapping": {
            "creds": {...},
            "mapping": {...}
        },
        "update_db_data": {...}
    },
    "auto_start_commands": {...}
}


```
___

## Main file sections and params

## Section `base_params`

### Subsection `base_params->working_directories`
Subsection `base_params->working_directories` contains list of project directories. 
Mainly this list is required for the platform tools feature of files permissions updating.
The section required for platform tools command `core:setup:permissions`. (see related [DevBox Platform Tools](platform_tools.md))

Example:
```json
    "working_directories": {
        "dir_1": "/var/www"
    },
```

### Subsection `base_params->temp_storage`

Subsection `base_params->temp_storage` contains list of temp storages. 
Temp storage is required for example to download DB dump or some application files from a remote server.

Also you can use temp storage pattern `[~temp_storage]` at part of filesystem paths for other params. 
For example `"local_temp_path": "[~temp_storage]/db"`. 
In this case specific temp storage called `base` will be passed instead of this pattern.
`base_params->temp_storage->base`
Example:
```json
    "temp_storage": {
        "base": "/var/www/temp-dumps"
    }
```

## Section `configuration`

### Subsection `configuration->node_modules`

Subsection `configuration->node_modules` describes behaviour of node_modules preparation.
The section required for platform tools command `core:setup:node-modules`. (see related [DevBox Platform Tools](platform_tools.md))

Examples:
```json
    "configuration": {
        "node_modules": {
            "use_symlink": false,
            "package_manager": "yarn"
        }
    }
```
or (this is default values, and could be omitted) 
```json
    "configuration": {
        "node_modules": {
            "use_symlink": true,
            "package_manager": "npm"
        }
    }
```

## Section `sources`

### Subsection `sources->code`
Subsection `sources->code` defines params of code storage. You can specify a repository to be downloaded.
The section required for platform tools command `core:setup:code`. (see related [DevBox Platform Tools](platform_tools.md))
Source code will be downloaded to the directory specified in WEBSITE_SOURCES_ROOT parameter of your project '.env' file.
Available value of 'source_type': vcs.

If you prefer https authorization to vcs instead of ssh key you might need to set login/password as part of 'source_path'.
Or auth credentials will be requested by git engine.

```json
        "code": {
            "source_type": "vcs",
            "source_path": "git@github.com:my_project/my_repo.git",
            "source_branch": "master"
        },
```
or
```json
        "code": {
            "source_type": "vcs",
            "source_path": "https://mylogin:mypassword@github.com/my_project/my_repo.git",
            "source_branch": "develop"
        },
```

### Subsection `sources->db`
Subsection `sources->db` defines params of database dump storage. You can specify a source of sql dump in raw or gzipped format to be downloaded.
The section required for platform tools command `core:setup:db`. (see related [DevBox Platform Tools](platform_tools.md))
Dump file will be downloaded to the directory specified in the param subsection `local_temp_path`, then it will be 
unzipped within this directory if required and imported to project database host described in your project .env.

Available value of 'source_type': `owncloud`, `ftp`, `http`, `local`.

Examples:
```json
        "db": {
            "source_type": "owncloud",
            "source_path": "https://owncloud.mycompany.com/remote.php/webdav/my_project/dumps/my_project_db_dump.sql.gz",
            "source_login": "my_login",
            "source_password": "my_password",
            "local_temp_path": "[~temp_storage]/db"
        },
```
or
```json
        "db": {
            "source_type": "ftp",
            "source_path": "ftp://my_ftp_host/my_project/dumps/my_project_db_dump.sql.gz",
            "source_login": "my_login",
            "source_password": "my_password",
            "local_temp_path": "[~temp_storage]/db"
        },
```
or
```json
        "db": {
            "source_type": "http",
            "source_path": "http://my_http_host/my_project/dumps/my_project_db_dump.sql.gz",
            "source_login": "my_login",
            "source_password": "my_password",
            "local_temp_path": "[~temp_storage]/db"
        },
```
or
```json
        "db": {
            "source_type": "local",
            "source_path": "/var/www/share/dumps/my_project_db_dump.sql.gz",
            "local_temp_path": "[~temp_storage]/db"
        },
```

### Subsection `sources->es` [Akeneo only for now]
> Pay attention this section is valid only for Akeneo application for now

TODO make import from ES dump available on global level, build a separate command

Subsection `sources->es` defines params of elasticsearch dump storage. You can specify a source of elasticsearch dump in gzipped format to be downloaded.
The section required for platform tools command `akeneo2:setup:elastic` and `akeneo3:setup:elastic`. (see related [DevBox Platform Tools](platform_tools.md))
Dump file will be downloaded to the directory specified in the param subsection `local_temp_path`, then it will be
unzipped within this directory if required and imported to project elasticsearch host described in your project .env.

Available value of 'source_type': `owncloud`, `ftp`, `http`, `local`.

Examples:
```json
        "db": {
            "source_type": "owncloud",
            "source_path": "https://owncloud.mycompany.com/remote.php/webdav/my_project/dumps/my_project_es_dump.tar.gz",
            "source_login": "my_login",
            "source_password": "my_password",
            "local_temp_path": "[~temp_storage]/db"
        },
```
or
```json
        "db": {
            "source_type": "ftp",
            "source_path": "ftp://my_ftp_host/my_project/dumps/my_project_es_dump.tar.gz",
            "source_login": "my_login",
            "source_password": "my_password",
            "local_temp_path": "[~temp_storage]/db"
        },
```
or
```json
        "db": {
            "source_type": "http",
            "source_path": "http://my_http_host/my_project/dumps/my_project_es_dump.tar.gz",
            "source_login": "my_login",
            "source_password": "my_password",
            "local_temp_path": "[~temp_storage]/db"
        },
```
or
```json
        "db": {
            "source_type": "local",
            "source_path": "/var/www/share/dumps/my_project_es_dump.tar.gz",
            "local_temp_path": "[~temp_storage]/db"
        },
```

### Subsection `sources->media`

Subsection `sources->media` defines params of media files storage.
The section required for platform tools command `core:setup:media`. (see related [DevBox Platform Tools](platform_tools.md))
Defined files will be downloaded to the temp directory specified in the param subsection `local_temp_path`, then if 
process finished successfully all downloaded files will be copied to directory specified in param `local_media_website_path`.

Available value of 'source_type': `vcs`, `owncloud`, `ftp`, `http`, `local`.

Examples:
```json
        "media": {
            "source_type": "vcs",
            "source_path": "git@github.com:my_project/my_media_repo.git",
            "source_branch": "master",
            "local_media_website_path": "[~website_root]/pub/media",
            "local_temp_path": "[~temp_storage]/media"
        },
```
or
```json
        "media": {
            "source_type": "owncloud",
            "source_path": "https://owncloud.mycompany.com/remote.php/webdav/my_project/my_project_db_dump.sql.gz",
            "source_login": "my_login",
            "source_password": "my_password",
            "local_media_website_path": "[~website_root]/pub/media",
            "local_temp_path": "[~temp_storage]/media"
        },
```
or
```json
        "media": {
            "source_type": "ftp",
            "source_path": "ftp://my_ftp_host/my_project/staging/my_project_db_dump.sql.gz",
            "source_login": "my_login",
            "source_password": "my_password",
            "local_media_website_path": "[~website_root]/pub/media",
            "local_temp_path": "[~temp_storage]/media"
        },
```
or
```json
        "media": {
            "source_type": "http",
            "source_path": "http://my_http_host/my_project/staging/my_project_db_dump.sql.gz",
            "source_login": "my_login",
            "source_password": "my_password",
            "local_media_website_path": "[~website_root]/pub/media",
            "local_temp_path": "[~temp_storage]/media"
        },
```
or
```json
        "media": {
            "source_type": "local",
            "source_path": "/var/www/share/dumps/my_project_db_dump.sql.gz",
            "local_media_website_path": "[~website_root]/pub/media",
            "local_temp_path": "[~temp_storage]/media"
        },
```

### Subsection `sources->files_mapping`

Subsection `sources->files_mapping` defines params of media files storage.
The section required for platform tools command `core:remote-files:download`. (see related [DevBox Platform Tools](platform_tools.md))
Defined files will be downloaded to the temp directory specified in the param subsection `local_temp_path`, then all 
downloaded files will be copied to locations specified in subsection `mapping`.

Available value of 'source_type': `owncloud`, `ftp`, `http`, `local`.

Build paths example:
`ftp://my_ftp_host/my_project/devbox_configs_dir/my_config2.yml` -> `/var/www/public_hyml/configs/app_config2.yml`

Examples:
```json
        "files_mapping": {
            "creds": {
                "source_type": "owncloud",
                "source_path": "https://owncloud.mycompany.com/remote.php/webdav/my_project/devbox_configs_dir",
                "source_login": "my_login",
                "source_password": "my_password",
                "local_temp_path": "[~temp_storage]/files"
            },
            "mapping": {
                "my_config1.php": "/var/www/public_hyml/configs/main_config.php",
                "my_config2.yml": "[~website_root]/configs/app_config2.yml",
                "my_config3.xml": "configs/app_config.xml"
            }
        },
```
or
```json
        "files_mapping": {
            "creds": {
                "source_type": "ftp",
                "source_path": "ftp://my_ftp_host/my_project/devbox_configs_dir",
                "source_login": "my_login",
                "source_password": "my_password",
                "local_temp_path": "[~temp_storage]/files"
            },
            "mapping": {
                "my_config1.php": "/var/www/public_hyml/configs/main_config.php",
                "my_config2.yml": "[~website_root]/configs/app_config2.yml",
                "my_config3.xml": "configs/app_config.xml"
            }
        },
```
or
```json
        "files_mapping": {
            "creds": {
                "source_type": "http",
                "source_path": "https://my_http_host/my_project/devbox_configs_dir",
                "source_login": "my_login",
                "source_password": "my_password",
                "local_temp_path": "[~temp_storage]/files"
            },
            "mapping": {
                "my_config1.php": "/var/www/public_hyml/configs/main_config.php",
                "my_config2.yml": "[~website_root]/configs/app_config2.yml",
                "my_config3.xml": "configs/app_config.xml"
            }
        },
```
or
```json
        "files_mapping": {
            "creds": {
                "source_type": "local",
                "source_path": "/var/www/share/my_configs/devbox_configs_dir",
                "local_temp_path": "[~temp_storage]/files"
            },
            "mapping": {
                "my_config1.php": "/var/www/public_hyml/configs/main_config.php",
                "my_config2.yml": "[~website_root]/configs/app_config2.yml",
                "my_config3.xml": "configs/app_config.xml"
            }
        },
```

### Subsection `sources->update_db_data`

In subsection `sources->update_db_data` you can define some database values to be changed.
The section required for platform tools command `core:setup:update-db-data`.
Using this section you can describe in json format base pseudo-sql queries to update database tables.
Also, for Magento 2 tools package the command `core:setup:update-db-data` is executed as part of database dump import process.

For example from the following config
```json
        "update_db_data": {
            "my_table_1": [
                { "set": { "my_column_1": "value_1" }, "where": { "my_column_2": "equals_value_2" } },
                { "set": { "my_column_3": "value_3" }, "where": { "my_column_4": "%like_value_part_4%" } },
                {
                    "replace": { "my_column_5": { "needle": "from_value_5", "replacement": "to_value_5" } },
                    "where":
                    {
                        "my_column_6": "equals_value_6",
                        "and_my_column_7": "%like_value_part_7%"
                    }
                },
                { "set": { "my_column_8": "CONCAT('my_prefix_', value_8)" }, "where": { "my_column_9": "equals_value_9" } },
                { "delete": { }, "where": { "my_column_10": "value_10" } }
            ],
            "my_table_2": [
                { "set": { "my_column_11": "value_11_for_all_records" } },
                { "delete": { }, "where": { "my_column_12": "value_12" } }
            ]
        }
```
package will build and execute the following SQL queries:
```sql
UPDATE my_table_1 SET my_column_1 = value_1 WHERE my_column_2 = 'equals_value_2'
UPDATE my_table_1 SET my_column_3 = value_3 WHERE my_column_4 LIKE '%like_value_part_4%'
UPDATE my_table_1 SET my_column_5 = REPLACE(my_column_5, 'from_value_5', 'to_value_5') WHERE my_column_6 = 'equals_value_6' AND and_my_column_7 LIKE '%like_value_part_7%'
UPDATE my_table_1 SET my_column_8 = CONCAT('my_prefix_', value_8) WHERE my_column_9 = 'equals_value_9'
DELETE FROM my_table_1 WHERE my_column_10 = 'value_10'
UPDATE my_table_2 SET my_column_11 = value_11_for_all_records
DELETE FROM my_table_2 WHERE my_column_12 = 'value_12'
```


### Subsection `sources->domains_mapping` [Magento 2 only]

In subsection `sources->domains_mapping` you can define domains mapping for Magento 2 to update in the table 'core_config_data'.
The section required for platform tools command `magento2:setup:dburls`.
This command replaces all found host values from left key with right value in the magento configuration table 'core_config_data'.

```json
        "domains_mapping": {
            "https://prod.my_magento.com/": "http://my_magento.local/",
            "https://prod.my_magento2.com/": "http://my_magento.local/",
            "https://staging.my_magento2.com/": "http://my_magento.local/"
        },
```

### Subsection `sources->sales_prefix_mapping` [Magento 2 only]

Subsection `sources->sales_prefix_mapping`required for platform tools command `magento2:setup:dburls`.
Here you can define sales prefixes for Magento 2 to be updated.
This command updates prefixes in the database table 'sales_sequence_profile' and optionally it can update increment_id
for existing records in all base Magento 2 sales tables (e.g. sales_order, sales_invoice, etc.)

You can replace certain prefixes
```json
        "sales_prefix_mapping": {
            "STG_AU_" : "LOCAL_AU_",
            "STG_US_" : "LOCAL_US_"
        },
```
or prepend one prefix to all profiles (this default befaviour if this section is empty)
```json
        "sales_prefix_mapping": {
            "" : "LOCAL_"
        },
```

## Section `auto_start_commands`

- In this section you can define platform tools command which should be automatically executed on every project start.

Example:
```json
    "auto_start_commands": {
        "core:setup:permissions": "1"
    }
```

___

## Combined config example of '.env-project.json'

```json
{
    "base_params": {
        "working_directories": {
            "dir_1": "/var/www"
        },
        "temp_storage": {
            "base": "/var/www/temp-dumps"
        }
    },
    "configuration": {
        "node_modules": {
            "use_symlink": true,
            "package_manager": "yarn"
        }
    },
    "sources": {
        "code": {
            "source_type": "vcs",
            "source_path": "git@github.com:my_project/my_repo.git",
            "source_branch": "master"
        },
        "db": {
            "source_type": "owncloud",
            "source_path": "https://owncloud.mycompany.com/remote.php/webdav/my_project/dumps/my_project_db_dump.sql.gz",
            "source_login": "my_login",
            "source_password": "my_password",
            "local_temp_path": "[~temp_storage]/db"
        },
        "media": {
            "source_type": "vcs",
            "source_path": "git@github.com:my_project/my_media_repo.git",
            "source_branch": "master",
            "local_media_website_path": "[~website_root]/pub/media",
            "local_temp_path": "[~temp_storage]/media"
        },
        "files_mapping": {
            "creds": {
                "source_type": "owncloud",
                "source_path": "https://owncloud.mycompany.com/remote.php/webdav/my_project/devbox_configs_dir",
                "source_login": "my_login",
                "source_password": "my_password",
                "local_temp_path": "[~temp_storage]/files"
            },
            "mapping": {
                "my_config1.php": "/var/www/public_hyml/configs/main_config.php",
                "my_config2.yml": "[~website_root]/configs/app_config2.yml",
                "my_config3.xml": "configs/app_config.xml"
            }
        },
        "update_db_data": {
            "my_table_1": [
                { "set": { "my_column_1": "value_1" }, "where": { "my_column_2": "equals_value_2" } },
                { "set": { "my_column_3": "value_3" }, "where": { "my_column_4": "%like_value_part_4%" } },
                {
                    "replace": { "my_column_5": { "needle": "from_value_5", "replacement": "to_value_5" } },
                    "where":
                    {
                        "my_column_6": "equals_value_6",
                        "and_my_column_7": "%like_value_part_7%"
                    }
                },
                { "set": { "my_column_8": "CONCAT('my_prefix_', value_8)" }, "where": { "my_column_9": "equals_value_9" } },
                { "delete": { }, "where": { "my_column_10": "value_10" } }
            ],
            "my_table_2": [
                { "set": { "my_column_11": "value_11_for_all_records" } },
                { "delete": { }, "where": { "my_column_12": "value_12" } }
            ]
        },
        "domains_mapping": {
            "https://prod.my_magento.com/": "http://my_magento.local/",
            "https://prod.my_magento2.com/": "http://my_magento.local/",
            "https://staging.my_magento2.com/": "http://my_magento.local/"
        },
        "sales_prefix_mapping": {
            "STG_AU_" : "LOCAL_AU_",
            "STG_US_" : "LOCAL_US_"
        }
    },
    "auto_start_commands": {
        "core:setup:permissions": "1"
    }
}

```
