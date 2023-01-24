import React, { useState } from "react"
import { HOST } from "../lib/host"

export default ({ onLogin }) => {
  const [phone, setPhone] = useState('')

  const onChange = (event) =>
    setPhone(event.target.value)

  const login = userType => () =>
    fetch(`${HOST}/api/authenticate`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        phone: phone,
        type: userType
      })
    }).then(res => res.json())
      .then(user => onLogin(user))
  
  return (<div>
    <p>Welcome to Ridex! Please check in using your phone number</p>
    <input
      type="text"
      placeholder="Phone number"
      value={phone}
      onChange={onChange} />

    <button onClick={login('driver')}>Login as driver</button>
    <button onClick={login('rider')}>Login as rider</button>
  </div>)
}