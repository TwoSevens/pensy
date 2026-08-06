import { invoke } from "@tauri-apps/api/core";
import { info, error, debug } from '@tauri-apps/plugin-log';

type VaultState = {
    loaded: boolean;
    error: string | null;
};

export const vault_state = $state<VaultState>({
    loaded: false,
    error: null,
});

export async function open_vault(path: string, password: string): Promise<void> {
    try {
        await invoke("open_vault", { path, passphrase: password });
        vault_state.loaded = true;
        vault_state.error = null;
        info(`Vault opened successfully at path: ${path}`);
    } catch (err) {
        vault_state.loaded = false;
        vault_state.error = err as string;
        error(`Failed to open vault: ${err}`);
    }
}
