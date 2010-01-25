class Cfp < ActiveRecord::Base

  hobo_model # Don't put anything above this

  belongs_to :portfolio

  fields do
    due_on        :date, :required
    format_style  :string, :default => "ACM Proceedings format"
    format_url    :string, :default => "http://cyberchair.acm.org/oopslapapers/submit/"
    submit_to_url :string, :default => "http://cyberchair.acm.org/splash???/submit/"
    details       :text, :default => "To be completed by the portfolio chair"
    timestamps
  end


  # --- Permissions --- #

  def create_permitted?
    acting_user.administrator?
  end

  def update_permitted?
    acting_user.administrator?
  end

  def destroy_permitted?
    acting_user.administrator?
  end

  def view_permitted?(field)
    true
  end

end
