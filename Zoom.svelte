<script lang="ts" module>
  import type { Props as WrapperProps } from "./index.modified";

  export type Props = WrapperProps;

  const findToolbarContainer = async (element: Element) => {
    let footer: Element | null | undefined = null;
    while (!footer) {
      footer = element.closest("div")?.querySelector(".video-footer");
      await new Promise((r) => setTimeout(r, 100));
    }
    return footer;
  };

  export type Controls = {
    microphone: boolean;
    video: boolean;
    recording: boolean;
    screenShare: boolean;
    liveTranscription: boolean;
    liveBroadcast: boolean;
  };

  const identifyController = ({
    classList,
    id,
  }: Element): keyof Controls | undefined => {
    if (!classList.contains("video-tool")) return undefined;
    if (id === "microphone-button") return "microphone";
    else if (id === "camera-button") return "video";
    else if (id === "transcription-button") return "liveTranscription";
    else if (id === "live-broadcast-button") return "liveBroadcast";
    else if (id === "screen-share-button") return "screenShare";
    else if (id.startsWith("recording-button")) {
      if (id.endsWith("record")) return "recording";
      else if (id.endsWith("resume")) return "recording";
      else if (id.endsWith("pause")) return "recording";
      else if (id.endsWith("stop")) return "recording";
      else if (id.endsWith("status")) return "recording";
    }
    throw new Error(`Unknown toolbar child with id: ${id}`);
  };

  const createControlsMapping = (footer: Element) => {
    const mapping: Partial<Record<keyof Controls, Element | Element[]>> = {};
    Array.from(footer.children).forEach((child) => {
      const type = identifyController(child);
      if (type) {
        if (mapping[type]) {
          Array.isArray(mapping[type])
            ? mapping[type].push(child)
            : (mapping[type] = [mapping[type] as Element, child]);
        } else mapping[type] = child;
      }
    });
    return mapping;
  };

  const supportControl = (child: Element, condition: boolean) =>
    condition
      ? child.classList.add("supported")
      : child.classList.remove("supported");

  const supportControls = (childs: Element | Element[], condition: boolean) =>
    Array.isArray(childs)
      ? childs.forEach((child) => supportControl(child, condition))
      : supportControl(childs, condition);

  const conditionallySupportControl = (child: Element, controls?: Controls) => {
    const type = identifyController(child);
    if (!type) return;
    if (!controls || controls[type]) supportControl(child, true);
    else supportControl(child, false);
  };

  const controlAddedToFooterEffect = (footer: Element, controls?: Controls) => {
    const observer = new MutationObserver((mutations) => {
      for (const mutation of mutations)
        if (mutation.type === "childList")
          Array.from(mutation.addedNodes)
            .filter((node) => node instanceof Element)
            .forEach((element) =>
              conditionallySupportControl(element, controls)
            );
    });
    observer.observe(footer, { childList: true });
    return () => observer.disconnect();
  };
</script>

<script lang="ts">
  import { sveltify } from "svelte-preprocess-react";
  import { Wrapper } from "./index.modified";
  import ZoomVideo from "@zoom/videosdk";

  let {
    controls,
    ...props
  }: Omit<Props, "zoomClient"> & {
    controls?: Controls;
  } = $props();

  const client = ZoomVideo.createClient();

  let container = $state<Element | null>(null);

  let videoFooter = $state<Element | null>(null);

  $effect(() => {
    if (!videoFooter) return;
    const mapping = createControlsMapping(videoFooter);
    const controlsSpecified = controls !== undefined;
    Object.values(mapping).forEach((element) =>
      supportControls(element, !controlsSpecified)
    );
    for (const key in controls) {
      const control = key as keyof Controls;
      let elements = mapping ? mapping[control] : undefined;
      if (elements)
        supportControls(elements, controls ? controls[control] : true);
    }
  });

  $effect(() => {
    if (!videoFooter) return;
    return controlAddedToFooterEffect(videoFooter!, controls);
  });

  client.on("connection-change", async (payload) => {
    if (payload.state === "Connected") {
      videoFooter = await findToolbarContainer(container!);
    }
  });

  const react = sveltify({ Wrapper }); // Optional step, but adds type-safety
</script>

<div
  bind:this={container}
  style:--video-display={controls ? (controls.video ? "flex" : "none") : "flex"}
>
  <react.Wrapper {...props} zoomClient={client} />
</div>

<style>
  div {
    width: 100%;
    height: 100%;
  }

  :global(div .App) {
    position: relative;
    overflow: hidden;
    width: 100% !important;
    height: 100% !important;
  }

  :global(div .viewport) {
    width: 100% !important;
    height: 100% !important;
    overflow: hidden;
  }

  :global(div .loading-layer) {
    position: absolute !important;
    top: auto !important;
    left: auto !important;
    bottom: auto !important;
    right: auto !important;
    width: 100% !important;
    height: 100% !important;
  }

  :global(div .video-footer > .video-tool) {
    transition: opacity 0.5s;
  }

  :global(div .video-footer > .video-tool:not(.supported)) {
    display: none !important;
    opacity: 0 !important;
  }

  :global(div .video-footer > .video-tool.supported) {
    display: inline-flex !important;
    opacity: 1 !important;
  }

  :global(div .avatar) {
    display: var(--video-display);
  }

  :global(div video-player, div video-player-container) {
    display: var(--video-display) !important;
  }
</style>
