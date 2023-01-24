import React, { useState } from "react"
import Login from './components/Login'
import Map from './components/Map'
import './App.css';

export default () => {
  const [user, setUser] = useState()
  
  const handleLogin = (user) => setUser(user)

  return user ?
    <Map user={user} /> :
    <Login onLogin={handleLogin} />
}