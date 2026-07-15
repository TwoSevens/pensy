<script lang="ts">
  import { invoke } from "@tauri-apps/api/core";

  let vaults: string[] = $state([]);
  let selectedVault = $state("");
  let customPath = $state("");
  let password = $state("");
  let error = $state("");
  let loading = $state(false);
  let vaultReady = $state(false);

  async function loadVaults() {
    try {
      vaults = await invoke("list_vaults");
    } catch (e) {
      error = String(e);
    }
  }

  async function openVault() {
    const path = customPath.trim() || selectedVault;
    if (!path) {
      error = "Select a vault or enter a path.";
      return;
    }
    if (!password) {
      error = "Enter a password.";
      return;
    }

    error = "";
    loading = true;

    try {
      await invoke("open_vault", { path, passphrase: password });

      const ready = await invoke<boolean>("is_vault_loaded");
      if (ready) {
        vaultReady = true;
      } else {
        error = "Vault did not initialize.";
      }
    } catch (e) {
      error = String(e);
    } finally {
      loading = false;
    }
  }

  loadVaults();
</script>

{#if vaultReady}
  <main class="container">
    <h1>Vault loaded</h1>
  </main>
{:else}
  <main class="container">
    <h1>Open Vault</h1>

    {#if vaults.length > 0}
      <div class="vault-list">
        {#each vaults as vault}
          <button
            class="vault-item"
            class:selected={selectedVault === vault && !customPath}
            onclick={() => { selectedVault = vault; customPath = ""; }}
          >
            {vault}
          </button>
        {/each}
      </div>
    {/if}

    <form onsubmit={(e) => { e.preventDefault(); openVault(); }}>
      <input
        type="text"
        placeholder="Vault path..."
        bind:value={customPath}
      />
      <input
        type="password"
        placeholder="Password..."
        bind:value={password}
      />
      <button type="submit" disabled={loading}>
        {loading ? "Opening..." : "Open"}
      </button>
    </form>

    {#if error}
      <p class="error">{error}</p>
    {/if}
  </main>
{/if}

<style>
  :root {
    font-family: Inter, Avenir, Helvetica, Arial, sans-serif;
    font-size: 16px;
    line-height: 24px;
    font-weight: 400;
    color: #0f0f0f;
    background-color: #f6f6f6;
    font-synthesis: none;
    text-rendering: optimizeLegibility;
    -webkit-font-smoothing: antialiased;
    -moz-osx-font-smoothing: grayscale;
    -webkit-text-size-adjust: 100%;
  }

  .container {
    margin: 0;
    padding-top: 10vh;
    display: flex;
    flex-direction: column;
    align-items: center;
    text-align: center;
  }

  .vault-list {
    display: flex;
    flex-direction: column;
    gap: 0.5rem;
    margin-bottom: 1.5rem;
    width: 100%;
    max-width: 400px;
  }

  .vault-item {
    border-radius: 8px;
    border: 1px solid transparent;
    padding: 0.6em 1.2em;
    font-size: 1em;
    font-weight: 500;
    font-family: inherit;
    color: #0f0f0f;
    background-color: #ffffff;
    box-shadow: 0 2px 2px rgba(0, 0, 0, 0.2);
    cursor: pointer;
    text-align: left;
    transition: border-color 0.25s, background-color 0.25s;
    word-break: break-all;
  }

  .vault-item:hover {
    border-color: #396cd8;
  }

  .vault-item.selected {
    border-color: #396cd8;
    background-color: #e8e8e8;
  }

  form {
    display: flex;
    gap: 0.5rem;
    flex-wrap: wrap;
    justify-content: center;
  }

  input, button {
    border-radius: 8px;
    border: 1px solid transparent;
    padding: 0.6em 1.2em;
    font-size: 1em;
    font-weight: 500;
    font-family: inherit;
    color: #0f0f0f;
    background-color: #ffffff;
    transition: border-color 0.25s;
    box-shadow: 0 2px 2px rgba(0, 0, 0, 0.2);
    outline: none;
  }

  input {
    min-width: 200px;
  }

  button {
    cursor: pointer;
  }

  button:hover {
    border-color: #396cd8;
  }

  button:active {
    border-color: #396cd8;
    background-color: #e8e8e8;
  }

  button:disabled {
    opacity: 0.6;
    cursor: not-allowed;
  }

  .error {
    color: #e74c3c;
    margin-top: 1rem;
  }

  @media (prefers-color-scheme: dark) {
    :root {
      color: #f6f6f6;
      background-color: #2f2f2f;
    }

    .vault-item, input, button {
      color: #ffffff;
      background-color: #0f0f0f98;
    }

    .vault-item.selected {
      background-color: #0f0f0f69;
    }

    button:active {
      background-color: #0f0f0f69;
    }
  }
</style>
