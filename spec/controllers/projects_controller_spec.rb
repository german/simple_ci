require 'spec_helper'

describe ProjectsController do
  render_views
  
  let(:project) { FactoryGirl.create(:project) }
  let(:user) { FactoryGirl.create(:user, :projects => [project]) }
  
  describe "preferences page" do
    before do
      visit new_user_session_path
      fill_in :user_email, :with => user.email
      fill_in :user_password, :with => "12345678"
      click_button "Sign in"
      
      Build.any_instance.stubs(:enqueue_task).returns(true)
    end

    context "running build" do
      before { 
        visit "/projects"  
      }
      
      it "succeed" do
        expect { project.created? }.to be
        click_link "Run"
        BuildRunner.run(Build.last.id)
        expect { Build.last.running? }.to be
        expect(project.state).to eq('success')
      end
      
      #it "allows multiple builds to be running concurrently" do
      #  expect { project.created? }.to be  
      #  t1 = Thread.new do
      #    click_link "Run"
      #    BuildRunner.run(Build.last.id)
      #    expect { Build.last.running? }.to be
      #  end  
      #  t2 = Thread.new do
      #    click_link "Run"
      #    BuildRunner.run(Build.first.id)
      #    expect { Build.first.enqueued? }.to be
      #  end
      #  t1.join
      #  t2.join
      #  puts project.inspect
      #  expect(project.state).to eq('success')
      #end
    end

    context "valid changes" do
      before { visit "/projects/#{project.id}/preferences"  }
            
      it "saves name and path_to_rails_root properly" do
        fill_in :project_name, :with => "Hello, World"
        fill_in :project_path_to_rails_root, :with => Rails.root.to_s
        click_button "Save"
        expect(page).to have_content("Project sucessfully saved")
        project.reload
        expect(project.name).to eq("Hello, World")
        expect(project.path_to_rails_root).to eq(Rails.root.to_s)
      end
      
      it "couldn't save empty name" do
        fill_in :project_name, :with => ""
        fill_in :project_path_to_rails_root, :with => Rails.root.to_s
        expect {
          click_button "Save"
          expect(page).to have_content("errors while saving")
        }.not_to change{project.name}
      end

      it "couldn't save empty path_to_rails_root" do
        fill_in :project_name, :with => "Test"
        fill_in :project_path_to_rails_root, :with => ""
        expect {
          click_button "Save"
          expect(page).to have_content("errors while saving")
        }.not_to change{project.path_to_rails_root}
      end
      
      it "couldn't save invalid path_to_rails_root" do
        fill_in :project_name, :with => "Test"
        fill_in :project_path_to_rails_root, :with => "/home/my/projects"
        expect {
          click_button "Save"
          expect(page).to have_content("errors while saving")
        }.not_to change{project.path_to_rails_root}
      end
    end
  end
end
