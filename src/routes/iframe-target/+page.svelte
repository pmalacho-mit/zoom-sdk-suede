<script lang="ts">
  import Zoom from "$dist/Zoom.svelte";

  let urlParams = new URLSearchParams(window.location.search);

  const name =
    urlParams.get("name") ||
    `User_${Math.random().toString(36).substring(2, 8)}_${navigator.userAgent}`;
  const topic = urlParams.get("topic") || "Iframe Target Test";
  const signature = urlParams.get("signature") || "";
</script>

<Zoom meetingArgs={{ name, topic, signature }} />
