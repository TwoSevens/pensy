<script lang="ts">
  import "./+page.css";
  import {
    NoteCategory,
    type Note,
    string_to_note_category,
    create_note,
    get_notes,
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

  function open_note(note: Note) {
    const existing_tab = open_tabs.findIndex((tab) => tab.noteId === note.noteId);
    if (existing_tab >= 0) {
      focused_tab = existing_tab;
      return;
    }

    open_tabs.push(note);
    focused_tab = open_tabs.length - 1;
    tab_status = "";
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
        <button
          class="tab"
          class:active={index === focused_tab}
          role="tab"
          aria-selected={index === focused_tab}
          aria-label={`Open ${tab.title}`}
          onclick={() => (focused_tab = index)}
        >
          <span>{tab.title}</span>
        </button>
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
    {/if}
  </main>

  {#if tab_status}
    <div class="status">{tab_status}</div>
  {/if}
</div>
