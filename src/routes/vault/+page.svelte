<script lang="ts">
  import {
    PanelRight,
    PanelRightClose,
    NotepadText,
    Contact,
    Library,
    GraduationCap,
    Folder,
    Settings,
    type LucideProps,
  } from "@lucide/svelte";

  let icon_props: LucideProps = {
    size: "36px",
  };

  let panel_open = $state(false);

  let tabs = $state(["Untitled 1", "Untitled 2", "Untitled 3"]);
  let active_tab = $state(0);
</script>

<div
  class="app"
  style:--panel-offset={panel_open ? "var(--panel-width)" : "0px"}
>
  <div class="topbar">
    <button
      class="panel-toggle"
      aria-label={panel_open ? "Hide panel" : "Show panel"}
      aria-expanded={panel_open}
      onclick={() => (panel_open = !panel_open)}
    >
      {#if panel_open}
        <PanelRightClose {...icon_props} />
      {:else}
        <PanelRight {...icon_props} />
      {/if}
    </button>

    <div class="tabs">
      {#each tabs as tab, i}
        <button
          class="tab"
          class:active={i === active_tab}
          onclick={() => (active_tab = i)}
        >
          {tab}
        </button>
      {/each}
    </div>
  </div>

  <div class="sidenav">
    <div class="sidenav-top">
      <NotepadText {...icon_props} />
      <Contact {...icon_props} />
      <Library {...icon_props} />
      <GraduationCap {...icon_props} />
      <Folder {...icon_props} />
    </div>

    <div class="sidenav-bottom">
      <Settings {...icon_props} />
    </div>
  </div>

  {#if panel_open}
    <div class="panel"></div>
  {/if}

  <div class="screen"></div>

  <div class="statusbar">
    <p>Pensy V0.1</p>
  </div>
</div>

<style>
  .app {
    /* wrapper exists only to hold the layout variables */
    display: contents;

    --topbar-height: 42px;
    --sidenav-width: 42px;
    --statusbar-height: 28px;
    --panel-width: 380px;
  }

  .topbar {
    position: fixed;
    top: 0;
    left: 0;
    right: 0;
    height: var(--topbar-height);
    display: flex;
    flex-direction: row;
    align-items: stretch;
    background-color: rgb(49, 49, 49);
    z-index: 2;
  }

  .panel-toggle {
    flex: 0 0 var(--sidenav-width);
    display: grid;
    place-items: center;
    padding: 0;
    border: none;
    background: none;
    color: inherit;
    cursor: pointer;
  }

  .tabs {
    flex: 1 1 auto;
    min-width: 0;
    display: flex;
    align-items: stretch;
    overflow-x: auto;
    margin-left: var(--panel-offset);
    transition: margin-left 120ms ease;
  }

  .tab {
    border: none;
    background: none;
    color: inherit;
    cursor: pointer;
    white-space: nowrap;
  }

  .tab.active {
    background-color: rgb(0 0 0 / 0.2);
  }

  .sidenav {
    position: fixed;
    top: var(--topbar-height);
    bottom: 0;
    left: 0;
    width: var(--sidenav-width);
    display: flex;
    flex-direction: column;
    justify-content: space-between;
    background-color: rgb(59, 58, 58);
    z-index: 2;
  }

  .sidenav-top,
  .sidenav-bottom {
    display: flex;
    flex-direction: column;
  }

  .panel {
    position: fixed;
    top: var(--topbar-height);
    bottom: 0;
    left: var(--sidenav-width);
    width: var(--panel-width);
    overflow: auto;
    background-color: grey;
    z-index: 1;
  }

  .screen {
    position: fixed;
    top: var(--topbar-height);
    bottom: var(--statusbar-height);
    left: calc(var(--sidenav-width) + var(--panel-offset));
    right: 0;
    overflow: auto;
    transition: left 120ms ease;
  }

  .statusbar {
    position: fixed;
    bottom: 0;
    right: 0;
    height: var(--statusbar-height);
    display: flex;
    align-items: center;
    padding: 0 8px;
    white-space: nowrap;
    background-color: gray;
    z-index: 3;
  }

  .statusbar p {
    margin: 0;
  }
</style>
