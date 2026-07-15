use crate::vault::VaultState;
use std::path::PathBuf;
use std::sync::Mutex;
use tauri::Manager;

pub fn vault_exists(path: &PathBuf) -> bool {
    path.join("master_salt.bin").exists() && path.join("vault.db").exists()
}

pub fn initialize_app_data_dir(app_handle: &tauri::AppHandle) -> Result<(), String> {
    let vaults_dir = app_handle.path().app_data_dir()
        .map_err(|e| format!("Could not get app data directory: {}", e))?;
    std::fs::create_dir_all(&vaults_dir).map_err(|e| format!("Could not create app data directory: {}", e))?;

    let vault_list = vaults_dir.join("vault_list.txt");
    if !vault_list.exists() {
        std::fs::File::create(&vault_list).map_err(|e| format!("Could not create vault list file: {}", e))?;
        return Ok(());
    }

    let vaults: Vec<String> = std::fs::read_to_string(&vault_list)
        .map_err(|e| format!("Could not read vault list: {}", e))?
        .lines()
        .filter(|l| !l.is_empty())
        .map(String::from)
        .collect();

    let valid: Vec<String> = vaults.into_iter()
        .filter(|v| vault_exists(&PathBuf::from(v)))
        .collect();

    std::fs::write(&vault_list, valid.join("\n"))
        .map_err(|e| format!("Could not write vault list: {}", e))?;

    Ok(())
}

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

// This function adds a new vault to the path. If it already exists, it will be removed and appended to the top of the list.
// It is not a command as it is automatically called when a vault is opened or created. It is not exposed to the frontend as it is not needed there.
pub fn add_vault(app_handle: tauri::AppHandle, vault_path: String) -> Result<(), String> {
    let vaults_dir = app_handle.path().app_data_dir()
        .map_err(|e| format!("Could not get app data directory: {}", e))?;
    let vault_list = vaults_dir.join("vault_list.txt");

    let mut vaults = std::fs::read_to_string(&vault_list)
        .map_err(|e| format!("Could not read vault list: {}", e))?
        .lines()
        .map(String::from)
        .collect::<Vec<String>>();

    // Remove the vault if it already exists in the list
    vaults.retain(|v| v != &vault_path);

    // Append the new vault to the top of the list
    vaults.insert(0, vault_path);
    std::fs::write(&vault_list, vaults.join("\n"))
        .map_err(|e| format!("Could not write vault list: {}", e))?;
    Ok(())
}