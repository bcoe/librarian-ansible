Librarian::Ansible
=================

Port of librarian-chef, providing bundler functionality for Ansible roles.

Installation
------------

```bash
gem install librarian-ansible
```

Ansiblefile: Describing Your Dependencies
---------------------------------------------

To document the external Ansible roles you rely on, simply place them in an Ansiblefile:

_An Example Ansiblefile:_

```ruby
#!/usr/bin/env ruby
#^syntax detection

site "https://galaxy.ansible.com/api/v1"

role "kunik.deploy-upstart-scripts"

role "pgolm.ansible-playbook-monit",
  github: "pgolm/ansible-playbook-monit"

role "ansible-role-nagios-nrpe-server",
  ">=0.0.0",
  path: "./roles/ansible-role-nagios-nrpe-server"
```

Your dependencies can be:

* Ansible Galaxy IDs:

```ruby
role "kunik.deploy-upstart-scripts"
```

* paths to local files:

```ruby
role "ansible-role-nagios-nrpe-server", path: "./roles/ansible-role-nagios-nrpe-server"
```

* Github username/project pairs:

```ruby
role "pgolm.ansible-playbook-monit", github: "pgolm/ansible-playbook-monit"
```

* Git repos:

```ruby
role "pgolm.ansible-playbook-monit", git: "git@github.com:pgolm/ansible-playbook-monit.git"
```

Installing Dependencies
-----------------------

To install your dependencies, simply run:

```bash
librarian-ansible install
```

The first time you run this, an Ansible.lock file will be created which should be checked into your repo. This file ensures that other developers are pinned to the appropriate role versions.

On Version #s
-------------

librarian-ansible supports version #s, simply add one to your `meta/main.yml` file:

```yml
---
galaxy_info:
  author: Peter Golm
  license: MIT
  min_ansible_version: 1.4
  platforms:
    - name: Ubuntu
      versions:
        - raring
        - saucy

  categories:
    - monitoring
    - system
dependencies: []
version: 2.0.0
```

And update your Ansiblefile accordingly:

```ruby
role "kunik.deploy-upstart-scripts", "1.0.0"
```

## Contributing

1. Fork it ( http://github.com/<my-github-username>/librarian-ansible/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
