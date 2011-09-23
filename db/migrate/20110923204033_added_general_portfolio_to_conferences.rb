class AddedGeneralPortfolioToConferences < ActiveRecord::Migration

  def self.up
    add_column :conferences, :general_portfolio_id, :integer
    Portfolio.find_all_by_name("General").each do |p|
      c = p.conference
      c.general_portfolio = p
      c.save
    end
    add_index :conferences, [:general_portfolio_id]
  end

  def self.down
    Conference.all.each do |c|
      p = c.general_portfolio
      p.name = "General"
      p.save
    end
    remove_column :conferences, :general_portfolio_id
    remove_index :conferences, :name => :index_conferences_on_general_portfolio_id rescue ActiveRecord::StatementInvalid
  end

end
