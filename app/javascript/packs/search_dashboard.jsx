import React, {Component} from 'react'
import ReactDOM from 'react-dom'

class SearchDashboard extends Component {
  state = {
    term: '',
    autoCompleteResults: []
  }

  componentDidMount() {
    this.callSearch();
  }

  callSearch = () => {
    fetch('/search?q=' + this.state.term)
        .then(response => response.json())
        .then(response => {
          console.log(response.languages)
          this.setState({autoCompleteResults: response.languages}
          )
        })
  }

  getAutoCompleteResults(e) {
    this.setState({
      term: e.target.value
    }, () => {
      this.callSearch();
    });
  }

  render() {
    let {autoCompleteResults} = this.state;
    let autoCompleteList = []
    console.log(autoCompleteResults)
    debugger
    if (autoCompleteResults !== undefined) {
      autoCompleteList = autoCompleteResults.map((response, index) => {
        return <div key={index} className='card-wrapper'>
          <h2 className='name'>{response.name}</h2>
          <p className='type'>{response.type}</p>
          <p className='designed_by'>{response.designed_by}</p>
        </div>
      });
    }

    return (
      <div className='main-container'>
        <form action="" className="search-bar">
          <input ref={(input) => {
            this.searchBar = input
          }} value={this.state.term} onChange={this.getAutoCompleteResults.bind(this)}
                 type="search" name="search" required/>
          <button className="search-btn" type="submit">
            <span>Search</span>
          </button>
        </form>
        {autoCompleteList}
      </div>
    )
  }
}

document.addEventListener('DOMContentLoaded', () => {
  ReactDOM.render(
      <SearchDashboard/>,
      document.body.appendChild(document.createElement('div')),
  )
});