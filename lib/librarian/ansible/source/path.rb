require 'librarian/source/path'
require 'librarian/ansible/source/local'

# Install local dependency based on
# file path.
module Librarian
  module Ansible
    module Source
      class Path < Librarian::Source::Path
        include Local
      end
    end
  end
end
