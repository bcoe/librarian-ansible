require_relative "../../support/spec_helper"
require "librarian/ansible/cli"

module Librarian
  module Ansible
    describe Cli do
      include Librarian::RSpec::Support::CliMacro

      describe "init" do
        before do
          cli! "init"
        end

        it "should create a file named Ansiblefile" do
          pwd.should have_file "Ansiblefile"
        end
      end

      describe "version" do
        before do
          cli! "version"
        end

        it "should print the version" do
          stdout.should == strip_heredoc(<<-STDOUT)
            librarian-#{Librarian::VERSION}
            librarian-ansible-#{Librarian::Ansible::VERSION}
          STDOUT
        end
      end

      describe "install" do

        context "a simple Ansiblefile with one role" do
          let(:metadata) do
            { "name" => "apt",
              "version" => "1.0.0" }
          end

          before do
            write_yaml_file! "role-sources/apt/meta/main.yml", metadata
            write_file! "Ansiblefile", strip_heredoc(<<-ANSIBLEFILE)
              role 'apt',
                :path => 'role-sources/apt'
            ANSIBLEFILE

            cli! "install"
          end

          it "should write a lockfile" do
            pwd.should have_file "Ansiblefile.lock"
          end

          it "should install the role" do
            pwd.should have_yaml_file "librarian_roles/apt/meta/main.yml", metadata
          end
        end

      end

    end
  end
end
