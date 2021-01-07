import React, { Component } from 'react';
import './App.css';
import web3 from './web3';
import lottery from './lottery';


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

    this.setState({ message: 'Congrats user ' + accounts[0] + ' , you have won ' + convertedEthers + ' ethers.'});

   
    const players = await lottery.methods.getPlayers().call();
    const balance = await web3.eth.getBalance(lottery.options.address);

    this.setState({  players, balance });
    this.setState({ loading: false });
    this.setState({ standardBet: ""});
  };

  render() {
    
    const {
      title,
      spanText,
      spanText2,
      playerspng,
      numberOfPlayers,
      potpng,
      currentPotsize,
      gameplay,
      text2,
      gamePrompt,
      text1,
      nrplayersFrameProps,
      nrplayersFrame2Props,
      overlapgroup3Props,
      overlapgroup32Props,
      nrplayersFrame3Props,
      nrplayersFrame4Props,
    } = this.props;

    const nrplayersFrameData = {
      address: "5 Players",
    };
  
    const nrplayersFrame2Data = {
      address: "50 Tokens",
    };
  
    const overlapgroup3Data = {
      participate: "PARTICIPATE",
    };
  
    const overlapgroup32Data = {
      participate: "OK",
    };
  
    const nrplayersFrame3Data = {
      address: "Back",
    };
  
    const nrplayersFrame4Data = {
      address: "Start Game",
    };

    const X1HomepageData = {
      title: "https://anima-uploads.s3.amazonaws.com/projects/5ff0a4b7fe424f757973934b/releases/5ff5cdb4c35e8b29a7cdaf05/img/title@1x.png",
      spanText: "Room Details",
      spanText2: " ",
      playerspng: "https://anima-uploads.s3.amazonaws.com/projects/5ff0a4b7fe424f757973934b/releases/5ff5cdb4c35e8b29a7cdaf05/img/playerspng@1x.png",
      numberOfPlayers: "Number of Players: ",
      potpng: "https://anima-uploads.s3.amazonaws.com/projects/5ff0a4b7fe424f757973934b/releases/5ff5cdb4c35e8b29a7cdaf05/img/potpng@1x.png",
      currentPotsize: "Current Potsize: ",
      gameplay: "GamePlay",
      text2: "CLICK THE BUTTON TO PARTICIPATE",
      gamePrompt: "Game Prompt",
      text1: this.state.message,
      nrplayersFrameProps: nrplayersFrameData,
      nrplayersFrame2Props: nrplayersFrame2Data,
      overlapgroup3Props: overlapgroup3Data,
      overlapgroup32Props: overlapgroup32Data,
      nrplayersFrame3Props: nrplayersFrame3Data,
      nrplayersFrame4Props: nrplayersFrame4Data,
    };

    

    

  return (
    <div className="x1homepage">
      <img className="title" src={X1HomepageData.title} />
      <h1 className="room-details valign-text-middle border-class-1 atomicage-normal-white-36px">
        <span>
          <span className="span1">{X1HomepageData.spanText}</span>
          <span className="span2">{X1HomepageData.spanText2}</span>
        </span>
      </h1>
      <div className="auto-flex2">
        <img className="playerspng" src={X1HomepageData.playerspng} />
        <div className={`nrplayers-frame border-class-2 ${""}`}>
        <div className="address valign-text-middle border-class-1 armata-regular-normal-black-16px">{this.state.players.length} players</div>
      </div>
        {/* <NrplayersFrame {...nrplayersFrameProps}>{nrplayersFrameData}</NrplayersFrame> */}
      </div>
      <div className="number-of-players valign-text-middle border-class-1 armata-regular-normal-black-16px">
        {X1HomepageData.numberOfPlayers}{this.state.players.length}
      </div>
      <div className="auto-flex1">
        <img className="potpng" src={X1HomepageData.potpng} />
        <div className={`nrplayers-frame border-class-2 ${""}`}>
        <div className="address valign-text-middle border-class-1 armata-regular-normal-black-16px">{this.state.balance / 1000000000000000000} ethers</div>
      </div>
        {/* <NrplayersFrame {...nrplayersFrame2Props} className="pot-frame"></NrplayersFrame> */}
      </div>
      <div className="current-potsize valign-text-middle border-class-1 armata-regular-normal-black-16px">
        {X1HomepageData.currentPotsize}{web3.utils.fromWei(this.state.balance, 'ether')} ethers
      </div>
      <div className="game-play valign-text-middle border-class-1 atomicage-regular-normal-absolute-zero-36px">
        {X1HomepageData.gameplay}
      </div>
      <div className="overlap-group">
        <div className="text-2 border-class-1 armata-regular-normal-white-20px">{X1HomepageData.text2}
          <input
            type="number"
            value={this.state.value}
            onChange={event => this.setState({ value: event.target.value })}
          />
        </div>
        {/* <Overlapgroup3 {...overlapgroup3Props}></Overlapgroup3> */}
        <div className={`overlap-group3 ${""}`}>
        <div className="participate border-class-1 lato-regular-normal-black-16px" onClick = {this.onSubmit}>Participate</div>
      </div>
      </div>
      <div className="game-prompt valign-text-middle border-class-1 atomicage-regular-normal-governor-bay-36px">
        {X1HomepageData.gamePrompt}
      </div>
      <div className="overlap-group1">
        <div className="text-2 border-class-1 armata-regular-normal-white-20px">{this.state.message}</div>
        {/* <Overlapgroup3 {...overlapgroup32Props} className="overlap-group2" /> */}
        <div className={`overlap-group3 ${""}`}>
        <div className="participate border-class-1 lato-regular-normal-black-16px">OK</div></div>
      </div>
      <div className="auto-flex">
      <div className={`nrplayers-frame border-class-2 ${""}`}>
        <div className="address valign-text-middle border-class-1 armata-regular-normal-black-16px">Back</div>
      </div>
      <div className={`nrplayers-frame border-class-2 ${""}`}>
        <div className="address valign-text-middle border-class-1 armata-regular-normal-black-16px" onClick={this.onClick}>Pick Winner!</div>
      </div>
        {/* <NrplayersFrame {...nrplayersFrame3Props} className="back">Back</NrplayersFrame>
        <NrplayersFrame {...nrplayersFrame4Props} className="submit" /> */}
      </div>
    </div>
  );
}
}

export default App;


// class NrplayersFrame extends React.Component {
//   render() {
//     const { address, className } = this.props;

//     return (
//       <div className={`nrplayers-frame border-class-2 ${className || ""}`}>
//         <div className="address valign-text-middle border-class-1 armata-regular-normal-black-16px">{"Hello"}</div>
//       </div>
//     );
//   }
// }


// class Overlapgroup3 extends React.Component {
//   render() {
//     const { participate, className } = this.props;

//     return (
//       <div className={`overlap-group3 ${className || ""}`}>
//         <div className="participate border-class-1 lato-regular-normal-black-16px">{participate}</div>
//       </div>
//     );
//   }
// }



// class App extends Component {
//   state = {
//     manager: '',
//     players: [],
//     balance: '',
//     value: '',
//     message: '',
//     loading: false,
//     pageLoading: true,
//     standardBet: '',
//     account: '',
//     guess: 0
//   };

//   async componentDidMount() {
   
//     const players = await lottery.methods.getPlayers().call();
//     const balance = await web3.eth.getBalance(lottery.options.address);
//     const accounts = await web3.eth.getAccounts();
//     this.setState({  players, balance });
//     this.setState({ account: accounts[0] })
//     web3.eth.subscribe('newBlockHeaders', function (err, result) {
//       if(err) {
//         console.log(err);
//       }
//     });

//     this.setState({pageLoading: false})
//   }

//   onSubmit = async event => {
//     event.preventDefault();

//     if (this.state.value < 1) {
//       this.setState({ message: 'You need a minimum of 1 ether to bet.' });
//       return;
//     }
//     const accounts = await web3.eth.getAccounts();

//     this.setState({ loading: true });
//     this.setState({
//       message: 'This may take up to a minute. Waiting on transaction success...'
//     });

//     await lottery.methods.enter().send({
//       from: accounts[0],
//       value: web3.utils.toWei(this.state.value, 'ether')
//     });

//     this.setState({ message: 'Entry Recorded!'});
//     this.setState({ value: '' });

   
//     const players = await lottery.methods.getPlayers().call();
//     const balance = await web3.eth.getBalance(lottery.options.address);

//     this.setState({ players, balance });
//     this.setState({ loading: false });
//   };

//   onClick = async () => {
//     const accounts = await web3.eth.getAccounts();

//     this.setState({ loading: true });
//     this.setState({
//       message: 'Please wait...'
//     });

//     const convertedEthers = this.state.balance / 1000000000000000000;
//     await lottery.methods.pickWinner().send({
//       from: accounts[0]
//     });

//     this.setState({ message: 'Congrats user ' + accounts[0] + ' , you have won ' + convertedEthers + ' ethers.'});

   
//     const players = await lottery.methods.getPlayers().call();
//     const balance = await web3.eth.getBalance(lottery.options.address);

//     this.setState({  players, balance });
//     this.setState({ loading: false });
//     this.setState({ standardBet: ""});
//   };

//   render() {
//       const {
//         title,
//         spanText,
//         spanText2,
//         playerspng,
//         numberOfPlayers,
//         potpng,
//         currentPotsize,
//         gameplay,
//         text2,
//         gamePrompt,
//         text1,
//         nrplayersFrameProps,
//         nrplayersFrame2Props,
//         overlapgroup3Props,
//         overlapgroup32Props,
//         nrplayersFrame3Props,
//         nrplayersFrame4Props,
//       } = this.props;
//     if (this.state.pageLoading) {
//       return <h1>Now Connecting....</h1>
//     } else {
//       return (
//         // <div class = "App-header">
//         //   <p>
//         //     Players:{' '}
//         //     {this.state.players.length} </p>
//         //   <p>Total Pot Amount:{' '}
//         //     {web3.utils.fromWei(this.state.balance, 'ether')} ethers
//         //   </p>
//         //   <p>Standard Bet: {' '}
//         //     {web3.utils.fromWei(this.state.standardBet, 'ether')} ethers
//         //   </p>
      
//         //   <hr />
//         //   <form onSubmit={this.onSubmit}>
          
//         //     <label>Betting Amount: </label>
//         //     <input
//         //       type="number"
//         //       value={this.state.value}
//         //       onChange={event => this.setState({ value: event.target.value })}
//         //     />
//         //     <button disabled={this.state.loading}>Participate</button>
//         //   </form>
//         //   <hr />
//         //   <h4>Ready to pick a winner?</h4>
//         //   <button
//         //     onClick={this.onClick}
//         //     disabled={this.state.loading || !this.state.players.length}
//         //   >
//         //     Pick a Winner!
//         //   </button>
//         //   <hr />
//         //   <h1>{this.state.message}</h1>
//         // </div>
//         <div className="x1homepage">
//         <img className="title" src={title} />
//         <h1 className="room-details valign-text-middle border-class-1 atomicage-normal-white-36px">
//           <span>
//             <span className="span1">{spanText}</span>
//             <span className="span2">{spanText2}</span>
//           </span>
//         </h1>
//         <div className="auto-flex2">
//           <img className="playerspng" src={playerspng} />
//           <NrplayersFrame {...nrplayersFrameProps} />
//         </div>
//         <div className="number-of-players valign-text-middle border-class-1 armata-regular-normal-black-16px">
//           {numberOfPlayers}
//         </div>
//         <div className="auto-flex1">
//           <img className="potpng" src={potpng} />
//           <NrplayersFrame {...nrplayersFrame2Props} className="pot-frame" />
//         </div>
//         <div className="current-potsize valign-text-middle border-class-1 armata-regular-normal-black-16px">
//           {currentPotsize}
//         </div>
//         <div className="game-play valign-text-middle border-class-1 atomicage-regular-normal-absolute-zero-36px">
//           {gameplay}
//         </div>
//         <div className="overlap-group">
//           <div className="text-2 border-class-1 armata-regular-normal-white-20px">{text2}</div>
//           <Overlapgroup3 {...overlapgroup3Props} />
//         </div>
//         <div className="game-prompt valign-text-middle border-class-1 atomicage-regular-normal-governor-bay-36px">
//           {gamePrompt}
//         </div>
//         <div className="overlap-group1">
//           <div className="text-1 valign-text-middle border-class-1 armata-regular-normal-black-20px">{text1}</div>
//           <Overlapgroup3 {...overlapgroup32Props} className="overlap-group2" />
//         </div>
//         <div className="auto-flex">
//           <NrplayersFrame {...nrplayersFrame3Props} className="back"></NrplayersFrame>
//           <NrplayersFrame {...nrplayersFrame4Props} className="submit" />
//         </div>
//       </div>
//       );
//     }
//   }
// }
// //Extra elements to use ltr. 
// class NrplayersFrame extends React.Component {
//   render() {
//     const { address, className } = this.props;

//     return (
//       <div className={`nrplayers-frame border-class-2 ${className || ""}`}>
//         <div className="address valign-text-middle border-class-1 armata-regular-normal-black-16px">{address}</div>
//       </div>
//     );
//   }
// }


// class Overlapgroup3 extends React.Component {
//   render() {
//     const { participate, className } = this.props;

//     return (
//       <div className={`overlap-group3 ${className || ""}`}>
//         <div className="participate border-class-1 lato-regular-normal-black-16px">{participate}</div>
//       </div>
//     );
//   }
// }
// const nrplayersFrameData = {
//     address: "5 Players",
// };

// const nrplayersFrame2Data = {
//     address: "50 Tokens",
// };

// const overlapgroup3Data = {
//     participate: "PARTICIPATE",
// };

// const overlapgroup32Data = {
//     participate: "OK",
// };

// const nrplayersFrame3Data = {
//     address: "Back",
// };

// const nrplayersFrame4Data = {
//     address: "Start Game",
// };

// const X1HomepageData = {
//     title: "https://anima-uploads.s3.amazonaws.com/projects/5ff0a4b7fe424f757973934b/releases/5ff5cdb4c35e8b29a7cdaf05/img/title@1x.png",
//     spanText: "Room Details",
//     spanText2: " ",
//     playerspng: "https://anima-uploads.s3.amazonaws.com/projects/5ff0a4b7fe424f757973934b/releases/5ff5cdb4c35e8b29a7cdaf05/img/playerspng@1x.png",
//     numberOfPlayers: "Number of Players",
//     potpng: "https://anima-uploads.s3.amazonaws.com/projects/5ff0a4b7fe424f757973934b/releases/5ff5cdb4c35e8b29a7cdaf05/img/potpng@1x.png",
//     currentPotsize: "Current Potsize",
//     gameplay: "GamePlay",
//     text2: "CLICK THE BUTTON TO PARTICIPATE",
//     gamePrompt: "Game Prompt",
//     text1: "Congratulations! You have won {ether} ethers!",
//     nrplayersFrameProps: nrplayersFrameData,
//     nrplayersFrame2Props: nrplayersFrame2Data,
//     overlapgroup3Props: overlapgroup3Data,
//     overlapgroup32Props: overlapgroup32Data,
//     nrplayersFrame3Props: nrplayersFrame3Data,
//     nrplayersFrame4Props: nrplayersFrame4Data,
// };


// export default App;
