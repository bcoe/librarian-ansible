Librarian-Ansible
=================

[![Code Climate](https://codeclimate.com/github/bcoe/librarian-ansible.png)](https://codeclimate.com/github/bcoe/librarian-ansible)
[![Build Status](https://travis-ci.org/bcoe/librarian-ansible.png)](https://travis-ci.org/bcoe/librarian-ansible)

Provides bundler-inspired functionality for Ansible roles:

http://bundler.io/v1.3/rationale.html

This is a port of [librarian-chef](https://github.com/applicationsonline/librarian-chef)

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
  :github => "pgolm/ansible-playbook-monit"

role "ansible-role-nagios-nrpe-server",
  ">=0.0.0",
  :path => "./roles/ansible-role-nagios-nrpe-server"
```

Your dependencies can be:

* Ansible Galaxy IDs:

```ruby
role "kunik.deploy-upstart-scripts"
```

* paths to local files:

```ruby
role "ansible-role-nagios-nrpe-server", :path => "./roles/ansible-role-nagios-nrpe-server"
```

* Github username/project pairs:

```ruby
role "pgolm.ansible-playbook-monit", :github => "pgolm/ansible-playbook-monit"
```

* Git repos (master branch):

```ruby
role "pgolm.ansible-playbook-monit", :git => "git@github.com:pgolm/ansible-playbook-monit.git"
```

* Git repos and check out a tag (or anything that git will recognize as a ref)

```ruby
role "varnish",
    :git => "git@github.com:geerlingguy/ansible-role-varnish",
    :ref => "1.0.0"
```

Installing Dependencies
-----------------------

To install your dependencies, simply run:

```bash
librarian-ansible install
```

The first time you run this, an Ansible.lock file will be created which should be checked into your repo. This file ensures that other developers are pinned to the appropriate role versions.

Specifying Version #s
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

Specifying git branch
---------------------

librarian-ansible support git branch checkout, using the `ref` attribute:

```ruby
role "pgolm.ansible-playbook-monit", git: "git@github.com:pgolm/ansible-playbook-monit.git", ref: "origin/develop"
```

### Configuration

Configuration comes from three sources with the following highest-to-lowest
precedence:

* The local config (`./.librarian/ansible/config`)
* The environment
* The global config (`~/.librarian/ansible/config`)

You can inspect the final configuration with:

    $ librarian-ansible config

You can find out where a particular key is set with:

    $ librarian-ansible config KEY

You can set a key at the global level with:

    $ librarian-ansible config KEY VALUE --global

And remove it with:

    $ librarian-ansible config KEY --global --delete

You can set a key at the local level with:

    $ librarian-ansible config KEY VALUE --local

And remove it with:

    $ librarian-ansible config KEY --local --delete

You cannot set or delete environment-level config keys with the CLI.

Configuration set at either the global or local level will affect subsequent
invocations of `librarian-ansible`. Configurations set at the environment level are
not saved and will not affect subsequent invocations of `librarian-ansible`.

You can pass a config at the environment level by taking the original config key
and transforming it: replace hyphens (`-`) with underscores (`_`) and periods
(`.`) with doubled underscores (`__`), uppercase, and finally prefix with
`LIBRARIAN_ANSIBLE_`. For example, to pass a config in the environment for the key
`part-one.part-two`, set the environment variable
`LIBRARIAN_ANSIBLE_PART_ONE__PART_TWO`.

Configuration affects how various commands operate.

* The `path` config sets the roles directory to install to. If a relative
  path, it is relative to the directory containing the `Ansiblefile`. The
  equivalent environment variable is `LIBRARIAN_ANSIBLE_PATH`.

* The `tmp` config sets the cache directory for librarian. If a relative
  path, it is relative to the directory containing the `Ansiblefile`. The
  equivalent environment variable is `LIBRARIAN_ANSIBLE_TMP`.

* The `install.strip-dot-git` config causes the `.git/` directory to be stripped
  out when installing roles from a git source. This must be set to exactly
  "1" to cause this behavior. The equivalent environment variable is
  `LIBRARIAN_ANSIBLE_INSTALL__STRIP_DOT_GIT`.

Configuration can be set by passing specific options to other commands.

* The `path` config can be set at the local level by passing the `--path` option
  to the `install` command. It can be unset at the local level by passing the
  `--no-path` option to the `install` command. Note that if this is set at the
  environment or global level then, even if `--no-path` is given as an option,
  the environment or global config will be used.

* The `install.strip-dot-git` config can be set at the local level by passing
  the `--strip-dot-git` option to the `install` command. It can be unset at the
  local level by passing the `--no-strip-dot-git` option.

Note that the directories will be purged if you run librarian-ansible with the
--clean or --destructive flags.

## Contributing

1. Fork it ( http://github.com/bcoe/librarian-ansible/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
