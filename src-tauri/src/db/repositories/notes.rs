use rusqlite::{Connection, Result};
use crate::db::models::notes::{Note, NoteCategory};

pub fn get_notes(conn: &Connection, category: Option<NoteCategory>) -> Result<Vec<Note>> {
    let mut stmt = conn.prepare(
        "SELECT note_id, title, created_at, updated_at, category_id
         FROM notes
         WHERE ?1 IS NULL OR category_id = ?1",
    )?;

    let notes = stmt.query_map([category.map(|c| c.get_index() as i64)], |row| {
        Ok(Note {
            note_id: row.get(0)?,
            title: row.get(1)?,
            created_at: row.get(2)?,
            updated_at: row.get(3)?,
            category: row.get::<_, Option<u32>>(4)?.and_then(NoteCategory::from_index),
        })
    })?;

    notes.collect()
}

pub fn create_note(conn: &Connection, title: &str, category: NoteCategory) -> Result<i64> {
    conn.execute(
        "INSERT INTO notes (title, category_id) VALUES (?1, ?2)",
        (title, category.get_index() as i64),
    )?;

    Ok(conn.last_insert_rowid())
}
