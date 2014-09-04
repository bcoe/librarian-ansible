require "librarian/ansible/source/git"
require "faraday"

# Lookup an Ansible role in Galaxy API, using
# github_user and package name.
module Librarian
  module Ansible
    module Source
      class Galaxy

        @@galaxy_api = "https://galaxy.ansible.com/api/v1/"

        class << self

          def galaxy_api=(galaxy_api)
            @@galaxy_api = galaxy_api
          end

          def lock_name
            Git.lock_name
          end

          def from_lock_options(environment, options)
            Git.from_lock_options(environment, options)
          end

          def from_spec_args(environment, uri, options)
            Git.from_spec_args(environment, github_url(uri), options)
          end

          private

          def github_url(uri)
            package = nil
            # because both name and username can contain dots, we have
            # to check every combination until package will be found
            segments = uri.split('.')
            (0..segments.size - 2).each do |pivot|
              username = segments[0..pivot].join('.')
              name = segments[pivot + 1..-1].join('.')
              package = lookup_package(username, name)
            end
            raise Error, "Could not find package: #{uri}" if package.nil?
            "https://github.com/#{package['github_user']}/#{package['github_repo']}"
          end

          def lookup_package(username, name)
            conn = Faraday.new(:url => @@galaxy_api)

            url = "#{@@galaxy_api}/roles/?name=#{name}&format=json"
            loop do
              response = conn.get(url)
              if response.status != 200
                raise Error, 'Could not read package from galaxy API.'
              else
                json = JSON.parse(response.body)
                package = json['results'].find do |r|
                  r['summary_fields']['owner']['username'] == username &&
                    r['name'] == name
                end
                return package if package
                url = json['next']
                break unless url
              end
            end
          end
        end
      end
    end
  end
end
