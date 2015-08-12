require 'librarian/helpers'

require 'librarian/cli'
require 'librarian/ansible'
require 'librarian/ansible/action'

module Librarian
  module Ansible
    class Cli < Librarian::Cli

      module Particularity
        def root_module
          Ansible
        end
      end

      extend Particularity

      source_root Pathname.new(__FILE__).dirname.join("templates")

      def init
        copy_file environment.specfile_name
      end

      desc "install", "Resolves and installs all of the dependencies you specify."
      option "quiet", :type => :boolean, :default => false
      option "verbose", :type => :boolean, :default => false
      option "line-numbers", :type => :boolean, :default => false
      option "clean", :type => :boolean, :default => false
      option "strip-dot-git", :type => :boolean
      option "path", :type => :string
      option "destructive", :type => :boolean, :default => false
      def install
        ensure!
        clean! if options["clean"]
        unless options["destructive"].nil?
          environment.config_db.local['destructive'] = options['destructive'].to_s
        end
        if options.include?("strip-dot-git")
          strip_dot_git_val = options["strip-dot-git"] ? "1" : nil
          environment.config_db.local["install.strip-dot-git"] = strip_dot_git_val
        end
        if options.include?("path")
          environment.config_db.local["path"] = options["path"]
        end

        resolve!
        install!
      end

      private

      # override the actions to use our own

      def install!(options = { })
        Action::Install.new(environment, options).run
      end
    end
  end
end
