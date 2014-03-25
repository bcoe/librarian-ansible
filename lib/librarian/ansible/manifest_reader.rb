require 'json'
require 'yaml'

require 'librarian/manifest'

module Librarian
  module Ansible
    module ManifestReader
      extend self

      def manifest_path(path)
        path.join("meta/main.yml")
      end

      def read_manifest(name, manifest_path)
        if [".yml", ".yaml"].include?(manifest_path.extname)
          YAML.load(binread(manifest_path)).tap do |m|
            m["dependencies"] ||= []
          end
        end
      end

      def manifest?(name, path)
        path = Pathname.new(path)
        !!manifest_path(path)
      end

      def check_manifest(name, manifest_path)
        manifest = read_manifest(name, manifest_path)
        manifest["name"] == name
      end

    private

      if File.respond_to?(:binread)
        def binread(path)
          File.binread(path)
        end
      else
        def binread(path)
          File.read(path)
        end
      end

    end
  end
end
