module PlayHelpers
  def click_cell(x, y)
    within("table.board") { all("tr")[y].all("td")[x].click }
  end
end
