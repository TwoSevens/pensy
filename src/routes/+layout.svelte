<script lang="ts">
  import "../app.css";
  import Login from "../lib/components/Login.svelte";
  import Vault from "../lib/components/Vault.svelte";
  import { vault_state } from "../lib/vault.svelte";
</script>

{#if vault_state.loaded}
  <Vault />
{:else}
  <Login />
{/if}
