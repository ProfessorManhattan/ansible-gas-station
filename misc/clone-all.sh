#!/bin/bash

# Create token with "read_api": https://gitlab.com/-/profile/personal_access_tokens
gitlab_token=""
# Directory where all repos will be cloned on local computer
gitlab_clone_directory="/home/git"

project_list=$(curl "https://gitlab.com/api/v4/projects?private_token=$gitlab_token&min_access_level=50" | jq | grep -E '(path_with_namespace|ssh_url_to_repo)' | tr -d ',"' | sed -e 's/^[ \t]*//')

echo "$project_list" | while read -r git_info
do
        if [[ $(echo "$git_info" | grep 'path_with_namespace' || true) ]]; then
                group=$(echo "$git_info" | grep 'path_with_namespace' | cut -d' ' -f2)
                mkdir -p "$gitlab_clone_directory"/"$group"
        elif [[ $(echo "$git_info" | grep 'ssh_url_to_repo' || true) ]]; then
                git_clone_link=$(echo "$git_info" | grep 'ssh_url_to_repo' | cut -d' ' -f2)
                git clone "$git_clone_link" "$gitlab_clone_directory"/"$group"
        else
                echo "There is problem with $git_info"
                continue;
        fi
done
