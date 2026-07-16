-- ==================================================
-- Vault
-- ==================================================

CREATE TABLE vault_metadata (
    key TEXT PRIMARY KEY,
    value BLOB NOT NULL
);

-- For convenience, user settings will have to be defined outside the database.
-- This makes creating them more flexible.
CREATE TABLE user_settings (
    key TEXT PRIMARY KEY,
    value TEXT NOT NULL
);

-- ==================================================
-- Notes
-- ==================================================

CREATE TABLE note_category (
    category_id INTEGER PRIMARY KEY AUTOINCREMENT,
    category TEXT
);

INSERT INTO note_category (category)
VALUES
    ('journal'),
    ('people'),
    ('writings'),
    ('knowledge'),
    ('files');

CREATE TABLE tags (
    tag_id INTEGER PRIMARY KEY AUTOINCREMENT,
    label TEXT UNIQUE
);

CREATE TABLE notes (
    note_id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    created_at TEXT
        DEFAULT (DATETIME('now')),
    updated_at TEXT
        DEFAULT (DATETIME('now')),
    category_id INTEGER,
    FOREIGN KEY (category_id)
        REFERENCES note_category(category_id)
);

CREATE TABLE notes_tags (
    note_id INTEGER,
    tag_id INTEGER,
    PRIMARY KEY (note_id, tag_id),
    FOREIGN KEY (note_id)
        REFERENCES notes(note_id)
        ON DELETE CASCADE,
    FOREIGN KEY (tag_id)
        REFERENCES tags(tag_id)
        ON DELETE CASCADE
);

-- ==================================================
-- Journal Notes
-- ==================================================

CREATE TABLE journal_notes (
    note_id INTEGER PRIMARY KEY,
    calendar_day TEXT
        DEFAULT (DATE('now'))
        UNIQUE,
    mood_rating INTEGER
        CHECK (mood_rating BETWEEN 0 and 10)
        DEFAULT 5,
    FOREIGN KEY (note_id)
        REFERENCES notes(note_id)
        ON DELETE CASCADE
);

CREATE TABLE journal_content (
    note_id INTEGER,
    start_time TEXT
        DEFAULT (TIME('now')),
    end_time TEXT
        DEFAULT (TIME('now')),
    content TEXT,
    FOREIGN KEY (note_id)
        REFERENCES notes(note_id)
        ON DELETE CASCADE
);

-- ==================================================
-- People Notes
-- ==================================================

CREATE TABLE people_nicknames (
    note_id INTEGER,
    nickname TEXT,
    FOREIGN KEY (note_id)
        REFERENCES notes(note_id)
        ON DELETE CASCADE
);

CREATE TABLE people_contact_info (
    note_id INTEGER,
    medium TEXT,
    identifier TEXT,
    FOREIGN KEY (note_id)
        REFERENCES notes(note_id)
        ON DELETE CASCADE
);

CREATE TABLE people_physical_traits (
    note_id INTEGER,
    physical_trait TEXT,
    FOREIGN KEY (note_id)
        REFERENCES notes(note_id)
        ON DELETE CASCADE
);

CREATE TABLE people_behavioral_traits (
    note_id INTEGER,
    behavioral_trait TEXT,
    FOREIGN KEY (note_id)
        REFERENCES notes(note_id)
        ON DELETE CASCADE
);

CREATE TABLE people_impression_over_time (
    note_id INTEGER,
    log_date TEXT
        DEFAULT (DATETIME('now')),
    impression_rating INTEGER
        CHECK (impression_rating BETWEEN 0 and 10),
    FOREIGN KEY (note_id)
        REFERENCES notes(note_id)
        ON DELETE CASCADE
);

-- Will need to insert starter relations later on
CREATE TABLE relation_types (
    relation TEXT, -- e.g. father
    counterpart TEXT -- e.g. son
);

CREATE TABLE people_notes (
    note_id INTEGER PRIMARY KEY,
    photo_note_id INTEGER DEFAULT NULL,
    relation_to_me TEXT DEFAULT NULL,
    date_of_birth TEXT DEFAULT NULL,
    residence_place TEXT DEFAULT NULL,
    first_met TEXT DEFAULT NULL, -- meeting date
    met_place TEXT DEFAULT NULL,
    FOREIGN KEY (note_id)
        REFERENCES notes(note_id)
        ON DELETE CASCADE,
    FOREIGN KEY (photo_note_id)
        REFERENCES notes(note_id)
);

CREATE TABLE people_relations (
    note_id_a INTEGER,
    note_id_b INTEGER,
    relation TEXT,
    intimacy_rating INTEGER
        CHECK (intimacy_rating BETWEEN 0 and 10)
);

-- ==================================================
-- Writings Notes
-- ==================================================

CREATE TABLE drafts (
    draft_id INTEGER PRIMARY KEY,  -- explicit, so parts can reference it
    note_id  INTEGER,
    FOREIGN KEY (note_id)
        REFERENCES notes(note_id)
        ON DELETE CASCADE
);

CREATE TABLE parts (
    draft_id INTEGER,
    content  TEXT,
    FOREIGN KEY (draft_id)
        REFERENCES drafts(draft_id)
        ON DELETE CASCADE
);

CREATE TABLE writing_category (
    category_id INTEGER PRIMARY KEY AUTOINCREMENT,
    label TEXT
);

INSERT INTO writing_category (label)
VALUES
    -- Fiction
    ("Story"),
    ("Short Story"),
    ("Flash Fiction"),
    ("Novel Chapter"),
    ("Fan Fiction"),
    ("Fable"),
    ("Fairy Tale"),
    ("Myth"),
    ("Myth Retelling"),
    ("Legend"),
    ("Parable"),

    -- Poetry
    ("Poem"),
    ("Haiku"),
    ("Sonnet"),
    ("Ode"),
    ("Elegy"),
    ("Limerick"),
    ("Prose Poetry"),
    ("Lyrics"),

    -- Personal writing
    ("Reflection"),
    ("Memoir"),
    ("Autobiography"),
    ("Personal Narrative"),
    ("Anecdote"),
    ("Travelogue"),
    ("Prayer"),
    ("Meditation"),

    -- Essays & criticism
    ("Essay"),
    ("Opinion Piece"),
    ("Editorial"),
    ("Review"),
    ("Critique"),
    ("Satire"),
    ("Parody"),

    -- Academic & research
    ("Research Paper"),
    ("Academic Paper"),
    ("Case Study"),
    ("Report"),
    ("Thought Experiment"),
    ("Philosophical Treatise"),

    -- Biography & life writing
    ("Biography"),

    -- Correspondence
    ("Letter"),
    ("Open Letter"),
    ("Cover Letter"),

    -- Performative & dramatic
    ("Speech"),
    ("Monologue"),
    ("Dialogue"),
    ("Script"),
    ("Screenplay"),
    ("Play"),

    -- Public & professional
    ("Blog Post"),
    ("Newsletter"),
    ("Press Release"),
    ("Manifesto"),
    ("Listicle"),
    ("How-To Guide"),
    ("Recipe"),

    -- Aphoristic & visionary
    ("Aphorism"),
    ("Epigram"),
    ("Prophecy");

CREATE TABLE writing_status (
    status_id INTEGER PRIMARY KEY AUTOINCREMENT,
    label TEXT
);

INSERT INTO writing_status (label)
VALUES
    ("Planning"),
    ("In Progress"),
    ("Completed"),
    ("Dropped"),
    ("Postponed");

CREATE TABLE writings_notes (
    note_id INTEGER PRIMARY KEY,
    category_id INTEGER DEFAULT NULL,
    status_id INTEGER DEFAULT NULL,
    FOREIGN KEY (category_id)
        REFERENCES writing_category(category_id),
    FOREIGN KEY (status_id)
        REFERENCES writing_status(status_id),
    FOREIGN KEY (note_id)
        REFERENCES notes(note_id)
        ON DELETE CASCADE
);

-- ==================================================
-- Knowledge Notes
-- ==================================================

CREATE TABLE knowledge_status (
    status_id INTEGER PRIMARY KEY AUTOINCREMENT,
    label TEXT
);

INSERT INTO knowledge_status (label)
VALUES
    ("Want to Know"),
    ("Researching"),
    ("Learning"),
    ("Completed"),
    ("Confused"),
    ("Postponed"),
    ("Dropped");

CREATE TABLE knowledge_subject (
    subject_id INTEGER PRIMARY KEY AUTOINCREMENT,
    label TEXT
);

INSERT INTO knowledge_subject (label)
VALUES
    -- General / meta
    ("General"),
    ("Personal"),
    ("Multiple"),

    -- Formal sciences
    ("Mathematics"),
    ("Logic"),
    ("Statistics"),
    ("Information Theory"),

    -- Natural sciences
    ("Physics"),
    ("Chemistry"),
    ("Biology"),
    ("Ecology"),
    ("Astronomy"),
    ("Earth Sciences"),
    ("Neuroscience"),

    -- Life & health sciences
    ("Medicine"),
    ("Nutrition"),
    ("Psychology"),
    ("Cognitive Science"),

    -- Social sciences
    ("Sociology"),
    ("Anthropology"),
    ("Economics"),
    ("Political Science"),
    ("Law"),
    ("Linguistics"),

    -- Humanities
    ("History"),
    ("Philosophy"),
    ("Ethics"),
    ("Religion"),
    ("Literature"),
    ("Art"),
    ("Music"),

    -- Applied sciences & engineering
    ("Computer Science"),
    ("Software Engineering"),
    ("Electrical Engineering"),
    ("Mechanical Engineering"),
    ("Civil Engineering"),
    ("Biotechnology"),
    ("Data Science"),
    ("Artificial Intelligence"),
    ("Cybersecurity"),
    ("Networking"),
    ("Systems Design"),

    -- Business & management
    ("Business"),
    ("Finance"),
    ("Management"),
    ("Marketing"),
    ("Entrepreneurship"),
    ("Project Management"),

    -- Education & learning
    ("Education"),
    ("Learning & Pedagogy"),

    -- Environment & sustainability
    ("Environment"),
    ("Sustainability"),
    ("Climate"),

    -- Technology & society
    ("Technology"),
    ("Media & Communication"),
    ("Science & Society"),

    -- Practical / craft knowledge
    ("Design"),
    ("Architecture"),
    ("Cooking"),
    ("Engineering Practice"),
    ("Crafts & Making");

CREATE TABLE knowledge_notes (
    note_id INTEGER PRIMARY KEY,
    status_id INTEGER DEFAULT NULL,
    subject_id INTEGER DEFAULT NULL,
    content TEXT DEFAULT NULL,
    FOREIGN KEY (status_id)
        REFERENCES knowledge_status(status_id),
    FOREIGN KEY (subject_id)
        REFERENCES knowledge_subject(subject_id),
    FOREIGN KEY (note_id)
        REFERENCES notes(note_id)
        ON DELETE CASCADE
);

-- ==================================================
-- Files Notes
-- ==================================================

CREATE TABLE file_notes (
    note_id INTEGER PRIMARY KEY,
    encrypted_filename TEXT DEFAULT NULL,
    mime_type TEXT DEFAULT NULL,
    size_bytes INTEGER DEFAULT (0),
    file_salt BLOB DEFAULT NULL,
    FOREIGN KEY (note_id)
        REFERENCES notes(note_id)
        ON DELETE CASCADE
);

-- ==================================================
-- Virtual Tables + Their Triggers
-- ==================================================

CREATE VIRTUAL TABLE title_search USING fts5 (
    note_id UNINDEXED,
    title
);

CREATE VIRTUAL TABLE content_search USING fts5 (
    note_id UNINDEXED,
    note_content
);

-- <-- FTS Triggers: Core Notes & Title -->

CREATE TRIGGER fts_notes_after_insert
AFTER INSERT ON notes
BEGIN
    -- Insert into title_search
    INSERT INTO title_search (note_id, title)
    VALUES (NEW.note_id, NEW.title);

    -- Insert title into content_search
    INSERT INTO content_search (note_id, note_content)
    VALUES (NEW.note_id, NEW.title);
END;

CREATE TRIGGER fts_notes_after_update
AFTER UPDATE OF title ON notes
BEGIN
    -- Update title_search
    UPDATE title_search
    SET title = NEW.title
    WHERE note_id = NEW.note_id;

    -- Update content_search (swap old title for new one)
    DELETE FROM content_search
    WHERE note_id = OLD.note_id AND note_content = OLD.title;

    INSERT INTO content_search (note_id, note_content)
    VALUES (NEW.note_id, NEW.title);
END;

CREATE TRIGGER fts_notes_after_delete
AFTER DELETE ON notes
BEGIN
    DELETE FROM title_search WHERE note_id = OLD.note_id;
    DELETE FROM content_search WHERE note_id = OLD.note_id;
END;


-- <-- FTS Triggers: Journal Content -->

CREATE TRIGGER fts_journal_content_after_insert
AFTER INSERT ON journal_content
BEGIN
    INSERT INTO content_search (note_id, note_content)
    SELECT NEW.note_id, NEW.content WHERE NEW.content IS NOT NULL;
END;

CREATE TRIGGER fts_journal_content_after_update
AFTER UPDATE OF content ON journal_content
BEGIN
    DELETE FROM content_search
    WHERE note_id = OLD.note_id AND note_content = OLD.content;

    INSERT INTO content_search (note_id, note_content)
    SELECT NEW.note_id, NEW.content WHERE NEW.content IS NOT NULL;
END;

CREATE TRIGGER fts_journal_content_after_delete
AFTER DELETE ON journal_content
BEGIN
    DELETE FROM content_search
    WHERE note_id = OLD.note_id AND note_content = OLD.content;
END;


-- <-- FTS Triggers: People Notes (met_place) -->

CREATE TRIGGER fts_people_notes_after_insert
AFTER INSERT ON people_notes
BEGIN
    INSERT INTO content_search (note_id, note_content)
    SELECT NEW.note_id, NEW.met_place WHERE NEW.met_place IS NOT NULL;
END;

CREATE TRIGGER fts_people_notes_after_update
AFTER UPDATE OF met_place ON people_notes
BEGIN
    DELETE FROM content_search
    WHERE note_id = OLD.note_id AND note_content = OLD.met_place;

    INSERT INTO content_search (note_id, note_content)
    SELECT NEW.note_id, NEW.met_place WHERE NEW.met_place IS NOT NULL;
END;

CREATE TRIGGER fts_people_notes_after_delete
AFTER DELETE ON people_notes
BEGIN
    DELETE FROM content_search
    WHERE note_id = OLD.note_id AND note_content = OLD.met_place;
END;


-- <-- FTS Triggers: People Nicknames -->

CREATE TRIGGER fts_people_nicknames_after_insert
AFTER INSERT ON people_nicknames
BEGIN
    INSERT INTO content_search (note_id, note_content)
    SELECT NEW.note_id, NEW.nickname WHERE NEW.nickname IS NOT NULL;
END;

CREATE TRIGGER fts_people_nicknames_after_update
AFTER UPDATE OF nickname ON people_nicknames
BEGIN
    DELETE FROM content_search
    WHERE note_id = OLD.note_id AND note_content = OLD.nickname;

    INSERT INTO content_search (note_id, note_content)
    SELECT NEW.note_id, NEW.nickname WHERE NEW.nickname IS NOT NULL;
END;

CREATE TRIGGER fts_people_nicknames_after_delete
AFTER DELETE ON people_nicknames
BEGIN
    DELETE FROM content_search
    WHERE note_id = OLD.note_id AND note_content = OLD.nickname;
END;


-- <-- FTS Triggers: People Contact Info (identifier) -->

CREATE TRIGGER fts_people_contact_after_insert
AFTER INSERT ON people_contact_info
BEGIN
    INSERT INTO content_search (note_id, note_content)
    SELECT NEW.note_id, NEW.identifier WHERE NEW.identifier IS NOT NULL;
END;

CREATE TRIGGER fts_people_contact_after_update
AFTER UPDATE OF identifier ON people_contact_info
BEGIN
    DELETE FROM content_search
    WHERE note_id = OLD.note_id AND note_content = OLD.identifier;

    INSERT INTO content_search (note_id, note_content)
    SELECT NEW.note_id, NEW.identifier WHERE NEW.identifier IS NOT NULL;
END;

CREATE TRIGGER fts_people_contact_after_delete
AFTER DELETE ON people_contact_info
BEGIN
    DELETE FROM content_search
    WHERE note_id = OLD.note_id AND note_content = OLD.identifier;
END;


-- <-- FTS Triggers: People Physical Traits -->

CREATE TRIGGER fts_people_physical_after_insert
AFTER INSERT ON people_physical_traits
BEGIN
    INSERT INTO content_search (note_id, note_content)
    SELECT NEW.note_id, NEW.physical_trait WHERE NEW.physical_trait IS NOT NULL;
END;

CREATE TRIGGER fts_people_physical_after_update
AFTER UPDATE OF physical_trait ON people_physical_traits
BEGIN
    DELETE FROM content_search
    WHERE note_id = OLD.note_id AND note_content = OLD.physical_trait;

    INSERT INTO content_search (note_id, note_content)
    SELECT NEW.note_id, NEW.physical_trait WHERE NEW.physical_trait IS NOT NULL;
END;

CREATE TRIGGER fts_people_physical_after_delete
AFTER DELETE ON people_physical_traits
BEGIN
    DELETE FROM content_search
    WHERE note_id = OLD.note_id AND note_content = OLD.physical_trait;
END;


-- <-- FTS Triggers: People Behavioral Traits -->

CREATE TRIGGER fts_people_behavioral_after_insert
AFTER INSERT ON people_behavioral_traits
BEGIN
    INSERT INTO content_search (note_id, note_content)
    SELECT NEW.note_id, NEW.behavioral_trait WHERE NEW.behavioral_trait IS NOT NULL;
END;

CREATE TRIGGER fts_people_behavioral_after_update
AFTER UPDATE OF behavioral_trait ON people_behavioral_traits
BEGIN
    DELETE FROM content_search
    WHERE note_id = OLD.note_id AND note_content = OLD.behavioral_trait;

    INSERT INTO content_search (note_id, note_content)
    SELECT NEW.note_id, NEW.behavioral_trait WHERE NEW.behavioral_trait IS NOT NULL;
END;

CREATE TRIGGER fts_people_behavioral_after_delete
AFTER DELETE ON people_behavioral_traits
BEGIN
    DELETE FROM content_search
    WHERE note_id = OLD.note_id AND note_content = OLD.behavioral_trait;
END;


-- <-- FTS Triggers: Knowledge Notes -->

CREATE TRIGGER fts_knowledge_after_insert
AFTER INSERT ON knowledge_notes
BEGIN
    INSERT INTO content_search (note_id, note_content)
    SELECT NEW.note_id, NEW.content WHERE NEW.content IS NOT NULL;
END;

CREATE TRIGGER fts_knowledge_after_update
AFTER UPDATE OF content ON knowledge_notes
BEGIN
    DELETE FROM content_search
    WHERE note_id = OLD.note_id AND note_content = OLD.content;

    INSERT INTO content_search (note_id, note_content)
    SELECT NEW.note_id, NEW.content WHERE NEW.content IS NOT NULL;
END;

CREATE TRIGGER fts_knowledge_after_delete
AFTER DELETE ON knowledge_notes
BEGIN
    DELETE FROM content_search
    WHERE note_id = OLD.note_id AND note_content = OLD.content;
END;


-- <-- FTS Triggers: Writings (Parts via Drafts) -->
-- Because 'parts' lacks a 'note_id', we must join it
-- with 'drafts' to find where the content belongs.
-- Fact check: true. AI is right for once!

CREATE TRIGGER fts_parts_after_insert
AFTER INSERT ON parts
BEGIN
    INSERT INTO content_search (note_id, note_content)
    SELECT drafts.note_id, NEW.content
    FROM drafts
    WHERE drafts.draft_id = NEW.draft_id
      AND NEW.content IS NOT NULL;
END;

CREATE TRIGGER fts_parts_after_update
AFTER UPDATE OF content ON parts
BEGIN
    -- Delete the old content using a subquery to find the note_id
    DELETE FROM content_search
    WHERE note_id = (SELECT note_id FROM drafts WHERE draft_id = OLD.draft_id)
      AND note_content = OLD.content;

    -- Insert the new content
    INSERT INTO content_search (note_id, note_content)
    SELECT drafts.note_id, NEW.content
    FROM drafts
    WHERE drafts.draft_id = NEW.draft_id
      AND NEW.content IS NOT NULL;
END;

CREATE TRIGGER fts_parts_after_delete
AFTER DELETE ON parts
BEGIN
    DELETE FROM content_search
    WHERE note_id = (SELECT note_id FROM drafts WHERE draft_id = OLD.draft_id)
      AND note_content = OLD.content;
END;

-- ==================================================
-- Views + Triggers
-- ==================================================

-- <-- Notes setup -->
-- NOTE: The created views are only intended to streamline notes insertion. 
-- Deletion and updating should be done through either the notes table or the corresponding _notes table.

-- JOURNAL

CREATE VIEW journal_note_entry AS
SELECT
    n.note_id,
    n.title,
    n.created_at,
    n.updated_at,
    j.calendar_day,
    j.mood_rating
FROM notes n
JOIN journal_notes j ON j.note_id = n.note_id
WHERE n.category_id = 1;

CREATE TRIGGER journal_note_insert
INSTEAD OF INSERT ON journal_note_entry
BEGIN
    INSERT INTO notes (title, category_id)
    VALUES (NEW.title, 1);

    INSERT INTO journal_notes (note_id, calendar_day, mood_rating)
    VALUES (
        last_insert_rowid(),
        COALESCE(NEW.calendar_day, DATE('now')),
        COALESCE(NEW.mood_rating, 5)
    );
END;


-- PEOPLE

CREATE VIEW people_note_entry AS
SELECT
    n.note_id,
    n.title,
    n.created_at,
    n.updated_at,
    p.photo_note_id,
    p.relation_to_me,
    p.date_of_birth,
    p.residence_place,
    p.first_met,
    p.met_place
FROM notes n
JOIN people_notes p ON p.note_id = n.note_id
WHERE n.category_id = 2;

CREATE TRIGGER people_note_insert
INSTEAD OF INSERT ON people_note_entry
BEGIN
    INSERT INTO notes (title, category_id)
    VALUES (NEW.title, 2);

    INSERT INTO people_notes (note_id, photo_note_id, relation_to_me, date_of_birth, residence_place, first_met, met_place)
    VALUES (
        last_insert_rowid(),
        NEW.photo_note_id,
        NEW.relation_to_me,
        NEW.date_of_birth,
        NEW.residence_place,
        NEW.first_met,
        NEW.met_place
    );
END;


-- WRITINGS

CREATE VIEW writings_note_entry AS
SELECT
    n.note_id,
    n.title,
    n.created_at,
    n.updated_at,
    w.category_id AS writing_category_id,
    w.status_id   AS writing_status_id
FROM notes n
JOIN writings_notes w ON w.note_id = n.note_id
WHERE n.category_id = 3;

CREATE TRIGGER writings_note_insert
INSTEAD OF INSERT ON writings_note_entry
BEGIN
    INSERT INTO notes (title, category_id)
    VALUES (NEW.title, 3);

    INSERT INTO writings_notes (note_id, category_id, status_id)
    VALUES (
        last_insert_rowid(),
        NEW.writing_category_id,
        NEW.writing_status_id
    );
END;


-- KNOWLEDGE

CREATE VIEW knowledge_note_entry AS
SELECT
    n.note_id,
    n.title,
    n.created_at,
    n.updated_at,
    k.status_id  AS knowledge_status_id,
    k.subject_id AS knowledge_subject_id,
    k.content
FROM notes n
JOIN knowledge_notes k ON k.note_id = n.note_id
WHERE n.category_id = 4;

CREATE TRIGGER knowledge_note_insert
INSTEAD OF INSERT ON knowledge_note_entry
BEGIN
    INSERT INTO notes (title, category_id)
    VALUES (NEW.title, 4);

    INSERT INTO knowledge_notes (note_id, status_id, subject_id, content)
    VALUES (
        last_insert_rowid(),
        NEW.knowledge_status_id,
        NEW.knowledge_subject_id,
        NEW.content
    );
END;


-- FILES

CREATE VIEW file_note_entry AS
SELECT
    n.note_id,
    n.title,
    n.created_at,
    n.updated_at,
    f.encrypted_filename,
    f.mime_type,
    f.size_bytes,
    f.file_salt
FROM notes n
JOIN file_notes f ON f.note_id = n.note_id
WHERE n.category_id = 5;

CREATE TRIGGER file_note_insert
INSTEAD OF INSERT ON file_note_entry
BEGIN
    INSERT INTO notes (title, category_id)
    VALUES (NEW.title, 5);

    INSERT INTO file_notes (note_id, encrypted_filename, mime_type, size_bytes, file_salt)
    VALUES (
        last_insert_rowid(),
        NEW.encrypted_filename,
        NEW.mime_type,
        COALESCE(NEW.size_bytes, 0),
        NEW.file_salt
    );
END;

-- <-- Notes consistency -->

CREATE TRIGGER prevent_note_category_update
BEFORE UPDATE OF category_id ON notes
BEGIN
    SELECT RAISE(ABORT, 'Note category cannot be changed after creation.')
    WHERE OLD.category_id IS NOT NULL AND NEW.category_id != OLD.category_id;
END;

-- <-- Relation consistency -->

CREATE TRIGGER after_relations_insert
AFTER INSERT ON people_relations
BEGIN
    INSERT INTO people_relations (note_id_a, note_id_b, relation, intimacy_rating)
    SELECT
        NEW.note_id_b,
        NEW.note_id_a,
        relation_types.counterpart,
        NEW.intimacy_rating
    FROM relation_types
    WHERE relation_types.relation = NEW.relation;
END;

CREATE TRIGGER after_relations_update
AFTER UPDATE ON people_relations
BEGIN
    UPDATE people_relations
    SET relation = (
        SELECT counterpart FROM relation_types
        WHERE relation = NEW.relation
    )
    WHERE note_id_a = NEW.note_id_b
    AND note_id_b = NEW.note_id_a;
END;

CREATE TRIGGER after_relations_delete
AFTER DELETE ON people_relations
BEGIN
    DELETE FROM people_relations
    WHERE note_id_a = OLD.note_id_b
    AND note_id_b = OLD.note_id_a;
END;

CREATE TRIGGER prevent_self_relation
BEFORE INSERT ON people_relations
BEGIN
    SELECT RAISE(ABORT, 'A person cannot be related to themselves.')
    WHERE NEW.note_id_a = NEW.note_id_b;
END;

-- <-- updated_at Triggers (Parent: notes) -->

-- 1. Base Notes Table
CREATE TRIGGER updated_at_notes_update
AFTER UPDATE OF title ON notes
BEGIN
    UPDATE notes SET updated_at = DATETIME('now') WHERE note_id = NEW.note_id;
END;


-- 2. Journal Content
CREATE TRIGGER updated_at_journal_content_insert
AFTER INSERT ON journal_content
BEGIN
    UPDATE notes SET updated_at = DATETIME('now') WHERE note_id = NEW.note_id;
END;

CREATE TRIGGER updated_at_journal_content_update
AFTER UPDATE OF content ON journal_content
BEGIN
    -- Update end_time on journal_content
    UPDATE journal_content
    SET end_time = TIME('now')
    WHERE rowid = OLD.rowid;

    -- Update updated_at
    UPDATE notes
    SET updated_at = DATETIME('now')
    WHERE note_id = NEW.note_id;
END;

CREATE TRIGGER updated_at_journal_content_delete
AFTER DELETE ON journal_content
BEGIN
    UPDATE notes SET updated_at = DATETIME('now') WHERE note_id = OLD.note_id;
END;


-- 3. People Notes (1-to-1 extension)
CREATE TRIGGER updated_at_people_notes_update
AFTER UPDATE OF photo_note_id, relation_to_me, first_met, met_place ON people_notes
BEGIN
    UPDATE notes SET updated_at = DATETIME('now') WHERE note_id = NEW.note_id;
END;


-- 4. People Nicknames
CREATE TRIGGER updated_at_people_nicknames_insert
AFTER INSERT ON people_nicknames
BEGIN
    UPDATE notes SET updated_at = DATETIME('now') WHERE note_id = NEW.note_id;
END;

CREATE TRIGGER updated_at_people_nicknames_update
AFTER UPDATE OF nickname ON people_nicknames
BEGIN
    UPDATE notes SET updated_at = DATETIME('now') WHERE note_id = NEW.note_id;
END;

CREATE TRIGGER updated_at_people_nicknames_delete
AFTER DELETE ON people_nicknames
BEGIN
    UPDATE notes SET updated_at = DATETIME('now') WHERE note_id = OLD.note_id;
END;


-- 5. People Contact Info
CREATE TRIGGER updated_at_people_contact_insert
AFTER INSERT ON people_contact_info
BEGIN
    UPDATE notes SET updated_at = DATETIME('now') WHERE note_id = NEW.note_id;
END;

CREATE TRIGGER updated_at_people_contact_update
AFTER UPDATE OF medium, identifier ON people_contact_info
BEGIN
    UPDATE notes SET updated_at = DATETIME('now') WHERE note_id = NEW.note_id;
END;

CREATE TRIGGER updated_at_people_contact_delete
AFTER DELETE ON people_contact_info
BEGIN
    UPDATE notes SET updated_at = DATETIME('now') WHERE note_id = OLD.note_id;
END;


-- 6. People Physical Traits
CREATE TRIGGER updated_at_people_physical_insert
AFTER INSERT ON people_physical_traits
BEGIN
    UPDATE notes SET updated_at = DATETIME('now') WHERE note_id = NEW.note_id;
END;

CREATE TRIGGER updated_at_people_physical_update
AFTER UPDATE OF physical_trait ON people_physical_traits
BEGIN
    UPDATE notes SET updated_at = DATETIME('now') WHERE note_id = NEW.note_id;
END;

CREATE TRIGGER updated_at_people_physical_delete
AFTER DELETE ON people_physical_traits
BEGIN
    UPDATE notes SET updated_at = DATETIME('now') WHERE note_id = OLD.note_id;
END;


-- 7. People Behavioral Traits
CREATE TRIGGER updated_at_people_behavioral_insert
AFTER INSERT ON people_behavioral_traits
BEGIN
    UPDATE notes SET updated_at = DATETIME('now') WHERE note_id = NEW.note_id;
END;

CREATE TRIGGER updated_at_people_behavioral_update
AFTER UPDATE OF behavioral_trait ON people_behavioral_traits
BEGIN
    UPDATE notes SET updated_at = DATETIME('now') WHERE note_id = NEW.note_id;
END;

CREATE TRIGGER updated_at_people_behavioral_delete
AFTER DELETE ON people_behavioral_traits
BEGIN
    UPDATE notes SET updated_at = DATETIME('now') WHERE note_id = OLD.note_id;
END;


-- 8. People Impressions Over Time
CREATE TRIGGER updated_at_people_impression_insert
AFTER INSERT ON people_impression_over_time
BEGIN
    UPDATE notes SET updated_at = DATETIME('now') WHERE note_id = NEW.note_id;
END;

CREATE TRIGGER updated_at_people_impression_update
AFTER UPDATE OF log_date, impression_rating ON people_impression_over_time
BEGIN
    UPDATE notes SET updated_at = DATETIME('now') WHERE note_id = NEW.note_id;
END;

CREATE TRIGGER updated_at_people_impression_delete
AFTER DELETE ON people_impression_over_time
BEGIN
    UPDATE notes SET updated_at = DATETIME('now') WHERE note_id = OLD.note_id;
END;


-- 9. People Relations (Updates BOTH people involved)
CREATE TRIGGER updated_at_people_relations_insert
AFTER INSERT ON people_relations
BEGIN
    UPDATE notes SET updated_at = DATETIME('now')
    WHERE note_id IN (NEW.note_id_a, NEW.note_id_b);
END;

CREATE TRIGGER updated_at_people_relations_update
AFTER UPDATE OF relation, intimacy_rating ON people_relations
BEGIN
    UPDATE notes SET updated_at = DATETIME('now')
    WHERE note_id IN (NEW.note_id_a, NEW.note_id_b);
END;

CREATE TRIGGER updated_at_people_relations_delete
AFTER DELETE ON people_relations
BEGIN
    UPDATE notes SET updated_at = DATETIME('now')
    WHERE note_id IN (OLD.note_id_a, OLD.note_id_b);
END;


-- 10. Knowledge Notes (1-to-1 extension)
CREATE TRIGGER updated_at_knowledge_notes_update
AFTER UPDATE OF status_id, subject_id, content ON knowledge_notes
BEGIN
    UPDATE notes SET updated_at = DATETIME('now') WHERE note_id = NEW.note_id;
END;


-- 11. Parts (Joined via Drafts)
CREATE TRIGGER updated_at_parts_insert
AFTER INSERT ON parts
BEGIN
    UPDATE notes SET updated_at = DATETIME('now')
    WHERE note_id = (SELECT note_id FROM drafts WHERE draft_id = NEW.draft_id);
END;

CREATE TRIGGER updated_at_parts_update
AFTER UPDATE OF content ON parts
BEGIN
    UPDATE notes SET updated_at = DATETIME('now')
    WHERE note_id = (SELECT note_id FROM drafts WHERE draft_id = NEW.draft_id);
END;

CREATE TRIGGER updated_at_parts_delete
AFTER DELETE ON parts
BEGIN
    UPDATE notes SET updated_at = DATETIME('now')
    WHERE note_id = (SELECT note_id FROM drafts WHERE draft_id = OLD.draft_id);
END;
