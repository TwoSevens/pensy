# Pensy: a Privacy-Focused Personal Knowledge Management System

> Note: the app is in a very early development stage. Contributions won't be accepted until the app is usable.

Pensy is a Tauri note-taking application centered around managing personal knowledge. The app is divided into 5 main components, each with a distinct purpose.

## Components
| Component | Description                         |
|-----------|-------------------------------------|
| Journal   | Writing daily personal entries.     |
| People    | Writing notes about people.         |
| Writings  | Storing works you authored.         |
| Knowledge | Storing factual notes for future reference. |
| Files     | Storing photos, audio notes, etc... |

## Privacy

The app uses a SQLite database and stores all uploaded files in its vault (not as blobs in the database).

The database is encrypted using SQLCipher. Files are encrypted individually using the same password used for the database. File names are only stored in the database to ensure user privacy (they are stored with arbitrary names in the vault).
