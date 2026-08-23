use serde::{Serialize, Deserialize};

#[derive(Debug, Serialize, Deserialize)]
pub enum NoteCategory {
    Journal,
    People,
    Writings,
    Knowledge,
    Files
}

impl NoteCategory {
    pub fn from_index(index: u32) -> Option<Self> {
        match index {
            1 => Some(NoteCategory::Journal),
            2 => Some(NoteCategory::People),
            3 => Some(NoteCategory::Writings),
            4 => Some(NoteCategory::Knowledge),
            5 => Some(NoteCategory::Files),
            _ => None, // Only 5 categories exist
        }
    }

    pub fn get_index(&self) -> u32 {
        match self {
            NoteCategory::Journal => 1,
            NoteCategory::People => 2,
            NoteCategory::Writings => 3,
            NoteCategory::Knowledge => 4,
            NoteCategory::Files => 5,
        }
    }
}

#[derive(Debug, Serialize, Deserialize)]
pub struct Note {
    pub note_id: u32,
    pub title: String,
    pub created_at: String,
    pub updated_at: String,
    pub category: Option<NoteCategory>
}
