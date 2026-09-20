<script lang="ts">
  import TitleBar from "./TitleBar.svelte";

  type Props = {
    title: string;
    oninput: (event: Event) => void;
    onkeydown: (event: KeyboardEvent) => void;
    onblur: (event: FocusEvent) => void;
  };

  let { title, oninput, onkeydown, onblur }: Props = $props();
</script>

<TitleBar title="Journal" editable value={title} {oninput} {onkeydown} {onblur} />
