import { Channel, Socket } from 'phoenix'

const socket = new Socket('/socket', Socket, { params: { token: window.userToken } })
socket.connect()

export const gameModule = {
  channelNew,
  channelJoin,
  channelLeave,
  positionIsland,
  setIslands,

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
