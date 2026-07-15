# Pensy: a Privacy-Focused Personal Knowledge Management System

> Note: the app is in a very early development stage. Contributions won't be accepted until the app is usable.

Pensy is a [Tauri](https://tauri.app/) note-taking application centered around managing personal knowledge. The app is divided into 5 main components, each with a distinct purpose.

## Components
| Component | Description                         |
|-----------|-------------------------------------|
| Journal   | Writing daily personal entries.     |
| People    | Writing notes about people.         |
| Writings  | Storing works you authored.         |
| Knowledge | Storing factual notes for future reference. |
| Files     | Storing photos, audio notes, etc... |

## Data Model

App Data Dir (see [here](https://jonaskruckenberg.github.io/tauri-sys/tauri_sys/path/fn.app_data_dir.html) for more etails) -> Keeps track of available vaults. Auto-updates on start-up and whenever a new vault is created/loaded.

Each vault contains:
* vault.db -> encrypted SQLite database
* master-salt.bin -> the master salt used for deriving the master key
* blobs/ -> contains encrypted files stored in the .bin format (images, voice notes, etc...)

## Security Model

* Password + Master Salt -> Master Key (using [Argon2](https://github.com/p-h-c/phc-winner-argon2))
* Master Key -> DB Key (HKDF)
* Master Key + File Salt -> File Key (also HKDF)

Database encryption is handled by [SQLCipher](https://github.com/sqlcipher/sqlcipher).
File encryption is handled using aes-gcm.

Encrypted files cannot be compared (i.e., it cannot be discovered that two encrypted files have the same content) as each file is encrypted with a unique nonce (random bytes) and its key is derived with a unique salt.

## AI Usage

AI is partially used in the development of this project.
