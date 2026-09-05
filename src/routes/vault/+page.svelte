<script lang="ts">
  import "./+page.css";
  import {
    NoteCategory,
    type Note,
    string_to_note_category,
    create_note,
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
    FolderTree,
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

  let staging_mode = $state(false);
  let staging_title = $state("");

  function select_category(id: (typeof CATEGORIES)[number]["id"]) {
    active_category = id;
  }

  async function new_note() {
    let note = await create_note(
      staging_title,
      string_to_note_category(active_category) as NoteCategory,
    );
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

    <div class="tabs">
      {#each open_tabs as tab, index}
        <button class="tab" class:active={index === focused_tab}>
          <span>{tab.title}</span>
        </button>
      {/each}
      <button class="tab" onclick={() => (staging_mode = true)}>
        <Plus />
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
          <p class="empty">No notes</p>
        </div>
      </div>
    </aside>
  {/if}

  <main class="screen">
    {#if staging_mode}
      <input class="field" type="text" bind:value={staging_title} />
      <button class="field" onclick={() => new_note()}>Confirm</button>
    {/if}
  </main>

  {#if focused_tab && tab_status}
    <div class="status">{tab_status}</div>
  {/if}
</div>
