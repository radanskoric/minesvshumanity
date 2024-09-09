Planned improvements:
- Use `insert_all` to insert mines when creating a board.
- Switch page refresh after game over to use refresh instead of full page reload. For some reason, Action Cable is not connected to the new game after a refresh. Need to debug this before using `Turbo.session.refresh(document.baseURI)`.
- add chording - it lets you click on a number to reveal the surrounding squares as long as it is correctly flagged. (Old school implementation use left+right click at the same time, though some modern clones just use left click)
- Investigate how to improve latency further.


