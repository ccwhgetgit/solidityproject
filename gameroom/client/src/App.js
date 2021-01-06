import React, { Component } from 'react';
import './App.css';
import web3 from './web3';
import lottery from './lottery';

class App extends Component {
  state = {
    manager: '',
    players: [],
    balance: '',
    value: '',
    message: '',
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
    if (this.state.pageLoading) {
      return <h1>Now Connecting....</h1>
    } else {
      return (
        <div>
          <p>
            Players:{' '}
            {this.state.players.length} </p>
          <p>Total Pot Amount:{' '}
            {web3.utils.fromWei(this.state.balance, 'ether')} ethers
          </p>
          <p>Standard Bet: {' '}
            {web3.utils.fromWei(this.state.standardBet, 'ether')} ethers
          </p>
      
          <hr />
          <form onSubmit={this.onSubmit}>
          
            <label>Betting Amount: </label>
            <input
              type="number"
              value={this.state.value}
              onChange={event => this.setState({ value: event.target.value })}
            />
            <button disabled={this.state.loading}>Participate</button>
          </form>
          <hr />
          <h4>Ready to pick a winner?</h4>
          <button
            onClick={this.onClick}
            disabled={this.state.loading || !this.state.players.length}
          >
            Pick a Winner!
          </button>
          <hr />
          <h1>{this.state.message}</h1>
        </div>
      );
    }
  }
}

export default App;
