import React, { useState, useEffect, useCallback } from 'react';
import { useWeb3 } from '@openzeppelin/network/react';


const infuraProjectId = '95202223388e49f48b423ea50a70e336';

function App1(props) {
  const web3Context = useWeb3(`wss://mainnet.infura.io/ws/v3/${infuraProjectId}`);
  const { networkId,  accounts, providerName, lib } = web3Context;
  
  
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
      <h3> Welcome to Casino Royale! </h3>
       Don't see the log in button? Ensure your browser has metamask
        
         <br></br>
         <br></br>
        Click here to try out 
        <br></br>
         <br></br>
         <button onClick={message}> What is Metamask? </button>
         <br></br>
         <br></br>
    
      {accounts && accounts.length ? (
        <div>  {/* what happens if user successfully logins */}

    Let's make money together 
       <div>Your address: {accounts && accounts.length ? accounts[0] : 'Unknown'}</div>
      <div>Your ETH balance: {balance}</div>
      <button 
 onClick={() => {
  
         props.history.push("/game");
    
    }}
    >
       Let's gamble 
    </button>

        </div>
      ) : !!networkId && providerName !== 'infura' ? ( 
       
       <div>
        
       
        </div>
      ) : (
        <div></div>
      )}
    </div>
  );
}
export default App1;