-- Note title history/timestamp behavior

-- Keep updated_at current whenever a note title changes.
CREATE TRIGGER trg_notes_title_updated_at
AFTER UPDATE OF title ON notes
FOR EACH ROW
WHEN NEW.title IS NOT OLD.title
BEGIN
    UPDATE notes
    SET updated_at = unixepoch()
    WHERE note_id = NEW.note_id;
END;
