import React, { Component } from 'react';
import './App.css';
import Web3 from 'web3';
import lottery from './ContractABI';

class App extends Component {
  state = {
    manager: '',
    players: [],
    balance: '',
    value: '',
    message: '',
    loading: false,
    pageLoading: true
  };

  async componentDidMount() {
   
    const players = await lottery.methods.getPlayers().call();
    const balance = await Web3.eth.getBalance(lottery.options.address);
    this.setState({  players, balance });

    Web3.eth.subscribe('newBlockHeaders', function (err, result) {
      if(err) {
        console.log(err);
      }
    });

    this.setState({pageLoading: false})
  }

  onSubmit = async event => {
    event.preventDefault();

    if (this.state.value <= 0.01) {
      this.setState({ message: 'Entry must exceed 0.01 ether.' });
      return;
    }

    const accounts = await Web3.eth.getAccounts();

    this.setState({ loading: true });
    this.setState({
      message: 'This may take up to a minute. Waiting on transaction success...'
    });

    await lottery.methods.enter().send({
      from: accounts[0],
      value: Web3.utils.toWei(this.state.value, 'ether')
    });

    this.setState({ message: 'You have been entered!' });
    this.setState({ value: '' });

   
    const players = await lottery.methods.getPlayers().call();
    const balance = await Web3.eth.getBalance(lottery.options.address);

    this.setState({ players, balance });
    this.setState({ loading: false });
  };

  onClick = async () => {
    const accounts = await Web3.eth.getAccounts();

    this.setState({ loading: true });
    this.setState({
      message: 'Hold up...'
    });

    await lottery.methods.pickWinner().send({
      from: accounts[0]
    });

    this.setState({ message: 'Check your account. The winner is picked!' });

   
    const players = await lottery.methods.getPlayers().call();
    const balance = await Web3.eth.getBalance(lottery.options.address);

    this.setState({  players, balance });
    this.setState({ loading: false });
  };

  render() {
    if (this.state.pageLoading) {
      return <h1>Connecting....</h1>
    } else {
      return (
        <div>
         
          <p>
            There are currently{' '}
            {this.state.players.length} in the game, competing to win{' '}
            {Web3.utils.fromWei(this.state.balance, 'ether')} ether!
          </p>
          
          <hr />
          
          <form onSubmit={this.onSubmit}>
          
            <label>Amount of ether to enter</label>
            <input
              type="number"
              value={this.state.value}
              onChange={event => this.setState({ value: event.target.value })}
            />
            <button disabled={this.state.loading}>Enter</button>
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
// function App() {
//   return (
//     <div className="App">
//       <header className="App-header">
//         <img src={logo} className="App-logo" alt="logo" />
//         <p>
//           Edit <code>src/App.js</code> and save to reload.
//         </p>
//         <a
//           className="App-link"
//           href="https://reactjs.org"
//           target="_blank"
//           rel="noopener noreferrer"
//         >
//           Learn React
//         </a>
//       </header>
//     </div>
//   );
// }

export default App;
