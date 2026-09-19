use std::sync::Mutex;

use crate::db::repositories::people as repository;
use crate::vault::VaultState;

#[tauri::command]
pub fn create_people_note(
    state: tauri::State<'_, Mutex<Option<VaultState>>>,
    title: String,
) -> Result<i64, String> {
    let vault_state = state.lock().map_err(|e| format!("Could not lock state: {}", e))?;
    let vault = vault_state.as_ref().ok_or("No vault is open")?;

    repository::create_people_note(&vault.database, &title)
        .map_err(|e| format!("Could not create people note: {}", e))
}
