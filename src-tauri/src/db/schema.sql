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
    category_id INTEGER,
    FOREIGN KEY (category_id) 
        REFERENCES note_category(category_id)
);

CREATE TABLE notes_tags (
    note_id INTEGER,
    tag_id INTEGER,
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
        DEFAULT (DATE('now')),
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
    photo_note_id INTEGER,
    relation_to_me TEXT,
    first_met TEXT, -- meeting date
    met_place TEXT,
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
    category_id INTEGER,
    status_id INTEGER,
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
    ("Confuding"),
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
    status_id INTEGER,
    subject_id INTEGER,
    content TEXT,
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
    encrypted_filename TEXT,
    mime_type TEXT,
    size_bytes INTEGER
);

-- ==================================================
-- Virtual Tables + Their Triggers
-- ==================================================

CREATE VIRTUAL TABLE title_search USING fts5 (
    note_id UNINDEXED,
    title
);

CREATE VIRTUAL TABLE title_search USING fts5 (
    note_id UNINDEXED,
    note_content
);

-- Todo: virtual tables triggers

-- ==================================================
-- Triggers
-- ==================================================