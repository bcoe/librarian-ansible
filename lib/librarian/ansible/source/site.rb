require 'librarian/source/path'
require 'librarian/ansible/source/git'
require 'librarian/ansible/source/galaxy'

# Set the Galaxy API url, using the
# site directive.
module Librarian
  module Ansible
    module Source
      class Site

        class << self

          def lock_name
            Git.lock_name
          end

          def from_lock_options(environment, options)
            Git.from_lock_options(environment, options)
          end

          def from_spec_args(environment, uri, options)
            Galaxy.galaxy_api = uri
          end

        end
      end
    end
  end
end
