
import React, { useState, useEffect } from 'react'
import { MapContainer, Marker, Popup, TileLayer } from 'react-leaflet'
import { Socket, Presence } from 'phoenix'
import Geohash from 'latlon-geohash'

// const geohashFromPosition = (position) =>
//   position ? Geohash.encode(position.lat, position.lng, 5) : ""

export default ({ user }) => {
  const [position, setPosition] = useState({
    lat: user.lat,
    lng: user.lng,
  })
  const [presences, setPresences] = useState({})
  const [channel, setChannel] = useState()
  const [userChannel, setUserChannel] = useState()
  const [rideRequests, setRideRequests] = useState([])

  const getLat = (position) => position ? position.lat : 0
  const getLng = (position) => position ? position.lng : 0

  useEffect(() => {
    const socket = new Socket('ws://localhost:4000/socket', { params: {token: user.token}});
    socket.connect()

    if (!position) {
      return
    }

    // console.log(geohashFromPosition(position));

    const phxChannel = socket.channel('cell:*', {position: position})
    phxChannel.join().receive('ok', () => {
      console.log('Joined successfully')
      setChannel(phxChannel)
    })

    const phxUserChannel = socket.channel('user:' + user.id)
    phxUserChannel.join().receive('ok', response => {
      console.log('Joined user channel!')
      setUserChannel(phxUserChannel)
    })

    return () => {
      phxChannel.leave()
      phxUserChannel.leave()
    }
  }, [
  ])

  useEffect(() => {
    if (channel) {
      channel.push('update_position', position)
    }
  }, [
    getLat(position),
    getLng(position)
  ])

  useEffect(() => {
    if(user.type === 'driver') {
      const intervalId = setInterval(() => {
        setPosition({
          lat: position.lat + 0.00003,
          lng: position.lng + 0.00003,
        });
      }, 1500);

      return () => clearInterval(intervalId);
    }
  }, [position])

  if (!position) {
    return (<div>Awaiting for position...</div>)
  }

  if (!channel || !userChannel) {
    return (<div>Connecting to channel...</div>)
  }

  channel.on('ride:requested', rideRequest => {
    console.log('A ride has been requested!', rideRequest);
    setRideRequests([...rideRequests, rideRequest]);
  })

  channel.on('presence_state', state => {
    console.log('presence_state', state);
    const syncedPresences = Presence.syncState(presences, state)
    console.log(syncedPresences)
    setPresences(syncedPresences)
  })

  channel.on('presence_diff', response => {
    console.log('presence_diff', response)
    const syncedPresences = Presence.syncDiff(presences, response)
    console.log(syncedPresences)
    setPresences(syncedPresences)
  })

  userChannel.on('ride:created', ride =>
    console.log('A ride has been created!', ride)
  )

  const positionsFromPresences = Presence.list(presences)
  .filter(presence => !!presence.metas)
  .map(presence => presence.metas[0])


  const acceptRideRequest = (request_id) => {
    console.log('Accepting ride request', request_id)
    channel.push('ride:accept_request', {request_id})
  }

  const requestRide = () => {
    console.log('Requesting ride', position)

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

        {
          positionsFromPresences.map(({lat, lng, phx_ref}) => (
            <Marker key={phx_ref} position={{lat, lng}} />
          ))
        }
      </MapContainer>
    </div>
  )
}