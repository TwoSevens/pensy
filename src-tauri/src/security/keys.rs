use rand_os::{rand_core::RngCore, OsRng};
use argon2::Argon2;
use sha2::Sha256;
use hkdf::Hkdf;

/// Derives a 32-byte master key from the user's password and master salt using Argon2id.
pub fn derive_master_key(password: &[u8], master_salt: &[u8]) -> Result<[u8; 32], String> {
    let mut master_key = [0u8; 32];
    Argon2::default().hash_password_into(password, master_salt, &mut master_key)
        .map_err(|e| format!("Error deriving master key: {}", e))?;
    Ok(master_key)
}

/// Derives a 32-byte file-specific key from the master key and a per-file salt using HKDF.
pub fn derive_file_key(master_key: &[u8; 32], file_salt: &[u8]) -> Result<[u8; 32], String> {
    let mut file_key = [0u8; 32];
    Hkdf::<Sha256>::new(Some(file_salt), master_key.as_ref())
        .expand(b"file-key-v1", &mut file_key)
        .map_err(|e| format!("Error deriving file key: {}", e))?;
    Ok(file_key)
}

/// Derives a 32-byte database key from the master key using HKDF.
/// Pass the result directly into db::initialize().
pub fn derive_db_key(master_key: &[u8; 32]) -> Result<[u8; 32], String> {
    let mut db_key = [0u8; 32];
    Hkdf::<Sha256>::new(None, master_key.as_ref())
        .expand(b"db-key-v1", &mut db_key)
        .map_err(|e| format!("Error deriving database key: {}", e))?;
    Ok(db_key)
}

/// Generates 16 cryptographically random bytes to use as a salt.
pub fn generate_salt() -> [u8; 16] {
    let mut salt = [0u8; 16];
    OsRng.fill_bytes(&mut salt);
    salt
}

/// Generates 12 cryptographically random bytes to use as a nonce.
pub fn generate_nonce() -> [u8; 12] {
    let mut nonce = [0u8; 12];
    OsRng.fill_bytes(&mut nonce);
    nonce
}