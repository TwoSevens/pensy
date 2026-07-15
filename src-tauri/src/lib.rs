mod db;
mod vault;
mod data_manager;
mod security;

use data_manager::initialize_app_data_dir;

use std::sync::Mutex;

#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    tauri::Builder::default()
        .setup(|app| {
            setup(app);
            Ok(())
        })
        .plugin(tauri_plugin_opener::init())
        .manage(Mutex::new(None::<vault::VaultState>))
        .invoke_handler(tauri::generate_handler![
            data_manager::open_vault,
            data_manager::list_vaults,
            data_manager::get_current_vault_path,
            data_manager::is_vault_loaded,
        ])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}

fn setup(app: &tauri::App) {
    if let Err(e) = initialize_app_data_dir(app.handle()) {
        eprintln!("Failed to initialize app data directory: {}", e);
    }
}