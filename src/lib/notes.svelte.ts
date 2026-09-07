import { invoke } from "@tauri-apps/api/core";

export enum NoteCategory {
    Journal = "Journal",
    People = "People",
    Writings = "Writings",
    Knowledge = "Knowledge",
    Files = "Files"
}

export function string_to_note_category(text: string): NoteCategory | undefined {
    switch (text.toLowerCase()) {
        case "journal":
            return NoteCategory.Journal;
        case "people":
            return NoteCategory.People;
        case "writings":
            return NoteCategory.Writings;
        case "knowledge":
            return NoteCategory.Knowledge;
        case "files":
            return NoteCategory.Files;
        default:
            return undefined;
    }
}

export type Note = {
    noteId: number,
    title: string,
    category: NoteCategory
}

type BackendNote = {
    note_id: number,
    title: string,
    category: string | null
}

function backend_category_to_note_category(category: string | null): NoteCategory | undefined {
    return category == null ? undefined : string_to_note_category(category);
}

function to_error(error: unknown): Error {
    return error instanceof Error ? error : new Error(String(error));
}

export async function create_note(title: string, category: NoteCategory): Promise<Note | Error> {
    try {
        let noteId = await invoke<number>("create_note", { title, category });
        return {noteId, title, category} as Note;
    } catch (error) {
        return to_error(error);
    }
}

export async function get_notes(category: NoteCategory): Promise<Array<Note>> {
    try {
        const notes = await invoke<Array<BackendNote>>("get_notes", { category });

        return notes.map((note) => ({
            noteId: note.note_id,
            title: note.title,
            category: backend_category_to_note_category(note.category) ?? category,
        }));
    } catch (error) {
        return [];
    }
}
