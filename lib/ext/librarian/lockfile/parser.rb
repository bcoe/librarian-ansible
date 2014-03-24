#
# For Ansible, allow "." in package names.
#
require 'librarian/manifest'
require 'librarian/dependency'
require 'librarian/manifest_set'

module Librarian
  class Lockfile
    class Parser

      def extract_and_parse_sources(lines)
        sources = []
        while source_type_names.include?(lines.first)
          source = {}
          source_type_name = lines.shift
          source[:type] = source_type_names_map[source_type_name]
          options = {}
          while lines.first =~ /^ {2}([\w-]+):\s+(.+)$/
            lines.shift
            options[$1.to_sym] = $2
          end
          source[:options] = options
          lines.shift # specs
          manifests = {}
          while lines.first =~ /^ {4}([.\w-]+) \((.*)\)$/
            lines.shift
            name = $1
            manifests[name] = {:version => $2, :dependencies => {}}
            while lines.first =~ /^ {6}([\w-]+) \((.*)\)$/
              lines.shift
              manifests[name][:dependencies][$1] = $2.split(/,\s*/)
            end
          end
          source[:manifests] = manifests
          sources << source
        end
        sources
      end

      def extract_and_parse_dependencies(lines, manifests_index)
        dependencies = []
        while lines.first =~ /^ {2}([.\w-]+)(?: \((.*)\))?$/
          lines.shift
          name, requirement = $1, $2.split(/,\s*/)
          dependencies << Dependency.new(name, requirement, manifests_index[name].source)
        end
        dependencies
      end

    end
  end
end
