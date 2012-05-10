namespace :deploy do
  desc "Post Deploy actions"
  task :post_deploy => :environment do
    system "git log -1"
    Rake::Task["db:migrate"].invoke
    Rake::Task["hobo:generate_taglibs"].invoke
    system "touch tmp/restart.txt"
  end
  task :now do
    system "git push"
  end
end
