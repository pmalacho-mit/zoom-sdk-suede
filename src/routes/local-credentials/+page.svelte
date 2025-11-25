<script lang="ts">
  // make sure to create a file named credentials.ts with the following content:
  // `export const sdk = { key: "...", secret: "..." }`
  import { sdk } from "./credentials";
  import { generateVideoToken } from "$dist/utils/util";
  import Zoom, { type Controls, type ZoomClient } from "$dist/Zoom.svelte";

  let name = $state(
    `User_${Math.random().toString(36).substring(2, 8)}_${navigator.userAgent}`
  );
  let topic = $state("Local Credentials Test");
  const signature = $derived(generateVideoToken(sdk.key, sdk.secret, topic));

  type Control = keyof Controls;
  let settings = $state<Control[]>([]);
  const options: Control[] = [
    "liveBroadcast",
    "liveTranscription",
    "microphone",
    "video",
    "recording",
    "screenShare",
  ];
  const controls = $derived(
    settings.reduce((acc, curr) => ({ ...acc, [curr]: true }), {} as Controls)
  );

  const viewport = $state({ color: "#222222", useColor: true });
  const buttons = $state({
    color: "#444444",
    useColor: true,
    activeColor: "#666666",
    useActiveColor: true,
  });

  let joined = $state(false);
  let client = $state<ZoomClient>();
</script>

<div
  style:height="100vh"
  style:width="100vw"
  style:display="flex"
  style:flex-direction="column"
  style:align-items="center"
  style:justify-content="flex-start"
  style:gap="20px"
>
  <div
    style:display="flex"
    style:flex-direction="row"
    style:flex-wrap="wrap"
    style:gap="10px"
  >
    <select
      name="cars"
      id="cars"
      multiple
      bind:value={settings}
      size={options.length}
    >
      {#each options as control}
        <option value={control}>{control}</option>
      {/each}
    </select>
    <label
      style:border="1px solid black"
      style:padding="5px"
      style:margin="5px"
    >
      <input type="checkbox" bind:checked={viewport.useColor} />
      Viewport Color:
      <input type="color" bind:value={viewport.color} />
    </label>
    <label
      style:border="1px solid black"
      style:padding="5px"
      style:margin="5px"
    >
      <input type="checkbox" bind:checked={buttons.useColor} />
      Buttons Color:
      <input type="color" bind:value={buttons.color} />
    </label>
    <label
      style:border="1px solid black"
      style:padding="5px"
      style:margin="5px"
    >
      <input type="checkbox" bind:checked={buttons.useActiveColor} />

      Buttons Active Color:
      <input type="color" bind:value={buttons.activeColor} />
    </label>
  </div>
  {#if !joined}
    <center>
      <label>Meeting topic: <input bind:value={topic} /></label>
      <label>Name: <input bind:value={name} /></label>
      <button onclick={() => (joined = true)}> Join Meeting </button>
    </center>
  {/if}
  <div style:height="15%" style:width="75%">
    {#if joined}
      <Zoom
        bind:client
        meetingArgs={{ name, topic, signature }}
        {controls}
        viewport={{ color: viewport.useColor ? viewport.color : undefined }}
        buttons={{
          color: buttons.useColor ? buttons.color : undefined,
          activeColor: buttons.useActiveColor ? buttons.activeColor : undefined,
        }}
      />
    {/if}
  </div>
</div>
