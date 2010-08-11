class Joomla < ActiveRecord::Base

  def before_validation
    self.alias = title.tr("A-Z","a-z").gsub(/\W+/,"-") unless self.alias && self.alias[/\w/]
  end
 
end
