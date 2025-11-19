<script lang="ts">
  import { generateVideoToken } from "$dist/utils/util";
  import Zoom from "$dist/Zoom.svelte";
  // make sure to create a file named credentials.ts with the following content:
  // `export const sdk = { key: "...", secret: "..." }`
  import { sdk } from "./credentials";
  let name = $state(
    `User_${Math.random().toString(36).substring(2, 8)}_${navigator.userAgent}`
  );
  let topic = $state("Local Credentials Test");
  const signature = $derived(generateVideoToken(sdk.key, sdk.secret, topic));
</script>

<div>
  Name: {name}
</div>

<Zoom meetingArgs={{ name, topic, signature }} />
