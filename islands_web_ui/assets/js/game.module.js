import { Channel, Socket } from 'phoenix'

const socket = new Socket('/socket', Socket, { params: { token: window.userToken } })
socket.connect()

export const gameModule = {
  channelNew,
  channelJoin,
  channelLeave,

  // game related
  startGame,
  addPlayer,
}

/**
 * @param {Socket} socket
 * @param {string} subtopic
 * @param {string} params
 * @returns Channel
 */
function channelNew(subtopic) {
  return socket.channel(`game:${subtopic}`)
}

/** @param {Channel} channel */
function channelJoin(channel) {
  channel
    .join()
    .receive('ok', () => console.log(`Joined "${channel.topic}"`))
    .receive('error', () => console.log(`Unable to join "${channel.topic}"...`))
}

/** @param {Channel} channel */
function channelLeave(channel) {
  channel
    .leave()
    .receive('ok', () => console.log(`Left "${channel.topic}"`))
    .receive('error', () => console.log(`Unable to leave "${channel.topic}"...`))
}

/** @param {Channel} channel */
function startGame(channel) {
  channel
    .push('start_game')
    .receive('ok', ({ player }) => console.log(`Game started for player: ${player}`))
    .receive('error', reason => {
      if (reason.includes(':already_started')) return console.log('Game resumed!')

      console.error(`Unable to start the game: ${reason}`)
    })
}

/**
 * @param {Channel} channel
 * @param {string} name
 */
function addPlayer(channel, name) {
  channel.push('add_player', name).receive('error', reason => console.error(`Unable to add a player: ${reason}`))
}
