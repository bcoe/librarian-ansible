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

        context "a single dependency with a git source" do

          let(:sample_path) { tmp_path.join("sample") }
          let(:sample_metadata) do
            { version: "0.6.5" }
          end

          let(:first_sample_path) { roles_path.join("first-sample") }
          let(:first_sample_metadata) do
            { version: "3.2.1" }
          end

          let(:second_sample_path) { roles_path.join("second-sample") }
          let(:second_sample_metadata) do
            { version: "4.3.2" }
          end

          before do
            sample_path.rmtree if sample_path.exist?
            sample_path.join('meta').mkpath
            sample_path.join("meta/main.yml").open("wb") { |f| f.write(YAML.dump(sample_metadata)) }
            Dir.chdir(sample_path) do
              `git init`
              `git config user.name "Simba"`
              `git config user.email "simba@savannah-pride.gov"`
              `git add meta/main.yml`
              `git commit -m "Initial commit."`
            end

            roles_path.rmtree if roles_path.exist?
            roles_path.mkpath
            first_sample_path.join('meta').mkpath
            first_sample_path.join("meta/main.yml").open("wb") { |f| f.write(YAML.dump(first_sample_metadata)) }
            second_sample_path.join('meta').mkpath
            second_sample_path.join("meta/main.yml").open("wb") { |f| f.write(YAML.dump(second_sample_metadata)) }
            Dir.chdir(roles_path) do
              `git init`
              `git config user.name "Simba"`
              `git config user.email "simba@savannah-pride.gov"`
              `git add .`
              `git commit -m "Initial commit."`
            end
          end

          context "resolving" do
            let(:repo_path) { tmp_path.join("repo/resolve") }
            before do
              repo_path.rmtree if repo_path.exist?
              repo_path.mkpath
              repo_path.join("librarian_roles").mkpath
              ansiblefile = Helpers.strip_heredoc(<<-ANSIBLEFILE)
                #!/usr/bin/env ruby
                role "sample", :git => #{sample_path.to_s.inspect}
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

              it "should not attempt to install the sample cookbok" do
                repo_path.join("librarian_roles/sample").should_not exist
              end
            end
          end

          context "installing" do
            let(:repo_path) { tmp_path.join("repo/install") }
            before do
              repo_path.rmtree if repo_path.exist?
              repo_path.mkpath
              repo_path.join(roles_path).mkpath
              ansiblefile = Helpers.strip_heredoc(<<-ANSIBLEFILE)
                #!/usr/bin/env ruby
                role "sample", :git => #{sample_path.to_s.inspect}
              ANSIBLEFILE
              repo_path.join("Ansiblefile").open("wb") { |f| f.write(ansiblefile) }

              Action::Resolve.new(env).run
            end

            context "the install" do
              it "should not raise an exception" do
                expect { Action::Install.new(env).run }.to_not raise_error
              end
            end

            context "the results" do
              before { Action::Install.new(env).run }

              it "should create the lockfile" do
                repo_path.join("Ansiblefile.lock").should exist
              end

              it "should create the directory for the role" do
                repo_path.join("librarian_roles/sample").should exist
              end

              it "should copy the role files into the role directory" do
                repo_path.join("librarian_roles/sample/meta/main.yml").should exist
              end
            end
          end

          context "resolving and and separately installing" do
            let(:repo_path) { tmp_path.join("repo/resolve-install") }
            before do
              repo_path.rmtree if repo_path.exist?
              repo_path.mkpath
              repo_path.join("librarian_roles").mkpath
              ansiblefile = Helpers.strip_heredoc(<<-ANSIBLEFILE)
                #!/usr/bin/env ruby
                role "sample", :git => #{sample_path.to_s.inspect}
              ANSIBLEFILE
              repo_path.join("Ansiblefile").open("wb") { |f| f.write(ansiblefile) }

              Action::Resolve.new(env).run
              repo_path.join("tmp").rmtree if repo_path.join("tmp").exist?
            end

            context "the install" do
              it "should not raise an exception" do
                expect { Action::Install.new(env).run }.to_not raise_error
              end
            end

            context "the results" do
              before { Action::Install.new(env).run }

              it "should create the directory for the role" do
                repo_path.join("librarian_roles/sample").should exist
              end

              it "should copy the role files into the role directory" do
                repo_path.join("librarian_roles/sample/meta/main.yml").should exist
              end
            end
          end

        end

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
              repo_path.join("librarian_roles").mkpath
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
              repo_path.join("librarian_roles").mkpath
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
              repo_path.join("librarian_roles").mkpath
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

        context "when upstream updates" do
          let(:git_path) { tmp_path.join("upstream-updates-repo") }
          let(:repo_path) { tmp_path.join("repo/resolve-with-upstream-updates") }

          let(:sample_metadata) do
            { version: "0.6.5" }
          end

          before do

            # set up the git repo as normal, but let's also set up a release-stable branch
            # from which our Ansiblefile will only pull stable releases
            git_path.rmtree if git_path.exist?
            git_path.join('meta').mkpath
            git_path.join("meta/main.yml").open("wb") { |f| f.write(YAML.dump(sample_metadata)) }

            Dir.chdir(git_path) do
              `git init`
              `git config user.name "Simba"`
              `git config user.email "simba@savannah-pride.gov"`
              `git add meta/main.yml`
              `git commit -m "Initial Commit."`
              `git checkout -b some-branch --quiet`
              `echo 'hi' > some-file`
              `git add some-file`
              `git commit -m 'Some File.'`
              `git checkout master --quiet`
            end

            # set up the ansible repo as normal, except the Ansiblefile points to the release-stable
            # branch - we expect when the upstream copy of that branch is changed, then we can
            # fetch & merge those changes when we update
            repo_path.rmtree if repo_path.exist?
            repo_path.mkpath
            repo_path.join("librarian_roles").mkpath
            ansiblefile = Helpers.strip_heredoc(<<-ANSIBLEFILE)
              role "sample",
                :git => #{git_path.to_s.inspect},
                :ref => "some-branch"
            ANSIBLEFILE
            repo_path.join("Ansiblefile").open("wb") { |f| f.write(ansiblefile) }
            Action::Resolve.new(env).run

            # change the upstream copy of that branch: we expect to be able to pull the latest
            # when we re-resolve
            Dir.chdir(git_path) do
              `git checkout some-branch --quiet`
              `echo 'ho' > some-other-file`
              `git add some-other-file`
              `git commit -m 'Some Other File.'`
              `git checkout master --quiet`
            end
          end

          let(:metadata_file) { repo_path.join("librarian_roles/sample/meta/main.yml") }
          let(:old_code_file) { repo_path.join("librarian_roles/sample/some-file") }
          let(:new_code_file) { repo_path.join("librarian_roles/sample/some-other-file") }

          context "when updating not a role from that source" do
            before do
              Action::Update.new(env).run
            end

            it "should pull the tip from upstream" do
              Action::Install.new(env).run

              metadata_file.should exist #sanity
              old_code_file.should exist #sanity

              new_code_file.should_not exist # the assertion
            end
          end

          context "when updating a role from that source" do
            before do
              Action::Update.new(env, :names => %w(sample)).run
            end

            it "should pull the tip from upstream" do
              pending('debug "should pull the tip from upstream"')

              Action::Install.new(env).run

              metadata_file.should exist #sanity
              old_code_file.should exist #sanity

              new_code_file.should exist # the assertion
            end
          end
        end

      end
    end
  end
end
