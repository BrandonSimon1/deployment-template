import React from 'react';
import './App.css';
import { Switch, Route } from "react-router-dom";
import { useQuery, gql } from '@apollo/client';

function App() {
  return (
    <Switch>
      <Route path="/">
        <div>Hello World</div>
      </Route>
    </Switch>
  );
}

export default App;
