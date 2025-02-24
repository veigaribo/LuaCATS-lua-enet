---@meta
---Credit:
---Leafo's lua-enet https://leafo.net/lua-enet/
---lua-enet's documentation https://leafo.net/lua-enet/#reference
---love2d wiki https://www.love2d.org/wiki/lua-enet

---@class ENet
local enet = {}

---A `bind_address` of `nil` makes a host that can not
---be connected to (typically a client).Otherwise the address
---can either be of the form `<ipaddress>:<port>`,
---`<hostname>:<port>`, or `*:<port>`.
---
---Example addresses include `"127.0.0.1:8888"`, `"localhost:2232"`, and `"*:6767"`.
---@param bind_address? string # `<ipaddress>:<port>` or `<hostname>:<port>` or `*:<port>`
---@param peer_count? number # max number of peers, defaults to `64`
---@param channel_count? number # max number of channels, defaults to `1`
---@param in_bandwidth? number # downstream bandwidth in bytes/sec, defaults to `0` (unlimited)
---@param out_bandwidth? number # upstream bandwidth in bytes/sec, defaults to `0` (unlimited)
---@return ENetHost
function enet.host_create(bind_address, peer_count, channel_count, in_bandwidth, out_bandwidth) end

---@alias ENetPeerState
---| "disconnected"
---| "connecting"
---| "acknowledging_connect"
---| "connection_pending"
---| "connection_succeeded"
---| "connected"
---| "disconnect_later"
---| "disconnecting"
---| "acknowledging_disconnect"
---| "zombie"
---| "unknown"

---@alias ENetSendFlags # default is reliable
---| "reliable" # Reliable packets are guaranteed to arrive, and arrive in the order in which they are sent
---| "unreliable"
---| "unsequenced" # Unsequenced packets are unreliable and have no guarantee on the order they arrive

---@alias ENetEventType
---| "connect"
---| "disconnect"
---| "receive"

---An event is a table generated by `host:service()` or
---`peer:receive()` which will always contain a `string`
---named *type*, a `enet.peer` named *peer*, and a `string` or
---`number` named *data* depending on the kind of event. Receive
---has an additional field named channel which contains the
---channel the data was received on specified by
---`enet.peer:send`, by default this is 0.
---
---Though be wary that `host:service()` and `peer:receive()` can
---return `nil` if no events are in the queue.
---@class ENetEvent : table
---@field type ENetEventType
---@field peer ENetPeer
---@field data string|number # `string` for receive, `number` for connect/disconnect
---@field channel number?
local event = {}

---@class ENetHost
local host = {}

---Connects a host to a remote host. Returns peer object
---associated with remote host. The actual connection will not
---take place until the next `host:service` is done, in which a
---`"connect"` event will be generated.
---
---channel_count is the number of channels to allocate. It
---should be the same as the channel count on the server.
---Defaults to `1`.
---@param address string # `<ipaddress>:<port>` or `<hostname>:<port>` or `*:<port>`
---@param channel_count? number # defaults to `1`
---@param data? number # an integer value that can be associated with the connect event. Defaults to `0`
function host:connect(address, channel_count, data) end

---Wait for events, send and receive any ready packets. `timeout`
---is the max number of milliseconds to be waited for an event.
---By default `timeout` is `0`. Returns `nil` on timeout if no
---events occurred.
---
---If an event happens, an event table is returned. All events
---have a `type` entry, which is one of `"connect"`, `"disconnect"`,
---or `"receive"`. Events also have a peer entry which holds the
---peer object of who triggered the event.
---
---A "receive" event also has a data entry which is a Lua string
---containing the data received.
---@param timeout number? # defaults to `0`
---@return ENetEvent
function host:service(timeout) end

---Checks for any queued events and dispatches one if available.
---Returns the associated event if something was dispatched,
---otherwise `nil`.
---@return ENetEvent?
function host:check_events() end

---Enables an adaptive order-2 PPM range coder for the
---transmitted data of all peers.
function host:compress_with_range_coder() end

---Sends any queued packets. This is only required to send
---packets earlier than the next call to `host:service`, or if
---`host:service` will not be called again.
function host:flush() end

---Queues a packet to be sent to all connected peers.
---@param data string # contents of the packet, it must be a Lua string
---@param channel? number # channel to send the packet on. Defaults to 0.
---@param flag? ENetSendFlags # defaults to `"reliable"`
function host:broadcast(data, channel, flag) end

---Sets the maximum number of channels allowed. If it is `0`
---then the system maximum allowable value is used.
---@param limit number
function host:channel_limit(limit) end

---Sets the bandwidth limits of the host in bytes/sec.
---Set to 0 for unlimited.
---@param incoming number
---@param outgoing number
function host:bandwidth_limit(incoming, outgoing) end

---Returns the number of bytes that were sent through the
---given host.
---@return number
function host:total_sent_data() end

---Returns the timestamp of the last call to `host:service()`
---or `host:flush()`.
---@return number
function host:service_time() end

---Returns the number of peers that are allocated for the
---given host. This represents the maximum number of
---possible connections.
---@return number
function host:peer_count() end

---Returns the connected peer at the specified index
---(starting at 1). ENet stores all peers in an array of
---the corresponding host and re-uses unused peers for new
---connections. You can query the state of a peer using
---`peer:state`.
---@return ENetPeer
function host:get_peer() end

---Returns a string that describes the socket address of
---the given host. The string is formatted as `“a.b.c.d:port”`,
---where `“a.b.c.d”` is the ip address of the used socket.
---@return string
function host:get_sock_address() end

---@class ENetPeer
local peer = {}

---Returns the field ENetPeer::connectID that is assigned
---for each connection.
---@return number id
function peer:connect_id() end

---Requests a disconnection from the peer. The message is
---sent on the next host:service or host:flush.
---@param data number? # optional integer value to be associated with the disconnect.
function peer:disconnect(data) end

---Force immediate disconnection from peer. Foreign peer
---not guaranteed to receive disconnect notification.
---@param data number? # optional integer value to be associated with the disconnect.
function peer:disconnect_now(data) end

---Request a disconnection from peer, but only after all queued outgoing packets are sent.
---@param data number? # optional integer value to be associated with the disconnect.
function peer:disconnect_later(data) end

---Returns the index of the peer. All peers of an ENet
---host are kept in an array. This function finds and
---returns the index of the peer of its host structure.
---@return number index
function peer:index() end

---Send a ping request to peer, updates `round_trip_time`.
---This is called automatically at regular intervals.
function peer:ping() end

---Specifies the interval in milliseconds that pings are
---sent to the other end of the connection (defaults to 500).
---@param interval? number
function peer:ping_interval(interval) end

---Forcefully disconnects peer. The peer is not notified
---of the disconnection.
function peer:reset() end

---Queues a packet to be sent to peer.
---@param data string # contents of the packet, it must be a Lua string
---@param channel? number # channel to send the packet on. Defaults to 0.
---@param flag? ENetSendFlags # defaults to `"reliable"`
function peer:send(data, channel, flag) end

---Returns the state of the peer as a `string`
---@return ENetPeerState state
function peer:state() end

---Attempts to dequeue an incoming packet for this peer.
---Returns `nil` if there are no packets waiting. Otherwise
---returns two values: the string representing the packet
---data, and the channel the packet came from.
---@return string | nil # data or `nil`
---@return number channel
function peer:receive() end

---Returns or sets the current round trip time (i.e. ping).
---If value is nil the current value of the peer is returned.
---Otherwise the value roundTripTime is set to the specified
---value and returned.
---
---Enet performs some filtering on the round trip times and
---it takes some time until the parameters are accurate.
---@param value number
---@return number roundTripTime
function peer:round_trip_time(value) end

---Returns or sets the current round trip time (i.e. ping).
---If value is nil the current value of the peer is returned.
---Otherwise the value roundTripTime is set to the specified
---value and returned.
---
---Enet performs some filtering on the round trip times and
---it takes some time until the parameters are accurate.
function peer:round_trip_time() end

---Returns or sets the round trip time of the previous round
---trip time computation. If value is nil the current value of
---the peer is returned. Otherwise the value lastRoundTripTime
---is set to the specified value and returned.
---
---Enet performs some filtering on the round trip times and it
---takes some time until the parameters are accurate. To speed
---it up you can set the value of the last round trip time to
---a more accurate guess.
---@param value number
---@return number lastRoundTripTime
function peer:last_round_trip_time(value) end

---Returns or sets the round trip time of the previous round
---trip time computation. If value is nil the current value of
---the peer is returned. Otherwise the value lastRoundTripTime
---is set to the specified value and returned.
---
---Enet performs some filtering on the round trip times and it
---takes some time until the parameters are accurate. To speed
---it up you can set the value of the last round trip time to
---a more accurate guess.
function peer:last_round_trip_time() end

---Changes the probability at which unreliable packets should
---not be dropped.
---@param interval number # interval in milliseconds to measure lowest mean RTT
---@param acceleration number # rate at which to increase throttle probability as mean RTT declines
---@param deceleration number # rate at which to decrease throttle probability as mean RTT increases
function peer:throttle_configure(interval, acceleration, deceleration) end

---Returns or sets the parameters when a timeout is detected.
---This is happens either after a fixed timeout or a variable
---timeout of time that takes the round trip time into account.
---The former is specified with the maximum parameter.
---@param limit number # a factor that is multiplied with a value that based on the average round trip time to compute the timeout limit
---@param minimum number # timeout value in milliseconds that a reliable packet has to be acknowledged if the variable timeout limit was exceeded
---@param maximum number # fixed timeout in milliseconds for which any packet has to be acknowledged
function peer:timeout(limit, minimum, maximum) end

---Returns or sets the parameters when a timeout is detected.
---This is happens either after a fixed timeout or a variable
---timeout of time that takes the round trip time into account.
---The former is specified with the maximum parameter.
---@return number limit # a factor that is multiplied with a value that based on the average round trip time to compute the timeout limit
---@return number minimum # timeout value in milliseconds that a reliable packet has to be acknowledged if the variable timeout limit was exceeded
---@return number maximum # fixed timeout in milliseconds for which any packet has to be acknowledged
function peer:timeout() end

return enet
