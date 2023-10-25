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
import { Channel, Socket } from 'phoenix'
import { LiveSocket } from 'phoenix_live_view'
import topbar from '../vendor/topbar'
import { gameModule } from './game.module'

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: '#29d' }, shadowColor: 'rgba(0, 0, 0, .3)' })
window.addEventListener('phx:page-loading-start', _info => topbar.show(300))
window.addEventListener('phx:page-loading-stop', _info => topbar.hide())

// liveSocket.enableDebug()
// liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// liveSocket.disableLatencySim()
const csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute('content')
window.liveSocket = new LiveSocket('/live', Socket, { params: { _csrf_token: csrfToken } })
liveSocket.connect()

// -- GAME

window.gameModule = gameModule

const searchParams = new URLSearchParams(location.search)
const player = searchParams.get('player')
const channel = gameModule.channelNew('islands')

gameModule.channelJoin(channel)
channel.on('player_added', ({ player }) => console.log('A second player joined the game:', player))

switch (player) {
  case 'p1':
    gameModule.startGame(channel)
    setTimeout(() => {
      gameModule.positionIsland(channel, { player: 'p1', shape: 'dot', col: 1, row: 1 })
      gameModule.positionIsland(channel, { player: 'p1', shape: 'square', col: 2, row: 2 })
    }, 5000) // give a few seconds for p2 to join the game
    break

  default:
    gameModule.addPlayer(channel, 'p2')
    gameModule.positionIsland(channel, { player: 'p2', shape: 'dot', col: 1, row: 1 })
    gameModule.positionIsland(channel, { player: 'p2', shape: 'square', col: 2, row: 2 })
    break
}

// gameModule.reply(channel, { reply: "reply" })
// gameModule.reply(channel, { reply: "reply" })

// channel.on("push", response => console.log("push: ", response))
// setTimeout(() => gameModule.push(channel, { push: "push" }), 2000)

// channel.on("broadcast", response => console.log("broadcast: ", response))
// gameModule.broadcast(channel, { broadcast: "broadcast" })

// function randomPlayer() {
//   return `${(Date.now() + Math.random().toString(36)).split('.')[1]}`
// }
