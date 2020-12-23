import React from "react";
import { newContextComponents } from "@drizzle/react-components";
import logo from "./logo.png";
import {drizzleReactHooks} from "@drizzle/react-plugin";

const {useDrizzle, useDrizzleState} = drizzleReactHooks;
const {AccountData, ContractData, ContractForm}  = newContextComponents; 


export default () => {
  // destructure drizzle and drizzleState from props
  const {drizzle } = useDrizzle(); 
  const state = useDrizzleState (state => state); 
  return (
    <div className="App">
      <div>
       
        <h1>Drizzle Examples</h1>
        
      </div>
      <AccountData
      drizzle = {drizzle}
      drizzleState = {state} 
      accounts = {state.accounts}
      accountIndex = {0}
      />

      <ContractData 
      drizzle = {drizzle}
      drizzleState = {state}
      contract = "SimpleStorage"
      method = "storedData"
     
      />

      <ContractForm
drizzle = {drizzle}
contract = "SimpleStorage"
method = "set"
      />

    </div>
  );
};
