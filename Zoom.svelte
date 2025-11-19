<script lang="ts" module>
  import type { Props as WrapperProps } from "./index.modified";

  export type Props = WrapperProps;
</script>

<script lang="ts">
  import { sveltify } from "svelte-preprocess-react";
  import { Wrapper } from "./index.modified";

  let props: Props = $props();

  const react = sveltify({ Wrapper }); // Optional step, but adds type-safety
</script>

<react.Wrapper {...props} />
