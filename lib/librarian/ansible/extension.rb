require 'librarian/ansible/environment'
require 'librarian/action/base'

module Librarian
  module Ansible
    extend self
    extend Librarian
  end
end

require "ext/librarian/lockfile/parser"
