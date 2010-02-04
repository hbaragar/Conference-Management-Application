class Guest < Hobo::Guest

  def administrator?
    false
  end

  def members
    []
  end

end
