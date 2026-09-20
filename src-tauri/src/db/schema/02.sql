-- Journal note content

CREATE TABLE journal_notes (
    note_id INTEGER PRIMARY KEY,
    content TEXT NOT NULL DEFAULT '',
    FOREIGN KEY (note_id) REFERENCES notes(note_id) ON DELETE CASCADE
);

-- Keep the parent note's timestamp current whenever journal content changes.
CREATE TRIGGER trg_journal_notes_content_updated_at
AFTER UPDATE OF content ON journal_notes
FOR EACH ROW
WHEN NEW.content IS NOT OLD.content
BEGIN
    UPDATE notes
    SET updated_at = unixepoch()
    WHERE note_id = NEW.note_id;
END;
