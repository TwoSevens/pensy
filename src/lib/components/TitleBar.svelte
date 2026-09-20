<script lang="ts">
  type Props = {
    title: string;
    editable?: boolean;
    value?: string;
    oninput?: (event: Event) => void;
    onkeydown?: (event: KeyboardEvent) => void;
    onblur?: (event: FocusEvent) => void;
  };

  let {
    title,
    editable = false,
    value = "",
    oninput,
    onkeydown,
    onblur,
  }: Props = $props();
</script>

<div class="title-bar">
  <p class="note-kicker">{title}</p>
  {#if editable}
    <input
      class="note-title"
      value={value}
      type="text"
      aria-label={`Edit ${title} title`}
      autocomplete="off"
      oninput={oninput}
      onkeydown={onkeydown}
      onblur={onblur}
    />
  {:else}
    <h1 class="note-title static-title">{title}</h1>
  {/if}
</div>

<style>
  .title-bar {
    width: min(720px, calc(100% - 64px));
    margin-top: clamp(72px, 13vh, 132px);
  }

  .static-title {
    margin: 0;
    user-select: none;
  }
</style>
