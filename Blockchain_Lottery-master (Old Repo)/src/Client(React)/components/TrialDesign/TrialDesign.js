import React, { useState, useEffect, useCallback } from 'react';

import {Route, withRouuter} from 'react-router-dom';
import { useWeb3 } from '@openzeppelin/network/react';

import './App.css';
import dice from './images/dice.gif';
import money from './images/money.gif';

const infuraProjectId = '95202223388e49f48b423ea50a70e336';


const TrialDesign = () => {
  const web3Context = useWeb3(`wss://mainnet.infura.io/ws/v3/${infuraProjectId}`);
  const { networkId, networkName, accounts, providerName, lib } = web3Context;
  const requestAuth = async web3Context => {
    try {
      await web3Context.requestAuth();
    } catch (e) {
      console.error(e);
    }
  };

  const requestAccess = useCallback(() => requestAuth(web3Context), []);
  
  const [balance, setBalance] = useState(0);

  const getBalance = useCallback(async () => {
    let balance =
      accounts && accounts.length > 0 ? lib.utils.fromWei(await lib.eth.getBalance(accounts[0]), 'ether') : 'Unknown';
    setBalance(balance);
  }, [accounts, lib.eth, lib.utils]);

  useEffect(() => {
    getBalance();
  }, [accounts, getBalance, networkId]);


  const message = () => {
    alert("Go to www.metamask.com") 
   }

   
    return  <div className="App">
    <header className="App-header">
      <box className = "row"> 
      <img alt="dice" className="dice" src={money} />
      <img alt="dice" className="dice" src={dice} />
     
      <img alt="dice" className="dice" src={money} />
      </box>
   
     
      <p1>

       Welcome to Casino Royale
      </p1> 
      
      <a
        className="App-link"
        href="https://reactjs.org"
       
      >
          Metamask
        </a>
        
        
      </header>

      <div  className="spacecontainer"> </div>
    
     
      <div  className="containerprofile">

{/* insert image of profile account */}

      
    {accounts && accounts.length ? (
        <div>


  
       <div>Your address: {accounts && accounts.length ? accounts[0] : 'Unknown'}</div>
      <div>Your ETH balance: {balance}</div>
     

        </div>
      ) : !!networkId && providerName !== 'infura' ? ( 
       
       <div>
      Cant see any account details? Login to metamask!



        </div>
      ) : (
        <div></div>
      )}
</div>


  </div>

  
  }

export default TrialDesign; 