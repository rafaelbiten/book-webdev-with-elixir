import { Channel, Socket } from 'phoenix'

const socket = new Socket('/socket', Socket, { params: { token: window.userToken } })
socket.connect()

export const gameModule = {
  channelNew,
  channelJoin,
  channelLeave,
  positionIsland,

  // game related
  startGame,
  addPlayer,
}

/**
 * @param {string} subtopic
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
    .receive('error', error => console.error(`Error @ ${channelJoin.name}`, error))
}

/** @param {Channel} channel */
function channelLeave(channel) {
  channel
    .leave()
    .receive('ok', () => console.log(`Left "${channel.topic}"`))
    .receive('error', error => console.error(`Error @ ${channelLeave.name}`, error))
}

/** @param {Channel} channel */
function startGame(channel) {
  channel
    .push('start_game')
    .receive('ok', ({ player }) => console.log(`Game started for player: ${player}`))
    .receive('error', error => {
      if (error.includes(':already_started')) return console.log('Game resumed!')

      console.error(`Error @ ${startGame.name}`, error)
    })
}

/**
 * @param {Channel} channel
 * @param {string} name
 */
function addPlayer(channel, name) {
  channel.push('add_player', name).receive('error', error => console.error(`Error @ ${addPlayer.name}`, error))
}

/**
 * @param {Channel} channel
 * @param {PositionIsland} payload
 */
function positionIsland(channel, payload) {
  channel
    .push('position_island', payload)
    .receive('ok', response => console.log('Island positioned', response))
    .receive('error', error => console.error(`Error @ ${positionIsland.name}`, error))
}

/**
 * @typedef {Object} PositionIsland
 * @property {string} player
 * @property {string} shape
 * @property {number} col
 * @property {number} row
 */
