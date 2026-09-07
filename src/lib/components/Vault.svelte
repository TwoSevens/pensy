<script lang="ts">
  import "./Vault.css";
  import {
    NoteCategory,
    type Note,
    string_to_note_category,
    create_note,
    get_notes,
    update_note_title,
  } from "../../lib/notes.svelte";
  import {
    Calendar,
    ChartColumn,
    Contact,
    Folder,
    GraduationCap,
    Library,
    NotepadText,
    PanelLeft,
    PanelLeftClose,
    Search,
    Settings,
    Plus,
    X,
  } from "@lucide/svelte";

  // The five rows seeded into note_category.
  const CATEGORIES = [
    { id: "journal", label: "Journal", icon: NotepadText },
    { id: "people", label: "People", icon: Contact },
    { id: "writings", label: "Writings", icon: Library },
    { id: "knowledge", label: "Knowledge", icon: GraduationCap },
    { id: "files", label: "Files", icon: Folder },
  ] as const;

  const open_tabs: Array<Note> = $state([]);
  let focused_tab = $state(0);
  let tab_status = $state("");

  let panel_open = $state(true);
  let active_category = $state<(typeof CATEGORIES)[number]["id"]>("journal");
  let query = $state("");
  let notes = $state<Array<Note>>([]);

  let staging_mode = $state(false);
  let staging_title = $state("");
  let staging_title_input = $state<HTMLInputElement>();
  let creating_note = $state(false);

  let editing_title = $state("");
  let original_title = $state("");
  let title_input = $state<HTMLInputElement>();
  let saving_title = $state(false);

  function select_category(id: (typeof CATEGORIES)[number]["id"]) {
    active_category = id;
  }

  function stage_new_note() {
    if (creating_note) {
      return;
    }

    tab_status = "";
    staging_title = "";
    staging_mode = true;
  }

  function cancel_staged_note() {
    if (creating_note) {
      return;
    }

    staging_mode = false;
    staging_title = "";
  }

  async function refresh_notes() {
    const category = string_to_note_category(active_category);
    if (category === undefined) {
      notes = [];
      return;
    }

    notes = await get_notes(category);
  }

  $effect(() => {
    active_category;
    void refresh_notes();
  });

  $effect(() => {
    if (staging_mode && staging_title_input) {
      staging_title_input.focus();
    }
  });

  function sync_title_editor() {
    const selected_note = open_tabs[focused_tab];
    editing_title = selected_note?.title ?? "";
    original_title = selected_note?.title ?? "";
  }

  function replace_note_title(noteId: number, title: string) {
    const open_tab = open_tabs.find((tab) => tab.noteId === noteId);
    if (open_tab) {
      open_tab.title = title;
    }

    const list_note = notes.find((note) => note.noteId === noteId);
    if (list_note) {
      list_note.title = title;
    }
  }

  function open_note(note: Note) {
    const existing_tab = open_tabs.findIndex((tab) => tab.noteId === note.noteId);
    if (existing_tab >= 0) {
      focused_tab = existing_tab;
      sync_title_editor();
      tab_status = "";
      return;
    }

    open_tabs.push({ ...note });
    focused_tab = open_tabs.length - 1;
    sync_title_editor();
    tab_status = "";
  }

  function select_tab(index: number) {
    if (index < 0 || index >= open_tabs.length) {
      return;
    }

    focused_tab = index;
    sync_title_editor();
    tab_status = "";
  }

  function close_tab(index: number) {
    if (index < 0 || index >= open_tabs.length) {
      return;
    }

    open_tabs.splice(index, 1);
    if (open_tabs.length === 0) {
      focused_tab = 0;
      editing_title = "";
      original_title = "";
      return;
    }

    if (index < focused_tab) {
      focused_tab -= 1;
    } else if (index === focused_tab) {
      focused_tab = Math.min(focused_tab, open_tabs.length - 1);
    }

    sync_title_editor();
  }

  function handle_title_input(event: Event) {
    const title = (event.currentTarget as HTMLInputElement).value;
    editing_title = title;

    const selected_note = open_tabs[focused_tab];
    if (selected_note) {
      replace_note_title(selected_note.noteId, title);
    }
  }

  function cancel_title_edit() {
    const selected_note = open_tabs[focused_tab];
    if (selected_note) {
      replace_note_title(selected_note.noteId, original_title);
    }

    editing_title = original_title;
  }

  async function save_title() {
    if (saving_title) {
      return;
    }

    const selected_note = open_tabs[focused_tab];
    if (!selected_note) {
      return;
    }

    const noteId = selected_note.noteId;
    const title = editing_title.trim();
    if (title.length === 0) {
      cancel_title_edit();
      return;
    }

    if (title === original_title) {
      return;
    }

    replace_note_title(noteId, title);
    editing_title = title;
    saving_title = true;
    const result = await update_note_title(noteId, title);
    saving_title = false;

    if (result instanceof Error) {
      replace_note_title(noteId, original_title);
      if (open_tabs[focused_tab]?.noteId === noteId) {
        editing_title = original_title;
      }
      tab_status = result.message;
      return;
    }

    if (open_tabs[focused_tab]?.noteId === noteId) {
      original_title = title;
    }
    tab_status = "";
    await refresh_notes();
  }

  function handle_title_keydown(event: KeyboardEvent) {
    if (event.key === "Enter") {
      event.preventDefault();
      void save_title();
      title_input?.blur();
    } else if (event.key === "Escape") {
      event.preventDefault();
      cancel_title_edit();
      title_input?.blur();
    }
  }

  async function commit_staged_note() {
    if (creating_note) {
      return;
    }

    const title = staging_title.trim();
    if (title.length === 0) {
      cancel_staged_note();
      return;
    }

    const category = string_to_note_category(active_category);
    if (category === undefined) {
      cancel_staged_note();
      return;
    }

    creating_note = true;
    const note = await create_note(title, category);
    creating_note = false;

    if (note instanceof Error) {
      tab_status = note.message;
      staging_title_input?.focus();
      return;
    }

    staging_mode = false;
    staging_title = "";
    open_note(note);
    await refresh_notes();
  }

  function handle_staging_keydown(event: KeyboardEvent) {
    if (event.key === "Enter") {
      event.preventDefault();
      void commit_staged_note();
    } else if (event.key === "Escape") {
      event.preventDefault();
      cancel_staged_note();
    }
  }
</script>

<div class="app" class:panel-open={panel_open}>
  <header class="topbar">
    <button
      class="icon-btn tip-down"
      data-label={panel_open ? "Hide sidebar" : "Show sidebar"}
      aria-label={panel_open ? "Hide sidebar" : "Show sidebar"}
      aria-expanded={panel_open}
      onclick={() => (panel_open = !panel_open)}
    >
      {#if panel_open}
        <PanelLeftClose size="17" />
      {:else}
        <PanelLeft size="17" />
      {/if}
    </button>

    <div class="tabs" role="tablist" aria-label="Open notes">
      {#each open_tabs as tab, index}
        <div
          class="tab"
          class:active={index === focused_tab}
          role="tab"
          aria-selected={index === focused_tab}
        >
          <button
            class="tab-main"
            type="button"
            aria-label={`Open ${tab.title}`}
            onclick={() => select_tab(index)}
          >
            <span>{tab.title}</span>
          </button>
          <button
            class="tab-close"
            type="button"
            aria-label={`Close ${tab.title}`}
            onclick={() => close_tab(index)}
          >
            <X size="14" />
          </button>
        </div>
      {/each}
      <button
        class="tab new-tab"
        type="button"
        aria-label="New note"
        onclick={stage_new_note}
      >
        <Plus size="17" />
      </button>
    </div>
  </header>

  <nav class="rail">
    <div class="rail-group">
      {#each CATEGORIES as item (item.id)}
        <button
          class="icon-btn tip-right"
          class:active={item.id === active_category}
          data-label={item.label}
          aria-label={item.label}
          aria-current={item.id === active_category}
          onclick={() => select_category(item.id)}
        >
          <item.icon size="17" />
        </button>
      {/each}
    </div>

    <!-- set apart from the categories: these are views, not note types -->
    <div class="rail-group rail-middle">
      <button
        class="icon-btn tip-right"
        data-label="Calendar"
        aria-label="Calendar"
      >
        <Calendar size="17" />
      </button>
      <button
        class="icon-btn tip-right"
        data-label="Statistics"
        aria-label="Statistics"
      >
        <ChartColumn size="17" />
      </button>
    </div>

    <div class="rail-group">
      <button
        class="icon-btn tip-right"
        data-label="Settings"
        aria-label="Settings"
      >
        <Settings size="17" />
      </button>
    </div>
  </nav>

  {#if panel_open}
    <aside class="panel">
      <div class="panel-head">
        <div class="search">
          <div class="field">
            <input
              type="text"
              bind:value={query}
              placeholder="Search notes…"
              aria-label="Search notes"
            />
          </div>
          <button
            class="icon-btn tip-down search-btn"
            data-label="Search"
            aria-label="Search"
          >
            <Search size="15" />
          </button>
        </div>

        <div class="note-list">
          {#if notes.length === 0}
            <p class="empty">No notes</p>
          {:else}
            {#each notes as note (note.noteId)}
              <button
                class="note-item"
                class:active={open_tabs[focused_tab]?.noteId === note.noteId}
                type="button"
                onclick={() => open_note(note)}
              >
                <span>{note.title}</span>
              </button>
            {/each}
          {/if}
        </div>
      </div>
    </aside>
  {/if}

  <main
    class="screen"
    onclick={(event) => {
      if (staging_mode && event.target !== staging_title_input) {
        void commit_staged_note();
      }
    }}
  >
    {#if staging_mode}
      <div class="staging-note">
        <p class="staging-kicker">New note</p>
        <input
          class="staging-title"
          bind:this={staging_title_input}
          bind:value={staging_title}
          type="text"
          placeholder="Untitled note"
          aria-label="Note title"
          autocomplete="off"
          onkeydown={handle_staging_keydown}
          onblur={() => void commit_staged_note()}
        />
      </div>
    {:else if open_tabs[focused_tab]}
      <div class="note-editor">
        <p class="note-kicker">Note</p>
        <input
          class="note-title"
          bind:this={title_input}
          value={editing_title}
          type="text"
          aria-label="Edit note title"
          autocomplete="off"
          oninput={handle_title_input}
          onkeydown={handle_title_keydown}
          onblur={() => void save_title()}
        />
      </div>
    {/if}
  </main>

  {#if tab_status}
    <div class="status">{tab_status}</div>
  {/if}
</div>
