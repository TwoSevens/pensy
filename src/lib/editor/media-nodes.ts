import {
    DecoratorNode,
    type EditorConfig,
    type LexicalEditor,
    type LexicalNode,
    type NodeKey,
    type SerializedLexicalNode,
} from "lexical";

export type MediaKind = "image" | "video" | "audio";

type SerializedMediaNode = SerializedLexicalNode & {
    kind: MediaKind;
    src: string;
    altText: string;
};

export class MediaNode extends DecoratorNode<null> {
    __kind: MediaKind;
    __src: string;
    __altText: string;

    static getType(): string {
        return "media";
    }

    static clone(node: MediaNode): MediaNode {
        return new MediaNode(node.__kind, node.__src, node.__altText, node.__key);
    }

    constructor(kind: MediaKind, src: string, altText = "", key?: NodeKey) {
        super(key);
        this.__kind = kind;
        this.__src = src;
        this.__altText = altText;
    }

    createDOM(_config: EditorConfig, _editor: LexicalEditor): HTMLElement {
        const wrapper = document.createElement("figure");
        wrapper.className = `lexical-media lexical-media-${this.__kind}`;
        if (this.__kind === "image") {
            const image = document.createElement("img");
            image.src = this.__src;
            image.alt = this.__altText;
            image.loading = "lazy";
            wrapper.appendChild(image);
        } else {
            const media = document.createElement(this.__kind) as HTMLVideoElement | HTMLAudioElement;
            media.src = this.__src;
            media.controls = true;
            wrapper.appendChild(media);
        }
        return wrapper;
    }

    updateDOM(prevNode: MediaNode, dom: HTMLElement): boolean {
        if (prevNode.__kind !== this.__kind) return true;
        const element = dom.firstElementChild as HTMLImageElement | HTMLVideoElement | HTMLAudioElement | null;
        if (!element) return true;
        if (prevNode.__src !== this.__src) element.src = this.__src;
        if (this.__kind === "image" && prevNode.__altText !== this.__altText) {
            (element as HTMLImageElement).alt = this.__altText;
        }
        return false;
    }

    decorate(): null {
        return null;
    }

    isInline(): boolean {
        return false;
    }

    getTextContent(): string {
        return this.__altText || `[${this.__kind}]`;
    }

    exportJSON(): SerializedMediaNode {
        return {
            type: "media",
            version: 1,
            kind: this.__kind,
            src: this.__src,
            altText: this.__altText,
        };
    }

    static importJSON(serializedNode: SerializedMediaNode): MediaNode {
        return new MediaNode(serializedNode.kind, serializedNode.src, serializedNode.altText);
    }
}

export function $createMediaNode(kind: MediaKind, src: string, altText = ""): MediaNode {
    return new MediaNode(kind, src, altText);
}

export function $isMediaNode(node: LexicalNode | null | undefined): node is MediaNode {
    return node instanceof MediaNode;
}
