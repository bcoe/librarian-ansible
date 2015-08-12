require 'librarian/action/install'

module Librarian
  module Ansible
    module Action
      class Install < Librarian::Action::Install

        private

        def create_install_path
          install_path.rmtree if install_path.exist? && destructive?
          install_path.mkpath
        end

        def destructive?
          environment.config_db.local['destructive'] == 'true'
        end

      end
    end
  end
end
