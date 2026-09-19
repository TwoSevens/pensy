use rusqlite::{Connection, Result};

pub fn create_writings_note(conn: &Connection, title: &str) -> Result<i64> {
    conn.execute(
        "INSERT INTO writings_note_entry (title) VALUES (?1)",
        [title],
    )?;

    conn.query_row(
        "SELECT note_id FROM notes WHERE category_id = 3 ORDER BY note_id DESC LIMIT 1",
        [],
        |row| row.get(0),
    )
}
