import React, {Component} from 'react';
import { Link } from 'react-router-dom';

class Navbar extends Component {
  handleClick = () => this.props.onClick(this.props.index)

  render() {
    return (
    <div>
        <Link to={`/${this.props.name}`}>
          <li
            className={this.props.isActive ? 'active' : ''}
            onClick={this.handleClick}>
            {this.props.name}
          </li>
        </Link>
        </div>
    );
  }
}

export default Navbar;