import React from "react";
import { drizzleReactHooks } from "@drizzle/react-plugin";
import { Drizzle } from "@drizzle/store";
import drizzleOptions from "./drizzleOptions";
import LoadingContainer from './LoadingContainer.js'
import MyComponent from "./MyComponent.js";

import "./App.css";

const drizzle = new Drizzle(drizzleOptions);
const {DrizzleProvider} = drizzleReactHooks; 
const App = () => {
  return (
  <DrizzleProvider drizzle = {drizzle}>
    <LoadingContainer>
      <MyComponent>

      </MyComponent>
  

    </LoadingContainer>
  </DrizzleProvider>

  );
}

export default App;
