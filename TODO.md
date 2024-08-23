Planned improvements:
- Use `insert_all` to insert mines when creating a board.
- Extract game creation into a form object created with ActiveModel.
- Switch page refresh after game over to use refresh instead of full page reload. For some reason, Action Cable is not connected to the new game after a refresh. Need to debug this before using `Turbo.session.refresh(document.baseURI)`.
