import React, { Component } from 'react';
import {useState} from 'react'
import './App.css';
import web3 from './web3';
import lottery from './lottery';
import Button from '@material-ui/core/Button';


class App extends React.Component {
  state = {
    manager: '',
    players: [],
    balance: '',
    value: '',
    message: 'Welcome to Holly Rolly Polly!',
    loading: false,
    pageLoading: true,
    standardBet: '',
    account: '',
    guess: 0
  };
  async componentDidMount() {
   
    const players = await lottery.methods.getPlayers().call();
    const balance = await web3.eth.getBalance(lottery.options.address);
    const accounts = await web3.eth.getAccounts();
    this.setState({  players, balance });
    this.setState({ account: accounts[0] })
    web3.eth.subscribe('newBlockHeaders', function (err, result) {
      if(err) {
        console.log(err);
      }
    });

    this.setState({pageLoading: false})
  }

  onSubmit = async event => {
    event.preventDefault();

    if (this.state.value < 1) {
      this.setState({ message: 'You need a minimum of 1 ether to bet.' });
      return;
    }
    const accounts = await web3.eth.getAccounts();

    this.setState({ loading: true });
    this.setState({
      message: 'This may take up to a minute. Waiting on transaction success...'
    });

    await lottery.methods.enter().send({
      from: accounts[0],
      value: web3.utils.toWei(this.state.value, 'ether')
    });

    this.setState({ message: 'Entry Recorded!'});
    this.setState({ value: '' });

   
    const players = await lottery.methods.getPlayers().call();
    const balance = await web3.eth.getBalance(lottery.options.address);

    this.setState({ players, balance });
    this.setState({ loading: false });
  };

  onClick = async () => {
    const accounts = await web3.eth.getAccounts();

    this.setState({ loading: true });
    this.setState({
      message: 'Please wait...'
    });

    const convertedEthers = this.state.balance / 1000000000000000000;
    await lottery.methods.pickWinner().send({
      from: accounts[0]
    });

    this.setState({ message: 'Congrats User ' + accounts[0] + ' , you have won ' + convertedEthers + ' Ethers!'});

   
    const players = await lottery.methods.getPlayers().call();
    const balance = await web3.eth.getBalance(lottery.options.address);

    this.setState({  players, balance });
    this.setState({ loading: false });
    this.setState({ standardBet: ""});
  };

  render() {
    const X1HomepageData = {
      title: "https://anima-uploads.s3.amazonaws.com/projects/5ff0a4b7fe424f757973934b/releases/5ff5cdb4c35e8b29a7cdaf05/img/title@1x.png",
      spanText: "Room Details",
      spanText2: " ",
      playerspng: "https://anima-uploads.s3.amazonaws.com/projects/5ff0a4b7fe424f757973934b/releases/5ff5cdb4c35e8b29a7cdaf05/img/playerspng@1x.png",
      numberOfPlayers: "Number of Players: ",
      potpng: "https://anima-uploads.s3.amazonaws.com/projects/5ff0a4b7fe424f757973934b/releases/5ff5cdb4c35e8b29a7cdaf05/img/potpng@1x.png",
      currentPotsize: "Current Potsize: ",
      gameplay: "GamePlay",
      text2: "Please input number of tokens to bet: ",
      gamePrompt: "Game Prompt",
      text1: this.state.message
    };

  //Grammatical OCD 
  var _inputEth = ""
  var _inputPlayer=""
  if(this.state.balance / 1000000000000000000 <= 1){
    _inputEth="Ether"
  }
  else{
    _inputEth="Ethers"
  }

  if(this.state.players.length <=1){
    _inputPlayer="Player"
  }
  else{
    _inputPlayer="Players"
  }
  if (this.state.pageLoading) {
      return <h1>Now Connecting....</h1>
  } else{
      return (
      <div className="x1homepage">
        <img className="title" src={X1HomepageData.title} />
        <h1 className="room-details valign-text-middle border-class-1 atomicage-normal-white-36px">
          <span>
            <span className="span1">{X1HomepageData.spanText}</span>
          </span>
        </h1>
        <div className="auto-flex2">
          <img className="playerspng" src={X1HomepageData.playerspng} />
          <div className={`nrplayers-frame border-class-2 ${""}`}>
          <div className="address valign-text-middle border-class-1 armata-regular-normal-black-16px">{this.state.players.length} {_inputPlayer}</div>
        </div>
          {/* <NrplayersFrame {...nrplayersFrameProps}>{nrplayersFrameData}</NrplayersFrame> */}
        </div>
        <div className="number-of-players valign-text-middle border-class-1 armata-regular-normal-black-16px">
          {X1HomepageData.numberOfPlayers}{this.state.players.length}
        </div>
        <div className="auto-flex1">
          <img className="potpng" src={X1HomepageData.potpng} />
          <div className={`nrplayers-frame border-class-2 ${""}`}>
          <div className="address valign-text-middle border-class-1 armata-regular-normal-black-16px">{this.state.balance / 1000000000000000000} {_inputEth}</div>
        </div>
          {/* <NrplayersFrame {...nrplayersFrame2Props} className="pot-frame"></NrplayersFrame> */}
        </div>
        <div className="current-potsize valign-text-middle border-class-1 armata-regular-normal-black-16px">
          {X1HomepageData.currentPotsize}{web3.utils.fromWei(this.state.balance, 'ether')} {_inputEth}
        </div>
        <div className="game-play valign-text-middle border-class-1 atomicage-regular-normal-absolute-zero-36px">
          {X1HomepageData.gameplay}
        </div>
        <div className={`overlap-group ${""}`}>
          <div className="text-2 border-class-1 armata-regular-normal-white-20px">{X1HomepageData.text2}
            <input
              type="number"
              value={this.state.value}
              onChange={event => this.setState({ value: event.target.value })}
            />
          </div>
          {/* <Overlapgroup3 {...overlapgroup3Props}></Overlapgroup3> */}
          <div className={`partButton ${""}`}>
          <Button variant="contained" disabled={this.state.value<1} size="Large" className="participate border-class-1 lato-regular-normal-black-16px" onClick = {this.onSubmit}>Participate</Button>
        </div>
        </div>
        <div className="game-prompt valign-text-middle border-class-1 atomicage-regular-normal-governor-bay-36px">
          {X1HomepageData.gamePrompt}
        </div>
        <div className="overlap-group1">
          <div className="armata-regular-normal-white-20px">{this.state.message}</div>
          {/* <div className="text-2 border-class-1 armata-regular-normal-black-20px">{this.state.message}</div> */}
          {/* <Overlapgroup3 {...overlapgroup32Props} className="overlap-group2" /> */}
        <div className={`backButton ${""}`}>
          <Button variant="contained" size="Large" color="secondary" className="lato-regular-normal-black-16px">Back</Button>
        </div>
        <div className={`pickWinnerButton ${""}`}>
          <Button variant="contained" disabled={this.state.players.length==0} size="Large" color="primary" className="lato-regular-normal-black-16px" onClick={this.onClick}>Pick Winner!</Button>
        </div>
        </div>
        <Wave/>
        </div>
      );
    }
  }
}
const Wave = () => {
      return(
        <svg height="100%" width="100%" id="bg-svg" viewBox="0 0 1440 500" xmlns="http://www.w3.org/2000/svg" 
        class="transition duration-300 ease-in-out delay-150"><defs><linearGradient id="gradient"><stop offset="5%" 
        stop-color="#9b7bc488"></stop><stop offset="95%" stop-color="#374b8c88"></stop></linearGradient></defs>
        <path d="M 0,500 C 0,500 0,166 0,166 C 108.42105263157893,194.86124401913878 216.84210526315786,223.72248803827753 319,
        207 C 421.15789473684214,190.27751196172247 517.0526315789474,127.97129186602871 618,112 C 718.9473684210526,
        96.02870813397129 824.9473684210525,126.39234449760764 900,154 C 975.0526315789475,181.60765550239236 1019.1578947368423,
        206.45933014354068 1104,208 C 1188.8421052631577,209.54066985645932 1314.4210526315787,187.77033492822966 1440,166 C 1440,
        166 1440,500 1440,500 Z" stroke="none" stroke-width="0" fill="url(#gradient)" class="transition-all duration-300 ease-in-out 
        delay-150"></path><defs><linearGradient id="gradient"><stop offset="5%" stop-color="#9b7bc4ff"></stop><stop offset="95%" 
        stop-color="#374b8cff"></stop></linearGradient></defs><path d="M 0,500 C 0,500 0,333 0,333 C 88.99521531100481,
        306.18660287081343 177.99043062200963,279.3732057416268 268,288 C 358.0095693779904,296.6267942583732 449.0334928229664,
        340.69377990430627 547,335 C 644.9665071770336,329.30622009569373 749.8755980861246,273.85167464114835 865,271 C 980.1244019138754,
        268.14832535885165 1105.4641148325359,317.8995215311005 1203,337 C 1300.5358851674641,356.1004784688995 1370.267942583732,
        344.55023923444975 1440,333 C 1440,333 1440,500 1440,500 Z" stroke="none" stroke-width="0" fill="url(#gradient)" 
        class="transition-all duration-300 ease-in-out delay-150"></path></svg>
      )
    }

export default App;

