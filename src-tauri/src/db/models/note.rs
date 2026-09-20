use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
pub struct Note {
    pub note_id: i64,
    pub title: String,
    pub created_at: i64,
    pub updated_at: i64,
    pub category: String,
}
