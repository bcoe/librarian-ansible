require 'librarian/ansible/environment'

module Librarian
  module Ansible
    extend self
    extend Librarian
  end
end

require "ext/librarian/lockfile/parser"
