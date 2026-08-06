<script lang="ts">
  import { invoke } from "@tauri-apps/api/core";
  import { open } from "@tauri-apps/plugin-dialog";
  import { onMount } from "svelte";
  import { goto } from "$app/navigation";
  import { open_vault, vault_state } from "../lib/vault.svelte";

  const NEW_VAULT = "__new_vault__";

  let vault_list: string[] = $state([]);
  let selected: string = $state("");
  let password: string = $state("");

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
</script>

<div class="screen">
  <div class="vault-selector">
    <h2>Select Vault</h2>

    <select value={selected} onchange={handleChange}>
      <option value="" disabled>Choose a vault…</option>
      {#each vault_list as vault (vault)}
        <option value={vault}>{vault}</option>
      {/each}
      <option value={NEW_VAULT}>Open/New Vault…</option>
    </select>

    <input
      bind:value={password}
      type="password"
      placeholder="Enter password…"
    />

    <button
      disabled={!selected || !password}
      onclick={async () => {
        await open_vault(selected, password);
        if (vault_state.loaded) {
          goto("/vault");
        }
      }}>Open Vault</button
    >
  </div>

  {#if vault_state.error}
    <p class="error">{vault_state.error}</p>
  {/if}
</div>

<style>
  :global(body) {
    margin: 0;
    padding: 0;
  }

  .screen {
    width: 100vw;
    height: 100vh;
    display: flex;
    flex-direction: column;
    justify-content: center;
    align-items: center;
  }

  .vault-selector {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 1rem;
    border: solid 1px #ccc;
    padding: 1rem;
  }

  select {
    width: 20vw;
  }
  .error {
    color: crimson;
  }

  button {
    width: 30%;
  }
</style>
