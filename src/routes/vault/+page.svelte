<script lang="ts">
  import {
    Calendar,
    ChartColumn,
    ChevronDown,
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
  } from "@lucide/svelte";

  // The five rows seeded into note_category.
  const CATEGORIES = [
    { id: "journal", label: "Journal", icon: NotepadText },
    { id: "people", label: "People", icon: Contact },
    { id: "writings", label: "Writings", icon: Library },
    { id: "knowledge", label: "Knowledge", icon: GraduationCap },
    { id: "files", label: "Files", icon: Folder },
  ] as const;

  let panel_open = $state(true);
  let active_category = $state<(typeof CATEGORIES)[number]["id"]>("journal");
  let query = $state("");

  // Nothing is loaded until the backend is wired up.
  let open_tabs: string[] = $state([]);
  let active_note: string | null = $state(null);
  let note_status: string | null = $state(null);

  function select_category(id: (typeof CATEGORIES)[number]["id"]) {
    active_category = id;
    // groupable fields differ per category, so the selection does not carry over
    group_field = "";
    combo_query = "";
  }

  /* --- group-by combobox: type to filter, or open and pick ------------------
     Not <datalist> — it cannot be styled to match the rest of the app. */

  // Fields the notes can be grouped by, for the active category.
  // Populated alongside the notes; empty until the backend is wired.
  let group_options: string[] = $state([]);
  let group_field = $state("");
  let combo_query = $state("");
  let combo_open = $state(false);
  let cursor = $state(-1);
  let combo_el = $state<HTMLDivElement>();
  let combo_input = $state<HTMLInputElement>();

  let options = $derived(
    group_options.filter(
      (o) =>
        !combo_query.trim() ||
        o.toLowerCase().includes(combo_query.trim().toLowerCase()),
    ),
  );

  function open_combo() {
    combo_open = true;
  }

  function close_combo() {
    combo_open = false;
    cursor = -1;
    combo_query = group_field; // discard a half-typed filter
  }

  function pick(option: string) {
    group_field = option;
    combo_query = option;
    combo_open = false;
    cursor = -1;
  }

  function combo_keydown(event: KeyboardEvent) {
    if (event.key === "ArrowDown" || event.key === "ArrowUp") {
      event.preventDefault();
      if (!combo_open) return open_combo();
      if (options.length === 0) return;
      const step = event.key === "ArrowDown" ? 1 : -1;
      cursor = (cursor + step + options.length) % options.length;
    } else if (event.key === "Enter") {
      event.preventDefault();
      if (cursor >= 0 && options[cursor]) pick(options[cursor]);
      else if (options.length === 1) pick(options[0]);
    } else if (event.key === "Escape") {
      close_combo();
    } else if (event.key === "Tab") {
      close_combo();
    }
  }
</script>

<svelte:window
  onmousedown={(e) => {
    if (combo_open && combo_el && !combo_el.contains(e.target as Node)) {
      close_combo();
    }
  }}
/>

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
      {#each open_tabs as tab (tab)}
        <button class="tab" class:active={tab === active_note}>
          <span>{tab}</span>
        </button>
      {/each}
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

        <div class="combo" bind:this={combo_el}>
          <div class="field combo-field">
            <span class="overline"><FolderTree /></span>
            <input
              bind:this={combo_input}
              bind:value={combo_query}
              type="text"
              role="combobox"
              placeholder="Group by…"
              autocomplete="off"
              aria-expanded={combo_open}
              aria-controls="group-options"
              aria-autocomplete="list"
              aria-activedescendant={cursor >= 0
                ? `group-option-${cursor}`
                : undefined}
              aria-label="Group notes by"
              onfocus={open_combo}
              oninput={() => {
                cursor = -1;
                combo_open = true;
              }}
              onkeydown={combo_keydown}
            />
            <button
              type="button"
              class="caret"
              class:open={combo_open}
              tabindex="-1"
              aria-hidden="true"
              onmousedown={(e) => {
                e.preventDefault();
                if (combo_open) {
                  close_combo();
                } else {
                  combo_input?.focus();
                  open_combo();
                }
              }}
            >
              <ChevronDown size="13" />
            </button>
          </div>

          {#if combo_open}
            <ul
              class="combo-list"
              id="group-options"
              role="listbox"
              aria-label="Group by field"
            >
              {#each options as option, i (option)}
                <!-- svelte-ignore a11y_click_events_have_key_events -->
                <li
                  id="group-option-{i}"
                  class="combo-option"
                  class:cursor={i === cursor}
                  role="option"
                  aria-selected={option === group_field}
                  onmousedown={(e) => {
                    e.preventDefault();
                    pick(option);
                  }}
                >
                  {option}
                </li>
              {:else}
                <li class="empty">No fields</li>
              {/each}
            </ul>
          {/if}
        </div>
      </div>

      <!-- Notes land here, grouped by {group_field}, once the backend is wired. -->
      <div class="note-list">
        <p class="empty">No notes</p>
      </div>
    </aside>
  {/if}

  <main class="screen">
    <p class="empty">No note open</p>
  </main>

  {#if active_note && note_status}
    <div class="status">{note_status}</div>
  {/if}
</div>

<style>
  .app {
    --panel-offset: 0px;
    height: 100vh;
  }

  .app.panel-open {
    --panel-offset: var(--panel-w);
  }

  /* topbar spans the whole window; tabs are text with a rule under the active */
  .topbar {
    position: fixed;
    top: 0;
    left: 0;
    right: 0;
    height: var(--topbar-h);
    display: flex;
    align-items: center;
    gap: 10px;
    padding-left: 8px;
    background: var(--bg);
    border-bottom: 1px solid var(--line);
    z-index: 30;
  }

  .tabs {
    flex: 1;
    min-width: 0;
    display: flex;
    align-items: stretch;
    height: 100%;
    margin-left: var(--panel-offset);
    overflow-x: auto;
    scrollbar-width: none;
    transition: margin-left 0.15s;
  }

  .tabs::-webkit-scrollbar {
    display: none;
  }

  .tab {
    position: relative;
    display: flex;
    align-items: center;
    gap: 8px;
    max-width: 210px;
    padding: 0 16px;
    font-size: 13px;
    color: var(--faint);
    white-space: nowrap;
    transition: color 0.13s;
  }

  .tab span {
    overflow: hidden;
    text-overflow: ellipsis;
  }

  .tab:hover {
    color: var(--muted);
  }

  .tab.active {
    color: var(--text);
  }

  /* the rule is the only marker — no fill, no border, no pill */
  .tab.active::after {
    content: "";
    position: absolute;
    left: 16px;
    right: 16px;
    bottom: -1px;
    height: 2px;
    background: var(--text);
  }

  .rail {
    position: fixed;
    top: var(--topbar-h);
    bottom: 0;
    left: 0;
    width: var(--rail-w);
    display: flex;
    flex-direction: column;
    justify-content: space-between;
    align-items: center;
    padding: 14px 0;
    border-right: 1px solid var(--line);
    z-index: 20;
  }

  .rail-group {
    display: flex;
    flex-direction: column;
    gap: 10px;
  }

  .rail-middle {
    position: relative;
    padding: 20px 0;
  }

  .rail-middle::before,
  .rail-middle::after {
    content: "";
    position: absolute;
    left: 10px;
    right: 10px;
    height: 1px;
    background: var(--line);
  }

  .rail-middle::before {
    top: 0;
  }

  .rail-middle::after {
    bottom: 0;
  }

  /* the sidebar is the same surface as the editor — one hairline divides them */
  .panel {
    position: fixed;
    top: var(--topbar-h);
    bottom: 0;
    left: var(--rail-w);
    width: var(--panel-w);
    display: flex;
    flex-direction: column;
    background: var(--alt);
    border-right: 1px solid var(--line);
    z-index: 20;
  }

  .panel-head {
    flex: none;
    padding: 16px 14px 12px;
  }

  .search {
    display: flex;
    align-items: center;
    gap: 6px;
    margin-bottom: 16px;
  }

  .search .field {
    flex: 1;
    height: 28px;
  }

  .search-btn {
    flex: none;
    width: 26px;
    height: 26px;
  }

  .combo {
    position: relative;
  }

  .combo-field {
    height: 28px;
  }

  .combo-field .overline {
    margin-right: 10px;
  }

  .combo-field input {
    font-size: 13px;
  }

  .caret {
    display: grid;
    place-items: center;
    color: var(--faint);
    transition: transform 0.14s;
  }

  .caret.open {
    transform: rotate(180deg);
  }

  .combo-list {
    position: absolute;
    top: 100%;
    left: 0;
    right: 0;
    z-index: 60;
    max-height: 230px;
    overflow-y: auto;
    background: var(--bg);
    box-shadow: 0 0 0 1px var(--line);
  }

  .combo-option {
    padding: 7px 12px;
    font-size: 13px;
    color: var(--muted);
    cursor: pointer;
  }

  .combo-option.cursor,
  .combo-option:hover {
    color: var(--text);
    background: var(--hi);
  }

  .combo-option[aria-selected="true"] {
    color: var(--text);
  }

  .note-list {
    flex: 1;
    overflow-y: auto;
    padding-bottom: 20px;
  }

  .screen {
    position: fixed;
    top: var(--topbar-h);
    bottom: 0;
    right: 0;
    left: calc(var(--rail-w) + var(--panel-offset));
    overflow-y: auto;
    transition: left 0.15s;
    /* centres the empty state; swap for `place-items: start stretch` once a
       note actually renders here, or tall content will clip at the top */
    display: grid;
    place-items: center;
  }

  /* bottom right only, hugging its content */
  .status {
    position: fixed;
    right: 16px;
    bottom: 10px;
    z-index: 40;
    font-size: 11px;
    letter-spacing: 0.09em;
    text-transform: uppercase;
    color: var(--faint);
  }
</style>
