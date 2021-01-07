import React, { Component } from 'react';
import './App.css';
import web3 from './web3';
import lottery from './lottery';

class App extends Component {
  
};



function X1Homepage(props) {
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
  } = props;

  return (
    
    <div className="x1homepage">
      <X1Homepage {...X1HomepageData} />
      <img className="title" src={title} />
      <h1 className="room-details valign-text-middle border-class-1 atomicage-normal-white-36px">
        <span>
          <span className="span1">{spanText}</span>
          <span className="span2">{spanText2}</span>
        </span>
      </h1>
      <div className="auto-flex2">
        <img className="playerspng" src={playerspng} />
        <NrplayersFrame {...nrplayersFrameProps} />
      </div>
      <div className="number-of-players valign-text-middle border-class-1 armata-regular-normal-black-16px">
        {numberOfPlayers}
      </div>
      <div className="auto-flex1">
        <img className="potpng" src={potpng} />
        <NrplayersFrame {...nrplayersFrame2Props} className="pot-frame" />
      </div>
      <div className="current-potsize valign-text-middle border-class-1 armata-regular-normal-black-16px">
        {currentPotsize}
      </div>
      <div className="game-play valign-text-middle border-class-1 atomicage-regular-normal-absolute-zero-36px">
        {gameplay}
      </div>
      <div className="overlap-group1">
        <div className="text-2 border-class-1 armata-regular-normal-white-20px">{text2}</div>
        <Overlapgroup3 {...overlapgroup3Props} />
      </div>
      <div className="game-prompt valign-text-middle border-class-1 atomicage-regular-normal-governor-bay-36px">
        {gamePrompt}
      </div>
      <div className="overlap-group">
        <div className="text-1 valign-text-middle border-class-1 armata-regular-normal-black-20px">{text1}</div>
        <Overlapgroup3 {...overlapgroup32Props} className="overlap-group2" />
      </div>
      <div className="auto-flex">
        <NrplayersFrame {...nrplayersFrame3Props} className="back" />
        <NrplayersFrame {...nrplayersFrame4Props} className="submit" />
      </div>
    </div>
  );
}


function NrplayersFrame(props) {
  const { address, className } = props;

  return (
    <div className={`nrplayers-frame border-class-2 ${className || ""}`}>
      <div className="address valign-text-middle border-class-1 armata-regular-normal-black-16px">{address}</div>
    </div>
  );
}


function Overlapgroup3(props) {
  const { participate, className } = props;

  return (
    <div className={`overlap-group3 ${className || ""}`}>
      <div className="participate border-class-1 lato-regular-normal-black-16px">{participate}</div>
    </div>
  );
}
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
    numberOfPlayers: "Number of Players",
    potpng: "https://anima-uploads.s3.amazonaws.com/projects/5ff0a4b7fe424f757973934b/releases/5ff5cdb4c35e8b29a7cdaf05/img/potpng@1x.png",
    currentPotsize: "Current Potsize",
    gameplay: "GamePlay",
    text2: "CLICK THE BUTTON TO PARTICIPATE",
    gamePrompt: "Game Prompt",
    text1: "Congratulations! You have won {ether} ethers!",
    nrplayersFrameProps: nrplayersFrameData,
    nrplayersFrame2Props: nrplayersFrame2Data,
    overlapgroup3Props: overlapgroup3Data,
    overlapgroup32Props: overlapgroup32Data,
    nrplayersFrame3Props: nrplayersFrame3Data,
    nrplayersFrame4Props: nrplayersFrame4Data,
};

export default App;

