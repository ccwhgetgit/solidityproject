import { useWeb3 } from '@openzeppelin/network/react';
import React, { useState, useEffect, useCallback } from 'react';


const infuraProjectId = '95202223388e49f48b423ea50a70e336';


function Game() {
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

    return (

      <div>
        <form>
          <h1>navigate to a new page with everything else</h1>
          <p>Enter your name:</p>
          <input
            type="text"
          />
        </form>

        <div>Your address: {accounts && accounts.length ? accounts[0] : 'Unknown'}</div>
      <div>Your ETH balance: {balance}</div>

        </div>
      );
}

export default Game;