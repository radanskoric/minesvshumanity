module GamesHelper
  def cell_tag(cell)
    if cell.is_a? Minesweeper::Board::Mine
      content_tag :td, "💣".html_safe
    elsif cell.neighbour_mines.zero?
      content_tag :td, ""
    else
      content_tag :td, cell.neighbour_mines, class: "c#{cell.neighbour_mines}"
    end
  end

  def game_title(game)
    "Game ##{game.id}: #{game_status(game)}"
  end

  def game_color(game)
    case game.status
      when "play" then "text-indigo-600"
      when "win" then "text-green-600"
      when "lose" then "text-red-600"
    end
  end

  def game_status_full_message(game)
    case game.status
      when "play"
        content_tag(:p, "Game in progress", class: "text-2xl") if game.private?
      when "win"
        content_tag(:p, "#{player_noun(game)} won! :) We thrive over Mines once again!", class: "text-green-600 text-2xl")
      when "lose"
        content_tag(:p, "#{player_noun(game)} lost. :) :( The artifical but not intelligent mines have prevailed.", class: "text-red-600 text-2xl")
    end
  end

  private

  def game_status(game)
    case game.status
      when "play"
        "In progress"
      when "win"
        "#{player_noun(game)} won"
      when "lose"
        "#{player_noun(game)} lost"
    end
  end

  def player_noun(game)
    game.communal? ? "Humanity" : "You"
  end
end
