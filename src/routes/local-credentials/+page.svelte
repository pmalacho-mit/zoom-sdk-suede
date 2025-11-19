<script lang="ts">
  import { generateVideoToken } from "$dist/utils/util";
  import Zoom from "$dist/Zoom.svelte";
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
