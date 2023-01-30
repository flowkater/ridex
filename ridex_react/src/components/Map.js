
import React, { useState, useEffect } from 'react'
import { MapContainer, Marker, Popup, TileLayer } from 'react-leaflet'
import { Socket } from 'phoenix'
import Geohash from 'latlon-geohash'

// const geohashFromPosition = (position) =>
//   position ? Geohash.encode(position.lat, position.lng, 5) : ""

export default ({ user }) => {
  const [position, setPosition] = useState({
    lat: user.lat,
    lng: user.lng,
  })
  const [channel, setChannel] = useState()
  const [userChannel, setUserChannel] = useState()
  const [rideRequests, setRideRequests] = useState([])

  useEffect(() => {
    const socket = new Socket('ws://localhost:4000/socket', { params: {token: user.token}});
    socket.connect()

    if (!position) {
      return
    }

    // console.log(geohashFromPosition(position));

    const phxChannel = socket.channel('cell:xyz')
    phxChannel.join().receive('ok', () => {
      console.log('Joined successfully')
      setChannel(phxChannel)
    })

    const phxUserChannel = socket.channel('user:' + user.id)
    phxUserChannel.join().receive('ok', response => {
      console.log('Joined user channel!')
      setUserChannel(phxUserChannel)
    })

    return () => phxChannel.leave()
  }, [
    // geohashFromPosition(position),
  ])

  useEffect(() => {
    if(user.type === 'driver') {
      const intervalId = setInterval(() => {
        setPosition({
          lat: position.lat + 0.00006,
          lng: position.lng + 0.00006,
        });
      }, 1000);

      return () => clearInterval(intervalId);
    }
  }, [position])

  if (!position) {
    return (<div>Awaiting for position...</div>)
  }

  if (!channel || !userChannel) {
    return (<div>Connecting to channel...</div>)
  }

  useEffect(() => {
    if (!channel) return;

    channel.on('ride:requested', rideRequest => {
      console.log('A ride has been requested!', rideRequest);
      setRideRequests([...rideRequests, rideRequest]);
    })

    return () => {
      channel.off('ride:requested', channel);
    }
  }, [channel]);

  

  userChannel.on('ride:created', ride =>
    console.log('A ride has been created!')
  )

  const acceptRideRequest = (request_id) => {
    console.log('Accepting ride request', request_id)
    channel.push('ride:accept_request', {request_id})
  }

  const requestRide = () => {
    console.log('Requesting ride', position)
    console.log(channel);
    channel.push('ride:request', { position: position })
  }
  
  return (
    <div>
      Logged in as {user.type}
      {user.type === 'rider' && (
        <div>
          <button onClick={requestRide}>Request ride</button>
        </div>
      )}

      <MapContainer center={position} zoom={15}>
        <TileLayer
          url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
          attribution="&copy; <a href=&quot;http://osm.org/copyright&quot;>OpenStreetMap</a> contributors"
        />

        <Marker position={position} />

        {rideRequests.map(({request_id, position}) => (
          <Marker key={request_id} position={position}>
            <Popup>
              New ride Request
              <button onClick={() => acceptRideRequest(request_id)}>Accept</button>
            </Popup>
          </Marker>
        ))}
      </MapContainer>
    </div>
  )
}