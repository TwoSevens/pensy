import { invoke } from "@tauri-apps/api/core"

export enum NoteCategory {
    Journal,
    People,
    Writings,
    Knowledge,
    Files
}

export function string_to_note_category(text: string): NoteCategory | undefined {
    switch (text.toLowerCase()) {
        case "journal":
            return NoteCategory.Journal;
        case "People":
            return NoteCategory.People;
        case "writings":
            return NoteCategory.Writings;
        case "knowledge":
            return NoteCategory.Knowledge;
        case "Files":
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

export async function create_note(title: string, category: NoteCategory): Promise<Note | Error> {
    try {
        let noteId = await invoke<number>("create_note", { title, category });
        return {noteId, title, category} as Note;
    } catch (error) {
        return error as Error;
        // Idk, an error happened?
    }
}

export async function get_notes(category: NoteCategory): Promise<Array<Note>> {
    try {
        let notes = invoke<Array<Note>>("get_notes", { category });

        return notes;
    } catch (error) {
        return [];
        // Error again?
    }
}
