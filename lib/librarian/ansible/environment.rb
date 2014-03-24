require "librarian/environment"
require "librarian/ansible/dsl"
require "librarian/ansible/source"
require "librarian/ansible/version"

require "ext/librarian/dsl/target"

module Librarian
  module Ansible
    class Environment < Environment

      def adapter_name
        "ansible"
      end

      def adapter_version
        VERSION
      end

      def install_path
        part = config_db["path"] || "librarian_roles"
        project_path.join(part)
      end

      def config_keys
        super + %w[
          install.strip-dot-git
          path
        ]
      end

    end
  end
end
