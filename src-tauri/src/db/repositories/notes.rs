use crate::db::models::Note;
use rusqlite::{params, Connection, Result};

pub struct NoteRepository<'connection> {
    connection: &'connection Connection,
}

impl<'connection> NoteRepository<'connection> {
    pub fn new(connection: &'connection Connection) -> Self {
        Self { connection }
    }

    pub fn create(&self, title: &str, category: &str) -> Result<i64> {
        self.connection.execute(
            "INSERT INTO notes (title, category) VALUES (?1, ?2)",
            params![title, category],
        )?;
        Ok(self.connection.last_insert_rowid())
    }

    pub fn list_by_category(&self, category: &str) -> Result<Vec<Note>> {
        let mut statement = self.connection.prepare(
            "SELECT note_id, title, created_at, updated_at, category
             FROM notes
             WHERE category = ?1
             ORDER BY updated_at DESC, note_id DESC",
        )?;

        let notes = statement
            .query_map(params![category], |row| {
                Ok(Note {
                    note_id: row.get(0)?,
                    title: row.get(1)?,
                    created_at: row.get(2)?,
                    updated_at: row.get(3)?,
                    category: row.get(4)?,
                })
            })?
            .collect();
        notes
    }

    pub fn update_title(&self, note_id: i64, title: &str) -> Result<bool> {
        let changed = self.connection.execute(
            "UPDATE notes SET title = ?1, updated_at = unixepoch() WHERE note_id = ?2",
            params![title, note_id],
        )?;
        Ok(changed == 1)
    }
}
