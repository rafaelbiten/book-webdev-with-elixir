// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import 'phoenix_html'
// Establish Phoenix Socket and LiveView configuration.
import { Socket } from 'phoenix'
import { LiveSocket } from 'phoenix_live_view'
import topbar from '../vendor/topbar'
import { gameModule } from './game.module'

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: '#29d' }, shadowColor: 'rgba(0, 0, 0, .3)' })
globalThis.addEventListener('phx:page-loading-start', _info => topbar.show(300))
globalThis.addEventListener('phx:page-loading-stop', _info => topbar.hide())

// liveSocket.enableDebug()
// liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// liveSocket.disableLatencySim()
const csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute('content')
globalThis.liveSocket = new LiveSocket('/live', Socket, { params: { _csrf_token: csrfToken } })
liveSocket.connect()

// -- GAME

const channel = gameModule.channelNew('islands')
gameModule.channelJoin(channel)

channel.on('player_added', ({ player }) => console.log('A player joined the game:', player))
channel.on('islands_set', ({ player }) => console.log('A player finished setting its islands:', player))
channel.on('coordinate_guessed', ({ player, ...results }) =>
  results.won
    ? console.log(`Player ${player} won the game!`)
    : console.log(`Player ${player} guess results`, results)
)

globalThis.p1 = createPlayer('p1')
globalThis.p2 = createPlayer('p2')

/**
 * Leaving this example here as a reference of how an entire game would work.
 * (Assuming that each player would join from a different browser session)
 *
 * From the browser console:
 *
 * p1.startGame()
 * p2.joinGame()
 * p1.positionIslands()
 * p2.positionIslands()
 * p1.setIslands()
 * p2.setIslands()
 * p1.guessCoordinate({ row: 1, col: 1 })
 * p2.guessCoordinate({ row: 1, col: 2 })
 * ...
 * p1.guessCoordinate({ row: 2, col: 2 })
 * p1.guessCoordinate({ row: 2, col: 3 })
 * p1.guessCoordinate({ row: 3, col: 2 })
 * p1.guessCoordinate({ row: 3, col: 3 })
 *
 * To get the game state:
 * pid = GameSupervisor.find_game_by_name("islands")
 * Game.get_state pid
 */

/**
 * @property {string} player
 */
function createPlayer(player) {
  return {
    startGame: () => gameModule.startGame(channel, player),
    joinGame: () => gameModule.addPlayer(channel, player),
    positionIslands: () => {
      gameModule.positionIsland(channel, { player, shape: 'dot', col: 1, row: 1 })
      gameModule.positionIsland(channel, { player, shape: 'square', col: 2, row: 2 })
    },
    setIslands: () => gameModule.setIslands(channel, { player }),
    guessCoordinate: ({ row, col }) => gameModule.guessCoordinate(channel, { player, row, col }),
  }
}
