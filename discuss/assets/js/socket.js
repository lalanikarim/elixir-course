import { Socket } from "phoenix"

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let socket = new Socket("/socket", { params: { _csrf_token: csrfToken } })
socket.connect()

const createSocket = (topicId) => {
  let channel = socket.channel(`comments:${topicId}`, {})
  channel.join()
    .receive("ok", resp => {
      renderComments(resp.comments)
    })
    .receive("error", resp => { console.error("Unable to join", resp) })

  channel.on(`comments:${topicId}:new`,renderComment)

  document.querySelector('button').addEventListener('click', () => {
    const content = document.querySelector('textarea').value
    channel.push('comment:add', { content: content })
  })
}

function renderComments(comments) {
  const renderedComments = comments.map(comment => {
    return commentTemplate(comment)
  })
  document.querySelector('ul.collection').innerHTML = renderedComments.join('')
}

function renderComment({comment}) {
  const renderedComment = commentTemplate(comment)
  document.querySelector('ul.collection').innerHTML += renderedComment
}

function commentTemplate(comment) {
    return `
      <li class="collection-item">
        ${comment.content}
      </li>
      `
}

window.createSocket = createSocket
