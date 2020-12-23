#!/bin/bash

while test $# -gt 0; do
	case "$1" in
		"--token")
			gitlab_token="$2"
			shift ;;
	esac
	shift
done

if [[ -z "$gitlab_token" ]]; then
	echo -e "You have to use --token\nVisit https://gitlab.com/-/profile/personal_access_tokens\ncreate token with \"read_api\" role"
	exit 0;
fi

# Create token with "read_api": https://gitlab.com/-/profile/personal_access_tokens
gitlab_token=""
# Directory where all repos will be cloned on local computer
gitlab_clone_directory=$(pwd)
for i in $(seq 1 100); do
	project_list=$(curl "https://gitlab.com/api/v4/projects?private_token=$gitlab_token&min_access_level=50&per_page=50&page=$i" | jq | grep -E '(path_with_namespace|ssh_url_to_repo)' | tr -d ',"' | sed -e 's/^[ \t]*//')

	if [[ -z "$project_list" ]]; then
		break;
	fi

	echo "$project_list" | while read -r git_info
	do
		if [[ $(echo "$git_info" | grep 'path_with_namespace' || true) ]]; then
			group=$(echo "$git_info" | grep 'path_with_namespace' | cut -d' ' -f2)
	        	mkdir -p "$gitlab_clone_directory"/"$group"
		elif [[ $(echo "$git_info" | grep 'ssh_url_to_repo' || true) ]]; then
			git_clone_link=$(echo "$git_info" | grep 'ssh_url_to_repo' | cut -d' ' -f2)
			if [[ -d "$gitlab_clone_directory/$group/.git" ]]; then
				cd "$gitlab_clone_directory"/"$group" || exit
	                	git pull
			else
				git clone "$git_clone_link" "$gitlab_clone_directory"/"$group"
			fi
		else
			echo "There is problem with $git_info"
			continue;
		fi
	done
done
