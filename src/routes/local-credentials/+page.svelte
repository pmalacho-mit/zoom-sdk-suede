<script lang="ts">
  // make sure to create a file named credentials.ts with the following content:
  // `export const sdk = { key: "...", secret: "..." }`
  import { sdk } from "./credentials";
  import { generateVideoToken } from "$dist/utils/util";
  import Zoom from "$dist/Zoom.svelte";

  let name = $state(
    `User_${Math.random().toString(36).substring(2, 8)}_${navigator.userAgent}`
  );
  let topic = $state("Local Credentials Test");
  const signature = $derived(generateVideoToken(sdk.key, sdk.secret, topic));
</script>

<center>
  <iframe
    style:height="75%"
    style:width="75%"
    title="using zoom component in iframe"
    src={`/iframe-target?name=${encodeURIComponent(name)}&topic=${encodeURIComponent(topic)}&signature=${encodeURIComponent(signature)}`}
  >
  </iframe>
</center>
