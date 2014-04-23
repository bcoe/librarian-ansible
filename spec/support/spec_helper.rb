require "librarian/rspec/support/cli_macro"

class FileMatcher < Librarian::RSpec::Support::CliMacro::FileMatcher
  def actual_content
    @actual_content ||= begin
      content = full_path.read
      content = JSON.parse(content) if type == :json
      content = YAML.load(content) if type == :yaml
      content
    end
  end

  def failure_message
    if full_path.file?
      "file content does not match"
    else
      "no file matches path #{rel_path}"
    end
  end
end

def write_yaml_file!(path, content)
  write_file! path, YAML.dump(content)
end

def have_yaml_file(rel_path, content)
  FileMatcher.new(rel_path, content, :type => :yaml)
end
