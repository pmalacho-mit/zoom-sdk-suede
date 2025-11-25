/* eslint-disable no-restricted-globals */
import React from "react";
import type { VideoClient } from "@zoom/videosdk";
import App, { type AppProps } from "./App.modified";
import ZoomContext from "./context/zoom-context";

export type Props = AppProps & { zoomClient: typeof VideoClient };

export const Wrapper = ({ zoomClient, ...props }: Props) => {
  return (
    <React.StrictMode>
      <ZoomContext.Provider value={zoomClient}>
        <App {...props} />
      </ZoomContext.Provider>
    </React.StrictMode>
  );
};
