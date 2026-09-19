use rusqlite::{Connection, Result};

pub fn create_people_note(conn: &Connection, title: &str) -> Result<i64> {
    conn.execute(
        "INSERT INTO people_note_entry (title) VALUES (?1)",
        [title],
    )?;

    conn.query_row(
        "SELECT note_id FROM notes WHERE category_id = 2 ORDER BY note_id DESC LIMIT 1",
        [],
        |row| row.get(0),
    )
}
