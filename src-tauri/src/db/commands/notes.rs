use std::sync::Mutex;
use crate::db::models::notes::{Note, NoteCategory};
use crate::db::repositories::notes as repository;
use crate::vault::VaultState;

#[tauri::command]
pub fn get_notes(
    state: tauri::State<'_, Mutex<Option<VaultState>>>,
    category: Option<NoteCategory>,
) -> Result<Vec<Note>, String> {
    let vault_state = state.lock().map_err(|e| format!("Could not lock state: {}", e))?;
    let vault = vault_state.as_ref().ok_or("No vault is open")?;

    repository::get_notes(&vault.database, category)
        .map_err(|e| format!("Could not get notes: {}", e))
}

#[tauri::command]
pub fn create_note(
    state: tauri::State<'_, Mutex<Option<VaultState>>>,
    title: String,
    category: NoteCategory,
) -> Result<i64, String> {
    let vault_state = state.lock().map_err(|e| format!("Could not lock state: {}", e))?;
    let vault = vault_state.as_ref().ok_or("No vault is open")?;

    repository::create_note(&vault.database, &title, category)
        .map_err(|e| format!("Could not create note: {}", e))
}

#[tauri::command]
pub fn update_note_title(
    state: tauri::State<'_, Mutex<Option<VaultState>>>,
    note_id: u32,
    title: String,
) -> Result<(), String> {
    let vault_state = state.lock().map_err(|e| format!("Could not lock state: {}", e))?;
    let vault = vault_state.as_ref().ok_or("No vault is open")?;

    repository::update_note_title(&vault.database, note_id, &title)
        .map_err(|e| format!("Could not update note title: {}", e))
}
