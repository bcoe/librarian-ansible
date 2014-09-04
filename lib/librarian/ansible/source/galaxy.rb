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
            username, name = uri.split(".")

            conn = Faraday.new(:url => @@galaxy_api)

            response = conn.get("#{@@galaxy_api}/roles/?name=#{name}&format=json")

            if response.status != 200
              raise Error, "Could not read package from galaxy API."
            else
              package = JSON.parse(response.body)['results'].find do |r|
                r['summary_fields']['owner']['username'] == username &&
                  r['name'] == name
              end
            end

            raise Error, "Could not find package #{uri}" if package.nil?
            "https://github.com/#{package['github_user']}/#{package['github_repo']}"
          end

        end

      end
    end
  end
end
