use crate::db::repositories::{NoteCategoryRepository, NoteRepository};
use crate::vault::VaultState;
use rusqlite::Error as SqlError;
use std::sync::Mutex;

fn connection<'state>(
    state: &'state tauri::State<'_, Mutex<Option<VaultState>>>,
) -> Result<std::sync::MutexGuard<'state, Option<VaultState>>, String> {
    state
        .lock()
        .map_err(|error| format!("Could not lock vault state: {error}"))
}

fn ensure_category(category: &str, vault: &VaultState) -> Result<(), String> {
    NoteCategoryRepository::new(&vault.database)
        .find(category)
        .map_err(|error| format!("Could not validate note category: {error}"))?
        .ok_or_else(|| format!("Unknown note category: {category}"))?;
    Ok(())
}

fn database_error(error: SqlError) -> String {
    error.to_string()
}

#[tauri::command]
pub fn create_note(
    state: tauri::State<'_, Mutex<Option<VaultState>>>,
    title: String,
    category: String,
) -> Result<i64, String> {
    let title = title.trim();
    if title.is_empty() {
        return Err("Note title cannot be empty".into());
    }

    let vault_state = connection(&state)?;
    let vault = vault_state
        .as_ref()
        .ok_or_else(|| "No vault is open".to_string())?;
    ensure_category(&category, vault)?;
    NoteRepository::new(&vault.database)
        .create(title, &category)
        .map_err(database_error)
}

#[tauri::command]
pub fn get_notes(
    state: tauri::State<'_, Mutex<Option<VaultState>>>,
    category: String,
) -> Result<Vec<crate::db::models::Note>, String> {
    let vault_state = connection(&state)?;
    let vault = vault_state
        .as_ref()
        .ok_or_else(|| "No vault is open".to_string())?;
    ensure_category(&category, vault)?;
    NoteRepository::new(&vault.database)
        .list_by_category(&category)
        .map_err(database_error)
}

#[tauri::command]
pub fn update_note_title(
    state: tauri::State<'_, Mutex<Option<VaultState>>>,
    note_id: i64,
    title: String,
) -> Result<(), String> {
    let title = title.trim();
    if title.is_empty() {
        return Err("Note title cannot be empty".into());
    }

    let vault_state = connection(&state)?;
    let vault = vault_state
        .as_ref()
        .ok_or_else(|| "No vault is open".to_string())?;
    let updated = NoteRepository::new(&vault.database)
        .update_title(note_id, title)
        .map_err(database_error)?;
    if updated {
        Ok(())
    } else {
        Err(format!("Note {note_id} was not found"))
    }
}

#[tauri::command]
pub fn get_journal_content(
    state: tauri::State<'_, Mutex<Option<VaultState>>>,
    note_id: i64,
) -> Result<String, String> {
    let vault_state = connection(&state)?;
    let vault = vault_state
        .as_ref()
        .ok_or_else(|| "No vault is open".to_string())?;
    NoteRepository::new(&vault.database)
        .get_journal_content(note_id)
        .map_err(database_error)?
        .map(|journal| journal.content)
        .ok_or_else(|| format!("Journal note {note_id} was not found"))
}

#[tauri::command]
pub fn update_journal_content(
    state: tauri::State<'_, Mutex<Option<VaultState>>>,
    note_id: i64,
    content: String,
) -> Result<(), String> {
    let vault_state = connection(&state)?;
    let vault = vault_state
        .as_ref()
        .ok_or_else(|| "No vault is open".to_string())?;
    let updated = NoteRepository::new(&vault.database)
        .update_journal_content(note_id, &content)
        .map_err(database_error)?;
    if updated {
        Ok(())
    } else {
        Err(format!("Journal note {note_id} was not found"))
    }
}
