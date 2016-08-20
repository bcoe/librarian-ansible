require 'librarian/ansible/manifest_reader'

# Install a local role.
module Librarian
  module Ansible
    module Source
      module Local

        def install!(manifest)
          manifest.source == self or raise ArgumentError

          info { "Installing #{manifest.name} (#{manifest.version})" }

          debug { "Installing #{manifest}" }

          name, version = manifest.name, manifest.version
          found_path = found_path(name)

          install_path = environment.install_path.join(name)
          if install_path.exist?
            debug { "Deleting #{relative_path_to(install_path)}" }
            install_path.rmtree
          end

          install_perform_step_copy!(found_path, install_path)
        end

        def fetch_version(name, extra)
          if manifest_data(name).is_a?(Hash) and manifest_data(name).has_key?("version")
            manifest_data(name)["version"]
          else
            "0.0.0"
          end
        end

        def fetch_dependencies(name, version, extra)
          if manifest_data(name).is_a?(Hash) and manifest_data(name).has_key?("dependencies")
            manifest_data(name)["dependencies"]
          end
        end

      private

        def install_perform_step_copy!(found_path, install_path)
          debug { "Copying #{relative_path_to(found_path)} to #{relative_path_to(install_path)}" }
          FileUtils.mkdir_p(install_path)
          FileUtils.cp_r(filter_path(found_path), install_path)
        end

        def filter_path(path)
          Dir.glob("#{path}/*").reject { |e| e == environment.install_path.to_s }
        end

        def manifest_data(name)
          @manifest_data ||= { }
          @manifest_data[name] ||= fetch_manifest_data(name)
        end

        def fetch_manifest_data(name)
          expect_manifest!(name)

          found_path = found_path(name)
          manifest_path = ManifestReader.manifest_path(found_path)
          ManifestReader.read_manifest(name, manifest_path)
        end

        def manifest?(name, path)
          ManifestReader.manifest?(name, path)
        end

        def expect_manifest!(name)
          found_path = found_path(name)
          return if found_path && ManifestReader.manifest_path(found_path)

          raise Error, "No metadata file found for #{name} from #{self}! If this should be an ansible role, you might consider contributing a metadata file upstream or forking the ansible role to add your own metadata file."
        end

      end
    end
  end
end
