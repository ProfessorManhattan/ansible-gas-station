#!/bin/bash
# Directory where files for import are located (need to point to root directory of ansible role)
import_files="/Users/bzalewski/Playbooks/misc/common"
# Directory where gitlab repository is located (need to point to directory where roles directory is)
git_repository_dir="/Users/bzalewski/Playbooks"

if [[ -z "$import_files" || -z "$git_repository_dir" ]]; then
	echo "You have not filled variables!"
fi
echo "---" >> /Users/bzalewski/Playbooks/misc/sample.txt
if [[ -d "$git_repository_dir/roles" ]]; then
	# added "not path" part to avoid copying files into .git directory and other hidden directories
	find "$git_repository_dir/roles" -mindepth 2 -maxdepth 2 -type d -not -path '*/\.*' | while read -r gitrepo
	do
		gfind "$import_files" -maxdepth 1 -mindepth 1 -printf "%f\n" | while read -r skriven
                do
                  echo "********************"
                  echo "$gitrepo"
                  echo "********************"
                  cd "$gitrepo" || exit
                  ROLE_DIR=$(echo $gitrepo | awk '{ print substr ($0, 28) }')
                  echo "molecule_$(basename $gitrepo):" >> /Users/bzalewski/Playbooks/misc/sample.txt
                  echo "  stage: test" >> /Users/bzalewski/Playbooks/misc/sample.txt
                  echo "  image: docker:stable-dind" >> /Users/bzalewski/Playbooks/misc/sample.txt
                  echo "  services:" >> /Users/bzalewski/Playbooks/misc/sample.txt
                  echo "    - docker:dind" >> /Users/bzalewski/Playbooks/misc/sample.txt
                  echo "  before_script:" >> /Users/bzalewski/Playbooks/misc/sample.txt
                  echo "    - apk update && apk add --no-cache python3 python3-dev py3-pip gcc git curl build-base autoconf automake py3-cryptography linux-headers musl-dev libffi-dev openssl-dev openssh" >> /Users/bzalewski/Playbooks/misc/sample.txt
                  echo "    - python3 -m pip install ansible molecule[docker]" >> /Users/bzalewski/Playbooks/misc/sample.txt
                  echo "  script:" >> /Users/bzalewski/Playbooks/misc/sample.txt
                  echo "    - cd $ROLE_DIR" >> /Users/bzalewski/Playbooks/misc/sample.txt
                  echo "    - molecule test -s docker" >> /Users/bzalewski/Playbooks/misc/sample.txt
                  echo "  only:" >> /Users/bzalewski/Playbooks/misc/sample.txt
                  echo "    refs:" >> /Users/bzalewski/Playbooks/misc/sample.txt
                  echo "      - branches" >> /Users/bzalewski/Playbooks/misc/sample.txt
                  echo "    changes:" >> /Users/bzalewski/Playbooks/misc/sample.txt
                  echo "      - $ROLE_DIR/**/*.yml" >> /Users/bzalewski/Playbooks/misc/sample.txt
                  echo "" >> /Users/bzalewski/Playbooks/misc/sample.txt
                  #cp -Rf "$import_files/$skriven" "$gitrepo"
                done
	done
else
	echo "Roles directory do not exist in git directory. Did you set right directory path?"
fi
