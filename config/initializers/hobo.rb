Hobo::ModelRouter.reload_routes_on_every_request = true
# Hobo::Dryml.precompile_taglibs if File.basename($0) != "rake" && Rails.env.production? 

HoboFields::MigrationGenerator.ignore_tables = %w(jos_menu jos_sections jos_categories jos_content)
