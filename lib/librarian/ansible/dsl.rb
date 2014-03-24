require 'librarian/dsl'
require 'librarian/ansible/source'

module Librarian
  module Ansible
    class Dsl < Librarian::Dsl

      dependency :role

      source :git => Source::Git
      source :github => Source::Github
      source :path => Source::Path
      source :galaxy => Source::Galaxy
      source :site => Source::Site

    end
  end
end
