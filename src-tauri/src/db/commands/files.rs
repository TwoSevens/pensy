use std::sync::Mutex;

use crate::db::repositories::files as repository;
use crate::vault::VaultState;

#[tauri::command]
pub fn create_file_note(
    state: tauri::State<'_, Mutex<Option<VaultState>>>,
    title: String,
) -> Result<i64, String> {
    let vault_state = state.lock().map_err(|e| format!("Could not lock state: {}", e))?;
    let vault = vault_state.as_ref().ok_or("No vault is open")?;

    repository::create_file_note(&vault.database, &title)
        .map_err(|e| format!("Could not create file note: {}", e))
}
