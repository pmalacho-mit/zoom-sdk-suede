<script lang="ts">
  // make sure to create a file named credentials.ts with the following content:
  // `export const sdk = { key: "...", secret: "..." }`
  import { sdk } from "./credentials";
  import { generateVideoToken } from "$dist/utils/util";
  import Zoom, { type Controls } from "$dist/Zoom.svelte";

  let name = $state(
    `User_${Math.random().toString(36).substring(2, 8)}_${navigator.userAgent}`
  );
  let topic = $state("Local Credentials Test");
  const signature = $derived(generateVideoToken(sdk.key, sdk.secret, topic));

  let settings = $state<(keyof Controls)[]>([]);
  const controls = $derived(
    settings.reduce((acc, curr) => ({ ...acc, [curr]: true }), {} as Controls)
  );

  $inspect(controls);
</script>

<center style:height="100vh" style:width="100vw">
  <select name="cars" id="cars" multiple bind:value={settings}>
    {#each ["liveBroadcast", "liveTranscription", "microphone", "video", "recording", "screenShare"] satisfies (keyof Controls)[] as control}
      <option value={control}>{control}</option>
    {/each}
  </select>
  <div style:height="15%" style:width="75%">
    <Zoom meetingArgs={{ name, topic, signature }} {controls} />
  </div>
</center>
