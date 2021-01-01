import React, { useState, useEffect, useCallback } from 'react';
import { useWeb3 } from '@openzeppelin/network/react';
import Avatar from '@material-ui/core/Avatar';
import gambler from './images/gambler.jpg';
import { makeStyles } from '@material-ui/core/styles';
import './App.css';
import dice from './images/dice.gif';
import money from './images/money.gif';


const infuraProjectId = '95202223388e49f48b423ea50a70e336';

const useStyles = makeStyles((theme) => ({

  large: {
    width: theme.spacing(18),
    height: theme.spacing(18),
    
  },
}));

const Account = () => {
  const web3Context = useWeb3(`wss://mainnet.infura.io/ws/v3/${infuraProjectId}`);
  const { networkId, accounts, providerName, lib } = web3Context;
  const requestAuth = async web3Context => {
    try {
      await web3Context.requestAuth();
    } catch (e) {
      console.error(e);
    }
  };

  const [balance, setBalance] = useState(0);

  const getBalance = useCallback(async () => {
    let balance =
      accounts && accounts.length > 0 ? lib.utils.fromWei(await lib.eth.getBalance(accounts[0]), 'ether') : 'Unknown';
    setBalance(balance);
  }, [accounts, lib.eth, lib.utils]);

  useEffect(() => {
    getBalance();
  }, [accounts, getBalance, networkId]);

  const classes = useStyles();


   
    return  <div className="App">
   <header className="App-header">
      <box className = "row"> 
      <img alt="dice" className="dice" src={money} />
      <img alt="dice" className="dice" src={dice} />
      <img alt="dice" className="dice" src={money} />
      </box>
   
     
      <p1>

       Your Account
      </p1> 
      
      
      </header>
      <div  className="spacecontainer"> </div>
    
    
    {accounts && accounts.length ? (
        <div  className="overall">
       <div  className="containerprofile">
       
       <div  className="spacecontainer"> </div>

<Avatar alt="containerprofile-dice" className={classes.large} src={gambler}  />
  
  <div  className="spacecontainer"> </div>
      
  <div  className="infocontainer"> 
     
      <b>The Wallet Address used is</b> <br></br><br></br>
      
      { accounts[0] }
     
      <br></br>  

      <div  className="sidenote"> 
     
     <i> **You will be unknown to others.  </i>
      </div>
      
      <br></br>
      <br></br>
     <b>Balance (Eth) :</b> {balance} 
     
     </div>
     </div>
     <br></br>

     <div  className="gamecontainer"> 
Number of Games played: 
     </div>
     <div  className="gamecontainer"> 
Number of Games played: 
     </div>
        </div>
        
      ) : !!networkId && providerName !== 'infura' ? ( 
       
       <div>
      Cant see any account details? Login to metamask!



        </div>
      ) : (
        <div>   fekf</div>
      )}
</div>




  
  }

export default Account; 