import React, { Component } from 'react';
import { render } from 'react-dom';
import { BrowserRouter } from 'react-router-dom';

import App3 from './App1.js';
import './style.css';

render(
  (<BrowserRouter>
    <App3 />
  </BrowserRouter>), document.getElementById('root'));