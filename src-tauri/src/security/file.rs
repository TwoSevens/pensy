use aes_gcm::{Aes256Gcm, Key, Nonce, aead::{Aead, KeyInit}};
use crate::security::keys::generate_nonce;

// Magic bytes written at the start of every .bin file to identify it as a vault file.
const MAGIC: &[u8; 4] = b"PNSY";
const VERSION: u8 = 0x01;

// Header layout: MAGIC (4) + VERSION (1) + NONCE (12) = 17 bytes
const HEADER_LEN: usize = 17;

struct Header {
    version: u8,
    nonce: [u8; 12],
}

/// Encrypts raw bytes with the given file key and returns a complete .bin blob
/// (magic + version + nonce + ciphertext + auth tag).
pub fn encrypt_file(file_key: &[u8; 32], plaintext: &[u8]) -> Result<Vec<u8>, String> {
    let cipher = Aes256Gcm::new(Key::<Aes256Gcm>::from_slice(file_key));
    let nonce_bytes = generate_nonce();
    let nonce = Nonce::from_slice(&nonce_bytes);

    // aes-gcm appends the 16-byte auth tag to the ciphertext automatically.
    let ciphertext = cipher.encrypt(nonce, plaintext).map_err(|e| format!("Encryption failed: {}", e))?;

    let mut blob = Vec::with_capacity(HEADER_LEN + ciphertext.len());
    blob.extend_from_slice(MAGIC);
    blob.push(VERSION);
    blob.extend_from_slice(&nonce_bytes);
    blob.extend_from_slice(&ciphertext);
    Ok(blob)
}

/// Decrypts a .bin blob with the given file key, verifying the auth tag,
/// and returns the original plaintext bytes.
pub fn decrypt_file(file_key: &[u8; 32], bin_bytes: &[u8]) -> Result<Vec<u8>, String> {
    let header = parse_header(bin_bytes).map_err(|e| format!("Invalid vault file header: {}", e))?;
    let cipher = Aes256Gcm::new(Key::<Aes256Gcm>::from_slice(file_key));
    let nonce = Nonce::from_slice(&header.nonce);

    // Everything after the header is ciphertext + auth tag.
    let ciphertext = &bin_bytes[HEADER_LEN..];

    // decrypt verifies the auth tag first — returns Err if the file was tampered with.
    cipher.decrypt(nonce, ciphertext).map_err(|e| format!("Decryption failed: {}", e))
}

/// Parses the magic bytes, version, and nonce out of a .bin blob header.
fn parse_header(bin_bytes: &[u8]) -> Result<Header, String> {
    if bin_bytes.len() < HEADER_LEN {
        return Err("File is too short to be a valid vault file".into());
    }
    if &bin_bytes[0..4] != MAGIC {
        return Err("Invalid magic bytes: not a vault file".into());
    }

    let version = bin_bytes[4];
    if version != VERSION {
        return Err(format!("Unsupported file version: {} (expected {})", version, VERSION).into());
    }
    let nonce = bin_bytes[5..17].try_into().map_err(|_| "Nonce slice has wrong length")?;

    Ok(Header { version, nonce })
}