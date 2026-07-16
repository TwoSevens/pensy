use crate::db;
use crate::security::{derive_master_key, derive_db_key, generate_salt};
use rusqlite::Connection;
use std::path::PathBuf;
use std::fs::File;
use std::io::Write;

pub struct VaultState {
    master_key: [u8; 32],
    pub database: Connection,
    pub path: PathBuf,
}

impl VaultState {
    pub fn new(path: PathBuf, passphrase: &str) -> Result<VaultState, String> {
        std::fs::create_dir_all(&path)
            .map_err(|e| format!("Failed to create vault directory: {}", e))?;
            
        let master_salt = generate_salt();
        let master_key = derive_master_key(passphrase.as_ref(), &master_salt)
            .map_err(|e| format!("Failed to generate master key: {}", e))?;

        File::create(path.join("master_salt.bin"))
            .map_err(|e| format!("Failed to create master salt file: {}", e))?
            .write_all(&master_salt)
            .map_err(|e| format!("Failed to write master salt file: {}", e))?;

        let db_key = derive_db_key(&master_key)
            .map_err(|e| format!("Failed to derive database key: {}", e))?;

        let database = db::initialize(path.join("vault.db"), db_key)
            .map_err(|e| format!("Failed to initialize database: {}", e))?;

        Ok(VaultState {
            master_key,
            database,
            path,
        })
    }

    pub fn load(path: PathBuf, passphrase: &str) -> Result<VaultState, String> {
        let master_salt = std::fs::read(path.join("master_salt.bin"))
            .map_err(|e| format!("Failed to read master salt file: {}", e))?;
        if master_salt.len() != 16 {
            return Err("Invalid master salt length".into());
        }

        let master_key = derive_master_key(passphrase.as_ref(), &master_salt)
            .map_err(|e| format!("Failed to derive master key: {}", e))?;

        let db_key = derive_db_key(&master_key)
            .map_err(|e| format!("Failed to derive database key: {}", e))?;

        let database = db::initialize(path.join("vault.db"), db_key)
            .map_err(|e| format!("Failed to initialize database: {}", e))?;

        Ok(VaultState {
            master_key,
            database,
            path,
        })
    }

    // TODO:
    // pub fn store_blob(&self, attachment: &[u8], filename: &str, salt: &[u8], key: &[u8]) -> Result<(), String> {}
    // pub fn get_blob(&self, filename: &str, salt: &[u8], key: &[u8]) -> Result<Vec<u8>, String> {}
    // pub fn delete_blob(&self, filename: &str) -> Result<(), String> {}
}