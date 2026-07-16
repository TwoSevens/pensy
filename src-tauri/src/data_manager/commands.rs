use std::path::PathBuf;
use std::sync::Mutex;
use tauri::Manager;
use crate::vault::VaultState;
use crate::data_manager::{add_vault, vault_exists};

#[tauri::command]
pub fn open_vault(
    state: tauri::State<'_, Mutex<Option<VaultState>>>,
    app_handle: tauri::AppHandle,
    path: String,
    passphrase: String,
) -> Result<(), String> {
    let path = PathBuf::from(path);
    let vault = if vault_exists(&path) {
        VaultState::load(path, &passphrase)
            .map_err(|e| format!("Could not open vault: {}", e))?
    } else {
        VaultState::new(path, &passphrase)
            .map_err(|e| format!("Could not create vault: {}", e))?
    };

    add_vault(app_handle, vault.path.to_string_lossy().to_string())
        .unwrap_or_else(|e| eprintln!("Could not add vault to list: {}", e));

    let mut vault_state = state.lock().map_err(|e| format!("Could not lock state: {}", e))?;
    *vault_state = Some(vault);

    Ok(())
}

#[tauri::command]
pub fn list_vaults(app_handle: tauri::AppHandle) -> Result<Vec<String>, String> {
    let vaults_dir = app_handle.path().app_data_dir()
        .map_err(|e| format!("Could not get app data directory: {}", e))?;
    let vault_list = vaults_dir.join("vault_list.txt");

    let vaults = std::fs::read_to_string(&vault_list)
        .map_err(|e| format!("Could not read vault list: {}", e))?
        .lines()
        .map(String::from)
        .collect();

    Ok(vaults)
}

#[tauri::command]
pub fn get_current_vault_path(state: tauri::State<'_, Mutex<Option<VaultState>>>) -> Result<Option<String>, String> {
    let vault_state = state.lock().map_err(|e| format!("Could not lock state: {}", e))?;
    Ok(vault_state.as_ref().map(|vault| vault.path.to_string_lossy().to_string()))
}

#[tauri::command]
pub fn is_vault_loaded(state: tauri::State<'_, Mutex<Option<VaultState>>>) -> Result<bool, String> {
    let vault_state = state.lock().map_err(|e| format!("Could not lock state: {}", e))?;
    Ok(vault_state.is_some())
}