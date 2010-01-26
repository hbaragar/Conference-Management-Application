class FixedFormatUrlTypoInCfps < ActiveRecord::Migration
  def self.up
    change_column :cfps, :format_url, :string, :limit => 255, :default => "http://www.acm.org/sigs/sigplan/authorInformation.htm"
  end

  def self.down
    change_column :cfps, :format_url, :string, :default => "http://cyberchair.acm.org/oopslapapers/submit/"
  end
end
