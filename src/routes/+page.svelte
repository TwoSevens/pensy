<script lang="ts">
  import { invoke } from "@tauri-apps/api/core";
  import { open } from "@tauri-apps/plugin-dialog";
  import { onMount } from "svelte";
  import { goto } from "$app/navigation";
  import { open_vault, vault_state } from "../lib/vault.svelte";
  import {
    ChevronDown,
    CircleAlert,
    Eye,
    EyeOff,
    Lock,
    LoaderCircle,
  } from "@lucide/svelte";

  const NEW_VAULT = "__new_vault__";

  let vault_list: string[] = $state([]);
  let selected: string = $state("");
  let password: string = $state("");
  let show_password = $state(false);
  let unlocking = $state(false);

  onMount(async () => {
    try {
      vault_list = await invoke<string[]>("list_vaults");
    } catch (e) {
      vault_state.error = String(e);
      vault_list = [];
    }
  });

  async function handleChange(event: Event) {
    const target = event.currentTarget as HTMLSelectElement;

    if (target.value !== NEW_VAULT) {
      selected = target.value;
      return;
    }

    // Revert right away so the sentinel never sticks if the dialog is cancelled
    target.value = selected;

    try {
      const path = await open({
        directory: true,
        multiple: false,
        title: "Open or create a vault",
      });

      if (typeof path !== "string") return; // user cancelled

      if (!vault_list.includes(path)) {
        vault_list = [...vault_list, path];
      }
      selected = path;
    } catch (e) {
      vault_state.error = String(e);
    }
  }

  async function unlock() {
    if (!selected || !password || unlocking) return;

    unlocking = true;
    try {
      await open_vault(selected, password);
      if (vault_state.loaded) {
        goto("/vault");
      }
    } finally {
      unlocking = false;
    }
  }

  // Show the folder name; the full path is what we actually pass to the backend.
  function vault_name(path: string): string {
    return path.split(/[/\\]/).filter(Boolean).pop() ?? path;
  }
</script>

<main class="screen">
  <form
    class="card"
    onsubmit={(e) => {
      e.preventDefault();
      unlock();
    }}
  >
    <h1>Pensy</h1>

    <div class="group">
      <label class="overline" for="vault">Vault</label>
      <div class="field">
        <select id="vault" value={selected} onchange={handleChange}>
          <option value="" disabled>Choose a vault…</option>
          {#each vault_list as vault (vault)}
            <option value={vault}>{vault_name(vault)}</option>
          {/each}
          <option value={NEW_VAULT}>Open or create a vault…</option>
        </select>
        <ChevronDown size="15" />
      </div>
    </div>

    <div class="group">
      <label class="overline" for="password">Password</label>
      <div class="field">
        <!-- svelte-ignore a11y_autofocus -->
        <input
          id="password"
          type={show_password ? "text" : "password"}
          bind:value={password}
          placeholder="Enter password…"
          autocomplete="current-password"
        />
        <button
          type="button"
          class="icon-btn tip-left"
          data-label={show_password ? "Hide password" : "Show password"}
          aria-label={show_password ? "Hide password" : "Show password"}
          onclick={() => (show_password = !show_password)}
        >
          {#if show_password}
            <EyeOff size="15" />
          {:else}
            <Eye size="15" />
          {/if}
        </button>
      </div>
    </div>

    {#if vault_state.error}
      <p class="error">
        <CircleAlert size="14" />
        <span>{vault_state.error}</span>
      </p>
    {/if}

    <button class="unlock" type="submit" disabled={!selected || !password || unlocking}>
      {#if unlocking}
        <LoaderCircle size="15" class="spin" />
        <span>Deriving key…</span>
      {:else}
        <Lock size="15" />
        <span>Unlock</span>
      {/if}
    </button>
  </form>
</main>

<style>
  .screen {
    height: 100vh;
    display: grid;
    place-items: center;
  }

  /* no card — the form simply sits on the page */
  .card {
    width: 300px;
  }

  h1 {
    font-size: 30px;
    font-weight: 300;
    letter-spacing: -0.02em;
    margin-bottom: 42px;
  }

  .group {
    margin-bottom: 26px;
  }

  .overline {
    display: block;
    margin-bottom: 4px;
  }

  .field :global(svg) {
    color: var(--faint);
  }

  .unlock {
    width: 100%;
    height: 40px;
    margin-top: 10px;
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 9px;
    font-size: 13px;
    letter-spacing: 0.04em;
    text-transform: uppercase;
    color: var(--bg);
    background: var(--text);
    transition: opacity 0.13s;
  }

  .unlock:hover:not(:disabled) {
    opacity: 0.85;
  }

  .unlock :global(.spin) {
    animation: spin 0.8s linear infinite;
  }

  @keyframes spin {
    to {
      transform: rotate(360deg);
    }
  }

  .error {
    display: flex;
    gap: 7px;
    margin-top: 16px;
    font-size: 12.5px;
    color: var(--danger);
  }

  .error :global(svg) {
    flex: none;
    margin-top: 3px;
  }
</style>
