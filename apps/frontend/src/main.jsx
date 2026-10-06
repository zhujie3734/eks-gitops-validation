import React, {useState, useEffect} from 'react';
import {createRoot} from 'react-dom/client';
import './App.css';
import './index.css';

// Adapted from the original App.js: add, fetch, clear PostgreSQL text records.
function App() {
  const [input, setInput] = useState('');
  const [texts, setTexts] = useState([]);
  const [error, setError] = useState('');
  async function api(path, options) {
    const response = await fetch('/api/' + path, options);
    if (!response.ok) throw new Error(await response.text());
    return response;
  }
  async function refresh() { setTexts((await (await api('fetch')).json()).texts); }
  async function act(fn) { try { setError(''); await fn(); } catch(e) { setError(e.message); } }
  useEffect(() => { act(refresh); }, []);
  return <div className="App">
    <header className="App-header">GitOps Lab · {__APP_VERSION__}</header>
    <p>Build → Git commit → Argo CD → Kubernetes</p>
    <input aria-label="Text" maxLength={120} value={input} onChange={e => setInput(e.target.value)}/>
    <button onClick={() => act(async () => { await api('add', {method:'POST', headers:{'Content-Type':'application/json'}, body:JSON.stringify({text:input})}); setInput(''); await refresh(); })}>Add</button>
    <button onClick={() => act(refresh)}>Refresh</button>
    <button onClick={() => act(async () => { await api('delete', {method:'DELETE'}); await refresh(); })}>Clear</button>
    {error && <p role="alert">{error}</p>}
    <ul>{texts.map((row, i) => <li key={i}>{row.text}</li>)}</ul>
  </div>;
}
createRoot(document.getElementById('root')).render(<App/>);
