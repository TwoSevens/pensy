use rusqlite::{Connection, Result};
use std::path::PathBuf;
use hex;

const SCHEMA: &'static str = include_str!("./schema.sql");

// Migrations go here. 
// The SCHEMA is treated as a migration since db initialization always checks and runs migrations.
const MIGRATIONS: &'static [&'static str] = &[SCHEMA];

fn get_version(conn: &Connection) -> Result<u32> {
    conn.query_row("PRAGMA user_version", [], |row| row.get(0))
}

fn set_version(conn: &Connection, version: u32) -> Result<()> {
    conn.execute_batch(&format!("PRAGMA user_version = {version}"))
}

// Create or open a database
// The vault handles where the database is stored.
pub fn initialize(db_path: PathBuf, db_key: [u8; 32]) -> Result<Connection> {
    let conn = Connection::open(db_path)?;
    
    // The passphrase must be set as soon as the database is open.
    conn.execute_batch(&format!("
        PRAGMA key=\"x'{}'\";;
        PRAGMA journal_mode=WAL;
        PRAGMA foreign_keys=ON;
        PRAGMA synchronous=NORMAL;
    ", hex::encode(db_key)))?;

    run_migrations(&conn)?;
    Ok(conn)
}

// This runs a migration if its index is equal to the db version.
// user_version starts at 0, so the schema runs when a new db is created.
fn run_migrations(conn: &Connection) -> Result<()> {
    for (i, migration) in MIGRATIONS.iter().enumerate() {
        if i as u32 >= get_version(&conn)? {
            conn.execute_batch(&migration)?;
            set_version(&conn, (i+1).try_into().unwrap())?;
        }
    }

    Ok(())
}