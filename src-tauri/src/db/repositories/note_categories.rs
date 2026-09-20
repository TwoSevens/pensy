use crate::db::models::NoteCategory;
use rusqlite::{params, Connection, Result};

pub struct NoteCategoryRepository<'connection> {
    connection: &'connection Connection,
}

impl<'connection> NoteCategoryRepository<'connection> {
    pub fn new(connection: &'connection Connection) -> Self {
        Self { connection }
    }

    pub fn find(&self, category: &str) -> Result<Option<NoteCategory>> {
        let mut statement = self
            .connection
            .prepare("SELECT category FROM note_categories WHERE category = ?1")?;

        let mut rows = statement.query(params![category])?;
        rows.next()?
            .map(|row| row.get::<_, String>(0).map(NoteCategory::new))
            .transpose()
    }

    pub fn list(&self) -> Result<Vec<NoteCategory>> {
        let mut statement = self
            .connection
            .prepare("SELECT category FROM note_categories ORDER BY category")?;

        let categories = statement
            .query_map([], |row| Ok(NoteCategory::new(row.get::<_, String>(0)?)))?
            .collect();
        categories
    }
}
