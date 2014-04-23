require 'librarian'
require 'librarian/helpers'
require 'librarian/error'
require 'librarian/action/resolve'
require 'librarian/action/install'
require 'librarian/action/update'
require 'librarian/ansible'

require 'support/project_path'

module Librarian
  module Ansible
    module Source
      describe Git do

        let(:project_path) { ::Support::ProjectPath.project_path }
        let(:tmp_path) { project_path.join("tmp/spec/integration/ansible/source/git") }
        after { tmp_path.rmtree if tmp_path && tmp_path.exist? }

        let(:roles_path) { tmp_path.join("librarian_roles") }

        # depends on repo_path being defined in each context
        let(:env) { Environment.new(:project_path => repo_path) }

        context "with a path" do

          let(:git_path) { tmp_path.join("big-git-repo") }
          let(:sample_path) { git_path.join("buttercup") }
          let(:sample_metadata) do
            { version: "0.6.5" }
          end

          before do
            git_path.rmtree if git_path.exist?
            git_path.mkpath
            sample_path.join('meta').mkpath
            sample_path.join("meta/main.yml").open("wb") { |f| f.write(YAML.dump(sample_metadata)) }
            Dir.chdir(git_path) do
              `git init`
              `git config user.name "Simba"`
              `git config user.email "simba@savannah-pride.gov"`
              `git add .`
              `git commit -m "Initial commit."`
            end
          end

          context "if no path option is given" do
            let(:repo_path) { tmp_path.join("repo/resolve") }
            before do
              repo_path.rmtree if repo_path.exist?
              repo_path.mkpath
              repo_path.join("roles").mkpath
              ansiblefile = Helpers.strip_heredoc(<<-ANSIBLEFILE)
                #!/usr/bin/env ruby
                role "sample",
                  :git => #{git_path.to_s.inspect}
              ANSIBLEFILE
              repo_path.join("Ansiblefile").open("wb") { |f| f.write(ansiblefile) }
            end

            it "should not resolve" do
              expect{ Action::Resolve.new(env).run }.to raise_error
            end
          end

          context "if the path option is wrong" do
            let(:repo_path) { tmp_path.join("repo/resolve") }
            before do
              repo_path.rmtree if repo_path.exist?
              repo_path.mkpath
              repo_path.join("roles").mkpath
              ansiblefile = Helpers.strip_heredoc(<<-ANSIBLEFILE)
                #!/usr/bin/env ruby
                role "sample",
                  :git => #{git_path.to_s.inspect},
                  :path => "jelly"
              ANSIBLEFILE
              repo_path.join("Ansiblefile").open("wb") { |f| f.write(ansiblefile) }
            end

            it "should not resolve" do
              expect{ Action::Resolve.new(env).run }.to raise_error
            end
          end

          context "if the path option is right" do
            let(:repo_path) { tmp_path.join("repo/resolve") }
            before do
              repo_path.rmtree if repo_path.exist?
              repo_path.mkpath
              repo_path.join("roles").mkpath
              ansiblefile = Helpers.strip_heredoc(<<-ANSIBLEFILE)
                #!/usr/bin/env ruby
                role "sample",
                  :git => #{git_path.to_s.inspect},
                  :path => "buttercup"
              ANSIBLEFILE
              repo_path.join("Ansiblefile").open("wb") { |f| f.write(ansiblefile) }
            end

            context "the resolve" do
              it "should not raise an exception" do
                expect { Action::Resolve.new(env).run }.to_not raise_error
              end
            end

            context "the results" do
              before { Action::Resolve.new(env).run }

              it "should create the lockfile" do
                repo_path.join("Ansiblefile.lock").should exist
              end
            end
          end

        end

      end
    end
  end
end
