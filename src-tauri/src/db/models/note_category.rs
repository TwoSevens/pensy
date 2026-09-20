use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
pub struct NoteCategory {
    pub category: String,
}

impl NoteCategory {
    pub fn new(category: impl Into<String>) -> Self {
        Self {
            category: category.into(),
        }
    }
}
