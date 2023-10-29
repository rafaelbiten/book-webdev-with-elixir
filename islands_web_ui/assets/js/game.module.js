import { Channel, Socket } from 'phoenix'

const socket = new Socket('/socket', Socket, { params: { token: window.userToken } })
socket.connect()

export const gameModule = {
  channelNew,
  channelJoin,
  channelLeave,

  startGame,
  addPlayer,
  positionIsland,
  setIslands,
  guessCoordinate,
  listPlayers,
}

/**
 * @param {string} subtopic
 * @param {string} display_name
 * @returns Channel
 */
function channelNew(subtopic, display_name) {
  return socket.channel(`game:${subtopic}`, { display_name })
}

/** @param {Channel} channel */
function channelJoin(channel) {
  channel
    .join()
    .receive('ok', () => console.log(`Joined "${channel.topic}"`))
    .receive('error', error => {
      console.error(`Error @ ${channelJoin.name}`, error)
      channel.leave()
    })
}

/** @param {Channel} channel */
function channelLeave(channel) {
  channel
    .leave()
    .receive('ok', () => console.log(`Left "${channel.topic}"`))
    .receive('error', error => console.error(`Error @ ${channelLeave.name}`, error))
}

/**
 * @param {Channel} channel
 * @param {string} player
 */
function startGame(channel, player) {
  channel
    .push('start_game')
    .receive('ok', () => console.log(`Game started for player: ${player}`))
    .receive('error', error => {
      if (error.includes(':already_started')) return console.log('Game resumed!')

      console.error(`Error @ ${startGame.name}`, error)
    })
}

/**
 * @param {Channel} channel
 * @param {string} player
 */
function addPlayer(channel, player) {
  channel.push('add_player', player).receive('error', error => console.error(`Error @ ${addPlayer.name}`, error))
}

/**
 * @param {Channel} channel
 * @param {PositionIsland} payload
 */
function positionIsland(channel, payload) {
  channel
    .push('position_island', payload)
    .receive('ok', () => console.log('Island positioned'))
    .receive('error', error => console.error(`Error @ ${positionIsland.name}`, error))
}

/**
 * @param {Channel} channel
 * @param {SetIslands} payload
 */
function setIslands(channel, payload) {
  channel
    .push('set_islands', payload)
    .receive('ok', response => console.log('Islands set', response))
    .receive('error', error => console.error(`Error @ ${setIslands.name}`, error))
}

/**
 * @param {Channel} channel
 * @param {GuessCoordinate} payload
 */
function guessCoordinate(channel, payload) {
  channel
    .push('guess_coordinate', payload)
    .receive('error', error => console.error(`Error @ ${guessCoordinate.name}`, error))
}

/**
 * @param {Channel} channel
 */
function listPlayers(channel) {
  channel.push('show_subscribers').receive('error', error => console.error(`Error @ ${listPlayers.name}`, error))
}

// -- TYPES

/**
 * @typedef {Object} PositionIsland
 * @property {string} player
 * @property {string} shape
 * @property {number} col
 * @property {number} row
 */

/**
 * @typedef {Object} SetIslands
 * @property {string} player
 */

/**
 * @typedef {Object} GuessCoordinate
 * @property {string} player
 * @property {number} col
 * @property {number} row
 */
