class RenamedExternalReviewersCallIdToCfpId < ActiveRecord::Migration
  def self.up
    rename_column :external_reviewers, :call_id, :cfp_id

    remove_index :external_reviewers, :name => :index_external_reviewers_on_call_id rescue ActiveRecord::StatementInvalid
    add_index :external_reviewers, [:cfp_id]
  end

  def self.down
    rename_column :external_reviewers, :cfp_id, :call_id

    remove_index :external_reviewers, :name => :index_external_reviewers_on_cfp_id rescue ActiveRecord::StatementInvalid
    add_index :external_reviewers, [:call_id]
  end
end
