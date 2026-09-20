<script lang="ts">
  import "./JournalEditor.css";
  import { onDestroy, onMount } from "svelte";
  import {
    $getSelection as getSelection,
    $isRangeSelection as isRangeSelection,
    COMMAND_PRIORITY_EDITOR,
    FORMAT_ELEMENT_COMMAND,
    FORMAT_TEXT_COMMAND,
    INDENT_CONTENT_COMMAND,
    OUTDENT_CONTENT_COMMAND,
    REDO_COMMAND,
    UNDO_COMMAND,
    createEditor,
    ParagraphNode,
    type LexicalEditor,
    type TextFormatType,
  } from "lexical";
  import { $createCodeNode as createCodeNode, CodeNode } from "@lexical/code";
  import { HashtagNode } from "@lexical/hashtag";
  import { createEmptyHistoryState, registerHistory } from "@lexical/history";
  import { AutoLinkNode, LinkNode, TOGGLE_LINK_COMMAND, autoLinkEmailMatcher, autoLinkUrlMatcher, registerAutoLink } from "@lexical/link";
  import { ListItemNode, ListNode, INSERT_CHECK_LIST_COMMAND, INSERT_ORDERED_LIST_COMMAND, INSERT_UNORDERED_LIST_COMMAND, registerList } from "@lexical/list";
  import { $convertFromMarkdownString as convertFromMarkdownString, $convertToMarkdownString as convertToMarkdownString, TRANSFORMERS, registerMarkdownShortcuts } from "@lexical/markdown";
  import { $setBlocksType as setBlocksType } from "@lexical/selection";
  import { registerRichText } from "@lexical/rich-text";
  import { INSERT_TABLE_COMMAND, TableCellNode, TableNode, TableRowNode, registerTablePlugin } from "@lexical/table";
  import {
    $createHeadingNode as createHeadingNode,
    $createQuoteNode as createQuoteNode,
    HeadingNode,
    QuoteNode,
  } from "@lexical/rich-text";
  import { update_journal_content, get_journal_content } from "../notes.svelte";
  import { $createMediaNode as createMediaNode, MediaNode, type MediaKind } from "../editor/media-nodes";
  import {
    Bold,
    Code,
    FileAudio,
    FileImage,
    FileVideo,
    Heading1,
    Heading2,
    Highlighter,
    Italic,
    Link,
    List,
    ListChecks,
    ListOrdered,
    LoaderCircle,
    AlignCenter,
    AlignLeft,
    AlignRight,
    Quote,
    Redo2,
    Table2,
    Strikethrough,
    Underline,
    Undo2,
    X,
  } from "@lucide/svelte";

  let { noteId, onStatus = () => {} } = $props<{
    noteId: number;
    onStatus?: (message: string) => void;
  }>();

  let editor_root: HTMLDivElement;
  let editor: LexicalEditor | undefined;
  let loading = $state(true);
  let saving = $state(false);
  let markdown_open = $state(false);
  let markdown_mode = $state<"import" | "export">("import");
  let markdown_value = $state("");
  let link_url = $state("");
  let link_open = $state(false);
  let file_input: HTMLInputElement;
  let save_timer: ReturnType<typeof setTimeout> | undefined;
  let cleanup: Array<() => void> = [];

  const theme = {
    paragraph: "editor-paragraph",
    quote: "editor-quote",
    heading: { h1: "editor-h1", h2: "editor-h2", h3: "editor-h3" },
    list: { nested: { listitem: "editor-nested-listitem" }, ol: "editor-list-ol", ul: "editor-list-ul", listitem: "editor-listitem", checklist: "editor-checklist" },
    text: { bold: "editor-bold", italic: "editor-italic", underline: "editor-underline", strikethrough: "editor-strikethrough", underlineStrikethrough: "editor-underline-strikethrough", code: "editor-inline-code" },
    code: "editor-code",
    link: "editor-link",
  };

  function build_editor(): LexicalEditor {
    return createEditor({
      namespace: "PensyJournal",
      theme,
      nodes: [
        HeadingNode,
        QuoteNode,
        ListNode,
        ListItemNode,
        LinkNode,
        AutoLinkNode,
        HashtagNode,
        CodeNode,
        TableNode,
        TableCellNode,
        TableRowNode,
        MediaNode,
      ],
      onError(error) {
        console.error(error);
        onStatus("Editor error");
      },
    });
  }

  function queue_save(current_editor: LexicalEditor) {
    if (save_timer) clearTimeout(save_timer);
    save_timer = setTimeout(async () => {
      saving = true;
      const result = await update_journal_content(noteId, JSON.stringify(current_editor.getEditorState().toJSON()));
      saving = false;
      if (result instanceof Error) onStatus(result.message);
      else onStatus("");
    }, 500);
  }

  async function load_content(current_editor: LexicalEditor) {
    loading = true;
    const stored = await get_journal_content(noteId);
    if (stored instanceof Error) {
      loading = false;
      onStatus(stored.message);
      return;
    }

    if (stored.trim()) {
      try {
        current_editor.setEditorState(current_editor.parseEditorState(stored));
      } catch {
        current_editor.update(() => convertFromMarkdownString(stored, TRANSFORMERS));
      }
    } else {
      current_editor.update(() => {
        const root = current_editor.getEditorState().read(() => null);
        void root;
      });
    }
    loading = false;
  }

  function format_text(format: TextFormatType) {
    editor?.dispatchCommand(FORMAT_TEXT_COMMAND, format);
  }

  function format_alignment(alignment: "left" | "center" | "right") {
    editor?.dispatchCommand(FORMAT_ELEMENT_COMMAND, alignment);
  }

  function set_block(type: "paragraph" | "h1" | "h2" | "quote" | "code") {
    editor?.update(() => {
      const selection = getSelection();
      if (!isRangeSelection(selection)) return;
      if (type === "h1" || type === "h2") {
        setBlocksType(selection, () => createHeadingNode(type));
      } else if (type === "quote") {
        setBlocksType(selection, () => createQuoteNode());
      } else if (type === "code") {
        setBlocksType(selection, () => createCodeNode());
      } else {
        setBlocksType(selection, () => new ParagraphNode());
      }
    });
  }

  function toggle_link() {
    const url = link_url.trim();
    editor?.dispatchCommand(TOGGLE_LINK_COMMAND, url || null);
    link_open = false;
    link_url = "";
  }

  function insert_table() {
    const columns = window.prompt("Columns", "3")?.trim();
    const rows = window.prompt("Rows", "3")?.trim();
    if (!columns || !rows || !/^\d+$/.test(columns) || !/^\d+$/.test(rows)) return;
    editor?.dispatchCommand(INSERT_TABLE_COMMAND, { columns, rows, includeHeaders: true });
  }

  function open_markdown(mode: "import" | "export") {
    markdown_mode = mode;
    markdown_value = mode === "export" && editor ? editor.getEditorState().read(() => convertToMarkdownString(TRANSFORMERS)) : "";
    markdown_open = true;
  }

  function apply_markdown() {
    if (!editor) return;
    if (markdown_mode === "import") {
      editor.update(() => convertFromMarkdownString(markdown_value, TRANSFORMERS));
    }
    markdown_open = false;
  }

  function choose_media(kind: MediaKind) {
    if (kind === "image") {
      file_input.accept = "image/*";
    } else if (kind === "video") {
      file_input.accept = "video/*";
    } else {
      file_input.accept = "audio/*";
    }
    file_input.dataset.kind = kind;
    file_input.click();
  }

  function handle_media_file(event: Event) {
    const input = event.currentTarget as HTMLInputElement;
    const file = input.files?.[0];
    const kind = input.dataset.kind as MediaKind | undefined;
    if (!file || !kind || !editor) return;
    const reader = new FileReader();
    reader.onload = () => {
      if (typeof reader.result !== "string") return;
      editor?.update(() => {
        const selection = getSelection();
        if (isRangeSelection(selection)) selection.insertNodes([createMediaNode(kind, reader.result as string, file.name)]);
      });
    };
    reader.readAsDataURL(file);
    input.value = "";
  }

  onMount(() => {
    editor = build_editor();
    editor.setRootElement(editor_root);
    cleanup = [
      registerRichText(editor),
      registerList(editor),
      registerHistory(editor, createEmptyHistoryState(), 300),
      registerMarkdownShortcuts(editor, TRANSFORMERS),
      registerAutoLink(editor, { matchers: [autoLinkUrlMatcher, autoLinkEmailMatcher], changeHandlers: [], excludeParents: [] }),
      registerTablePlugin(editor),
      editor.registerUpdateListener(({ editorState }) => {
        if (!loading && editor) queue_save(editor);
        void editorState;
      }),
    ];
    void load_content(editor);
    return () => {
      cleanup.forEach((dispose) => dispose());
      if (save_timer) clearTimeout(save_timer);
      editor?.setRootElement(null);
    };
  });

  onDestroy(() => {
    cleanup.forEach((dispose) => dispose());
    if (save_timer) clearTimeout(save_timer);
  });
</script>

<div class="journal-editor-shell">
  <div class="journal-toolbar" aria-label="Journal editing tools">
    <div class="toolbar-group">
      <button class="toolbar-button" aria-label="Undo" title="Undo" onclick={() => editor?.dispatchCommand(UNDO_COMMAND, undefined)}><Undo2 size="16" /></button>
      <button class="toolbar-button" aria-label="Redo" title="Redo" onclick={() => editor?.dispatchCommand(REDO_COMMAND, undefined)}><Redo2 size="16" /></button>
    </div>
    <span class="toolbar-divider"></span>
    <div class="toolbar-group">
      <button class="toolbar-button" aria-label="Heading 1" title="Heading 1" onclick={() => set_block("h1")}><Heading1 size="16" /></button>
      <button class="toolbar-button" aria-label="Heading 2" title="Heading 2" onclick={() => set_block("h2")}><Heading2 size="16" /></button>
      <button class="toolbar-button" aria-label="Quote" title="Quote" onclick={() => set_block("quote")}><Quote size="16" /></button>
      <button class="toolbar-button" aria-label="Code block" title="Code block" onclick={() => set_block("code")}><Code size="16" /></button>
    </div>
    <span class="toolbar-divider"></span>
    <div class="toolbar-group">
      <button class="toolbar-button" aria-label="Bold" title="Bold" onclick={() => format_text("bold")}><Bold size="16" /></button>
      <button class="toolbar-button" aria-label="Italic" title="Italic" onclick={() => format_text("italic")}><Italic size="16" /></button>
      <button class="toolbar-button" aria-label="Underline" title="Underline" onclick={() => format_text("underline")}><Underline size="16" /></button>
      <button class="toolbar-button" aria-label="Strikethrough" title="Strikethrough" onclick={() => format_text("strikethrough")}><Strikethrough size="16" /></button>
      <button class="toolbar-button" aria-label="Inline code" title="Inline code" onclick={() => format_text("code")}><Code size="16" /></button>
      <button class="toolbar-button" aria-label="Highlight" title="Highlight" onclick={() => format_text("highlight")}><Highlighter size="16" /></button>
    </div>
    <span class="toolbar-divider"></span>
    <div class="toolbar-group">
      <button class="toolbar-button" aria-label="Bulleted list" title="Bulleted list" onclick={() => editor?.dispatchCommand(INSERT_UNORDERED_LIST_COMMAND, undefined)}><List size="16" /></button>
      <button class="toolbar-button" aria-label="Numbered list" title="Numbered list" onclick={() => editor?.dispatchCommand(INSERT_ORDERED_LIST_COMMAND, undefined)}><ListOrdered size="16" /></button>
      <button class="toolbar-button" aria-label="Checklist" title="Checklist" onclick={() => editor?.dispatchCommand(INSERT_CHECK_LIST_COMMAND, undefined)}><ListChecks size="16" /></button>
      <button class="toolbar-button" aria-label="Indent" title="Indent" onclick={() => editor?.dispatchCommand(INDENT_CONTENT_COMMAND, undefined)}>›</button>
      <button class="toolbar-button" aria-label="Outdent" title="Outdent" onclick={() => editor?.dispatchCommand(OUTDENT_CONTENT_COMMAND, undefined)}>‹</button>
      <button class="toolbar-button" aria-label="Insert table" title="Insert table" onclick={insert_table}><Table2 size="16" /></button>
    </div>
    <span class="toolbar-divider"></span>
    <div class="toolbar-group">
      <button class="toolbar-button" aria-label="Insert link" title="Insert link" onclick={() => (link_open = true)}><Link size="16" /></button>
      <button class="toolbar-button" aria-label="Insert image" title="Insert image" onclick={() => choose_media("image")}><FileImage size="16" /></button>
      <button class="toolbar-button" aria-label="Insert video" title="Insert video" onclick={() => choose_media("video")}><FileVideo size="16" /></button>
      <button class="toolbar-button" aria-label="Insert audio" title="Insert audio" onclick={() => choose_media("audio")}><FileAudio size="16" /></button>
    </div>
    <span class="toolbar-divider"></span>
    <div class="toolbar-group">
      <button class="toolbar-button" aria-label="Align left" title="Align left" onclick={() => format_alignment("left")}><AlignLeft size="16" /></button>
      <button class="toolbar-button" aria-label="Align center" title="Align center" onclick={() => format_alignment("center")}><AlignCenter size="16" /></button>
      <button class="toolbar-button" aria-label="Align right" title="Align right" onclick={() => format_alignment("right")}><AlignRight size="16" /></button>
    </div>
    <span class="toolbar-divider"></span>
    <div class="toolbar-group">
      <button class="toolbar-text-button" onclick={() => open_markdown("import")}>Markdown in</button>
      <button class="toolbar-text-button" onclick={() => open_markdown("export")}>Markdown out</button>
    </div>
    <span class="toolbar-spacer"></span>
    {#if saving}<LoaderCircle class="toolbar-spinner" size="14" />{:else}<span class="toolbar-saved">Saved</span>{/if}
  </div>

  <slot name="title"></slot>

  <div class="journal-editor-wrap">
    {#if loading}<div class="editor-loading">Loading note…</div>{/if}
    <div class="journal-editor" class:is-loading={loading} bind:this={editor_root} contenteditable="true" role="textbox" aria-label="Journal note content" spellcheck="true"></div>
    <input class="hidden-file-input" bind:this={file_input} type="file" onchange={handle_media_file} />
  </div>
</div>

{#if link_open}
  <div class="editor-popover-backdrop" role="presentation" onclick={() => (link_open = false)}>
    <form class="editor-popover" onclick={(event) => event.stopPropagation()} onsubmit={(event) => { event.preventDefault(); toggle_link(); }}>
      <label for="link-url">Link URL</label>
      <input id="link-url" bind:value={link_url} placeholder="https://example.com" autofocus />
      <div class="popover-actions"><button type="button" onclick={() => (link_open = false)}>Cancel</button><button type="submit">Apply</button></div>
    </form>
  </div>
{/if}

{#if markdown_open}
  <div class="editor-popover-backdrop" role="presentation" onclick={() => (markdown_open = false)}>
    <form class="editor-popover markdown-popover" onclick={(event) => event.stopPropagation()} onsubmit={(event) => { event.preventDefault(); apply_markdown(); }}>
      <div class="popover-heading"><strong>{markdown_mode === "import" ? "Import Markdown" : "Markdown"}</strong><button type="button" aria-label="Close" onclick={() => (markdown_open = false)}><X size="15" /></button></div>
      <textarea bind:value={markdown_value} readonly={markdown_mode === "export"} spellcheck="false"></textarea>
      <div class="popover-actions"><button type="button" onclick={() => (markdown_open = false)}>Cancel</button>{#if markdown_mode === "import"}<button type="submit">Import</button>{/if}</div>
    </form>
  </div>
{/if}
