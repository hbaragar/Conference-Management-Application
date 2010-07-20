class Guest < Hobo::Guest

  def administrator?
    false
  end

  def portfolio_chair?
    false
  end

  def members
    []
  end

end
