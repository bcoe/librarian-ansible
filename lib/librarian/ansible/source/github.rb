require 'librarian/ansible/source/git'

# Install an ansible role based on github_user/github_repo
# format.
module Librarian
  module Ansible
    module Source
      class Github

        class << self

          def lock_name
            Git.lock_name
          end

          def from_lock_options(environment, options)
            Git.from_lock_options(environment, options)
          end

          def from_spec_args(environment, uri, options)
            Git.from_spec_args(environment, "https://github.com/#{uri}", options)
          end

        end

      end
    end
  end
end
