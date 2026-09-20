<script lang="ts">
  type Props = {
    value: string;
    oninput: (event: Event) => void;
    onkeydown: (event: KeyboardEvent) => void;
    onblur: (event: FocusEvent) => void;
  };

  let { value, oninput, onkeydown, onblur }: Props = $props();
  let title_input = $state<HTMLInputElement>();

  $effect(() => {
    title_input?.focus();
  });
</script>

<div class="staging-note">
  <p class="staging-kicker">New note</p>
  <input
    class="staging-title"
    bind:this={title_input}
    value={value}
    type="text"
    placeholder="Untitled note"
    aria-label="Note title"
    autocomplete="off"
    oninput={oninput}
    onkeydown={onkeydown}
    onblur={onblur}
  />
</div>
