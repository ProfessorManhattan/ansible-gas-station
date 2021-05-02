#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright: (c) 2018, Dincer Celik <hello@dincercelik.com>
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

ANSIBLE_METADATA = {'metadata_version': '1.1',
                    'status': ['preview'],
                    'supported_by': 'community'}

DOCUMENTATION = '''
---
module: snap
short_description: Manage snap packages
description:
  - This module can install, remove, refresh, enable, and disable snap packages.
version_added: '2.5'
author: 'Dincer Celik (@dincercelik)'
options:
  name:
    description:
      - Name of snap package
    required: true
  state:
    description:
      - State of snap package
    choices:
      - present
      - absent
      - refresh
      - enabled
      - disabled
    default: present
  classic:
    description:
      - Install package with classic confinement policy
    default: 'no'
    type: bool
  beta:
    description:
      - Install package from beta channel
    default: 'no'
    type: bool
'''

EXAMPLES = '''
- name: Install the package "hello-world"
  snap:
    name: hello-world
    state: present

- name: Install the package "hello-world" with classic confinement policy
  snap:
    name: hello-world
    state: present
    classic: yes

- name: Install the package "hello-world" from beta channel
  snap:
    name: hello-world
    state: present
    beta: yes

- name: Remove the package "hello-world"
  snap:
    name: hello-world
    state: absent

- name: Update the package "hello-world"
  snap:
    name: hello-world
    state: refresh

- name: Disable the package "hello-world"
  snap:
    name: hello-world
    state: disabled

- name: Enable the package "hello-world"
  snap:
    name: hello-world
    state: enabled
'''

try:
    import os
    import subprocess
except:
    error = 'The Ansible snap module requires os and subprocess libraries.'
    module_not_found = True
else:
    module_not_found = False

try:
    snap = open('/usr/bin/snap')
    snap.close
except:
    error = 'Snap installation missing.'
    snap_not_found = True
else:
    snap_not_found = False

from ansible.module_utils.basic import AnsibleModule

def snappy(data):
    package = data['name']
    is_classic = data['classic']
    is_beta = data['beta']
    action = data['state']
    commands = {
        'present': 'install',
        'absent': 'remove',
        'refresh': 'refresh',
        'enabled': 'enable',
        'disabled': 'disable'
    }
    parameter = commands.get(action)

    if parameter is 'install':
        if is_classic:
            proc = subprocess.Popen(['snap', 'install', package, '--classic'], stdout = subprocess.PIPE)
        elif is_beta:
            proc = subprocess.Popen(['snap', 'install', package, '--beta'], stdout = subprocess.PIPE)
        elif is_classic and is_beta:
            proc = subprocess.Popen(['snap', 'install', package, '--classic', '--beta'], stdout = subprocess.PIPE)
        else:
            proc = subprocess.Popen(['snap', 'install', package], stdout = subprocess.PIPE)
    else:
        proc = subprocess.Popen(['snap', parameter, package], stdout = subprocess.PIPE)

    (output, error) = proc.communicate()
    status = proc.wait()

    has_changed = False
    if output and not error:
        has_changed = True

    meta = {
        'package': package,
        'stdout': output,
        'stderr': error,
        'status': status
    }

    return (has_changed, meta)

def main():
    fields = {
        'name': {'required': True, 'type': 'str'},
        'classic': {'default': False, 'type': 'bool'},
        'beta': {'default': False, 'type': 'bool'},
        'state': {
            'default': 'present',
            'choices': ['present', 'absent', 'refresh', 'enabled', 'disabled'],
            'type': 'str'
        }
    }
    choice_map = {
        'present': snappy,
        'absent': snappy,
        'refresh': snappy,
        'enabled': snappy,
        'disabled': snappy
    }

    module = AnsibleModule(argument_spec = fields)
    (has_changed, result) = choice_map.get(module.params['state'])(module.params)

    if module_not_found or snap_not_found:
        module.fail_json(msg = error)
    else:
        module.exit_json(changed = has_changed, meta = result)

if __name__ == '__main__':
    main()
