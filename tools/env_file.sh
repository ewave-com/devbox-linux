#!/bin/bash
# info: actions with env file

#Prepare ENV file. Delete '\r' '\n' from file
prepare_env(){
sudo chmod -R 777 ./projects/"$project_folder"/.env && sudo chown -R www-data:www-data ./projects/"$project_folder"/.env
sudo tr '\r' '\n' < ./projects/"$project_folder"/.env > ./projects/"$project_folder"/newfile.env
sudo chmod -R 777 ./projects/"$project_folder"/newfile.env && sudo chown -R www-data:www-data ./projects/"$project_folder"/newfile.env
mv ./projects/"$project_folder"/newfile.env ./projects/"$project_folder"/.env
}

###########################################
# Function which set variable from ENV file
set_env(){
export $(cat ./projects/"$project_folder"/.env | grep -Ev "^$" | grep -v '^#' | xargs)
}

# Function which unset variable from ENV file
# Run function ONLY in the END
unset_env(){
unset $(cat ./projects/"$project_folder"/.env | grep -Ev "^$"  | grep -v '^#' | sed -E 's/(.*)=.*/\1/' | xargs)
}
###########################################
