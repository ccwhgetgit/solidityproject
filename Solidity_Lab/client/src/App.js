import logo from './logo.svg';
import './App.css';
import {simpleStorageAbi} from './abis/abis';
import Web3 from 'web3';
import React, {useState} from 'react';

const web3 = new Web3(Web3.givenProvider);
const contractAddr = '0xDc6A7fd950846b3796E0Dc16f4A297BD0ee4f405';
const SimpleContract = new web3.eth.Contract(simpleStorageAbi, contractAddr);

function App() {
  const [exchange, setExchange] = useState(0);
  const [getNumber, setGetNumber] = useState('0x00');
  const [luckyNumber, setLucky] = useState(10);
  const [betAmt, setBet] = useState(0);

  const state = {
    manager: '0x8Cc6C428195F06148cf3cFfd52D5eADe82C43aa8',
    players: [],
    balance: '',
    value: '',
    message: '...'
  };

  const handleGet = async (e) => {
    e.preventDefault();
    const result = await SimpleContract.methods.get().call();
    setGetNumber(result);
    console.log(result);
  }

  const convertEtherToToken = async (e) => {
    e.preventDefault();
    try{
      const accounts = await window.ethereum.enable();
      const account = accounts[0];
      const gas = await SimpleContract.methods.EthertoToken().estimateGas();
      const result = await SimpleContract.methods.EthertoToken().send({
        from: account,
        gas 
    })
      console.log(result);
    } catch(error){
      console.log(error);
    }    
  }

  const convertTokenToEther = async (e) => {
    e.preventDefault();
    try{
      const accounts = await window.ethereum.enable();
      const account = accounts[0];
      const gas = await SimpleContract.methods.set(exchange).estimateGas();
      const result = await SimpleContract.methods.set(exchange).send({
        from: account,
        gas 
    })
      console.log(result);
    } catch(error){
      console.log(error);
    }    
  }

  const placeBet = async (e) => {
    e.preventDefault();
    try{
      const accounts = await window.ethereum.enable();
      const account = accounts[0];
      const gas = await SimpleContract.methods.set(exchange).estimateGas();
      const result = await SimpleContract.methods.set(exchange).send({
        from: account,
        gas 
    })
      console.log(result);
    } catch(error){
      console.log(error);
    }    
  }

  const getOwner = async (e) => {
    e.preventDefault();
    const result = await SimpleContract.
    setGetNumber(result);
    console.log(result);
  }

  // return (
  //   <div className="App">
  //     <header className="App-header">
  //       <form onSubmit={handleSet}>
  //         <label>
  //           Set Number:
  //           <input 
  //             type="text"
  //             name="name"
  //             value={number}
  //             onChange={ e => setNumber(e.target.value) } />
  //         </label>
  //         <input type="submit" value="Set Number" />
  //       </form>
  //       <br/>
  //       <button
  //         onClick={handleGet}
  //         type="button" > 
  //         Get Number 
  //       </button>
  //       { getNumber }
  //     </header>
  //   </div>  
  // );
  return(
    <div className ="App">
      <header>Lottery Game</header>
      <p>
        This room is owned by {state.manager}. <br /> Current Room Load: {state.players.length} <br />
      </p>
      <p>Lucky number for the game: {luckyNumber}</p>
      <form onSubmit = {convertEtherToToken}>
      <label>Enter Ether Amount to token: </label>
      <input 
        type="text"
        name="etherToToken"
        value={exchange} 
        onChange={ e => setExchange(e.target.value) }/>
        <input type = "submit" value = "Convert"/></form>
      <p>
      <form onSubmit = {convertTokenToEther}>
      <label>Enter token to Ether: </label>
      <input 
        type="text"
        name="name"
        value={exchange} 
        onChange={ e => setExchange(e.target.value) }/>
        <input type = "submit" value = "Convert"/></form></p>
      <form onSubmit = {placeBet}>
      <p>Please key in your Bet amount:  
      <input 
        type="text"
        name="name"
        value={betAmt} 
        onChange={ e => setBet(e.target.value) }/>
      </p>
      <p>Please key in your lucky number 
      <input 
        type="text"
        name="name"
        value={luckyNumber} 
        onChange={ e => setLucky(e.target.value) }/>
        <input type = "submit" value = "Place bet"/>
      </p></form>
      <button>Gameplay</button>
      <p><button>Close Room</button></p>
    </div>
  )
}

export default App;
