-- Base Notes

CREATE TABLE note_categories (
    category TEXT PRIMARY KEY  
) WITHOUT ROWID;

INSERT INTO note_categories (category) VALUES
    ('journal'),
    ('people'),
    ('writings'),
    ('knowledge'),
    ('files');

CREATE TABLE notes (
    note_id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT DEFAULT (CURRENT_DATE),
    created_at INTEGER DEFAULT (unixepoch()),
    updated_at INTEGER DEFAULT (unixepoch()), -- Must be updated after every change
    category TEXT NOT NULL,
    FOREIGN KEY (category) REFERENCES note_categories(category)
);

-- One journal note per day
CREATE TRIGGER trg_notes_unique_journal_date
BEFORE INSERT ON notes
FOR EACH ROW
WHEN NEW.category = 'journal'
BEGIN
    SELECT RAISE(ABORT, 'A journal note already exists for this date')
    WHERE EXISTS (
        SELECT 1
        FROM notes
        WHERE category = 'journal'
          AND date(created_at, 'unixepoch') = date(NEW.created_at, 'unixepoch')
    );
END;

-- No future notes
CREATE TRIGGER trg_notes_no_future_timestamp
BEFORE INSERT ON notes
FOR EACH ROW
WHEN NEW.created_at > unixepoch()
BEGIN
    SELECT RAISE(ABORT, 'Cannot create a note with a future timestamp');
END;