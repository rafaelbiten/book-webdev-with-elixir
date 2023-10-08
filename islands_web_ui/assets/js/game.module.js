import { Channel, Socket } from 'phoenix'

const socket = new Socket('/socket', Socket, { params: { token: window.userToken } })
socket.connect()

export const gameModule = {
  channelNew,
  channelJoin,
  channelLeave,
  startGame,

  reply,
  push,
  broadcast,
}

/**
 * @param {Socket} socket
 * @param {string} subtopic
 * @param {string} params
 * @returns Channel
 */
function channelNew(subtopic, screen_name) {
  return socket.channel(`game:${subtopic}`, { screen_name })
}

/**
 * @param {Channel} channel
 */
function channelJoin(channel) {
  channel
    .join()
    .receive('ok', () => console.log(`Joined "${channel.topic}"`))
    .receive('error', () => console.log(`Unable to join "${channel.topic}"...`))
}

/**
 * @param {Channel} channel
 */
function channelLeave(channel) {
  channel
    .leave()
    .receive('ok', resp => console.log('Left channel!', resp))
    .receive('error', resp => console.log('Unable to leave the channel...', resp))
}

function startGame(channel) {
  channel
    .push('start_game')
    .receive('ok', response => console.log('Game started!', response))
    .receive('error', reason => {
      if (reason.includes(':already_started')) return console.log('Game resumed!')

      console.error(`Unable to start the game: ${reason}`)
    })
}

/**
 * @param {Channel} channel
 * @param {any} payload
 */
function reply(channel, payload) {
  channel
    .push('reply', payload)
    .receive('ok', response => console.log('reply: ', response))
    .receive('error', error => console.error('Unable to echo to the channel', error))
}

/**
 * @param {Channel} channel
 * @param {any} payload
 */
function push(channel, payload) {
  channel.push('push', payload)
}

/**
 * @param {Channel} channel
 * @param {any} payload
 */
function broadcast(channel, payload) {
  channel.push('broadcast', payload)
}
