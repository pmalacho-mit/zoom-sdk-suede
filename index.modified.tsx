/* eslint-disable no-restricted-globals */
import React from "react";
import ZoomVideo from "@zoom/videosdk";
import "./index.css";
import App, { type AppProps } from "./App.modified";
import ZoomContext from "./context/zoom-context";

const zmClient = ZoomVideo.createClient();

export type Props = AppProps;

export const Wrapper = (props: Props) => {
  return (
    <React.StrictMode>
      <ZoomContext.Provider value={zmClient}>
        <App {...props} />
      </ZoomContext.Provider>
    </React.StrictMode>
  );
};
