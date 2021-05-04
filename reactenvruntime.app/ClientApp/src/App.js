import React, {useState, useEffect} from "react";
import env from "@beam-australia/react-env";

const styles = {
  padding: 30,
  margin: 30,
  backgroundColor: "rgba(238, 238, 238, 0.39)",
  fontFamily: "monospace"
};

const App = () => {
  const [data, setData] = useState({ todos: []});

  useEffect(() => {
    const response = async () => {
      const response = await fetch(`${env("API_HOST")}/todos`);
      const todos = await response.json();
      setData({todos});
    };

    response();
  }, [])

  return (
    <div style={{ width: 650, margin: "0 auto" }}>
    <h1>React Env - {env("FRAMEWORK")}</h1>
    <p>Runtime environment variables</p>
    <hr />
    <h3>Environment</h3>
    <div style={styles}>
      <pre>{JSON.stringify(env(), null, 2)}</pre>
    </div>
    <hr />
    <h3>Todos</h3>
    <ul>
      {data.todos.slice(0, 5).map(todo => (
        <li key={todo.id}>{todo.title}</li>
      ))}
    </ul>
  </div>
  );
}

export default App;

// import React, { Component } from 'react';
// import { Route } from 'react-router';
// import { Layout } from './components/Layout';
// import { Home } from './components/Home';
// import { FetchData } from './components/FetchData';
// import { Counter } from './components/Counter';

// import './custom.css'

// export default class App extends Component {
//   static displayName = App.name;

//   render () {
//     return (
//       <Layout>
//         <Route exact path='/' component={Home} />
//         <Route path='/counter' component={Counter} />
//         <Route path='/fetch-data' component={FetchData} />
//       </Layout>
//     );
//   }
// }
