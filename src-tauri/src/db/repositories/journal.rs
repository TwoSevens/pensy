use rusqlite::{Connection, Result};

pub fn create_journal_note(conn: &Connection, title: &str) -> Result<i64> {
    conn.execute(
        "INSERT INTO journal_note_entry (title) VALUES (?1)",
        [title],
    )?;

    conn.query_row(
        "SELECT note_id FROM notes WHERE category_id = 1 ORDER BY note_id DESC LIMIT 1",
        [],
        |row| row.get(0),
    )
}
