type t

let token = Settings.slackToken

module SlackJS = {
  @bs.module @bs.new external _new: string => t = "slack"

  module Chat = {
    type c
    @bs.get external chat: t => c = "chat"
    @bs.send external postMessage: (c, 'a) => Js.Promise.t<'b> = "postMessage"
  }

  module Conversations = {
    type c
    @bs.get external conversations: t => c = "conversations"
    @bs.send external members: (c, 'a) => Js.Promise.t<'b> = "members"
  }
}

let make = token => SlackJS._new(token)

module Block = {
  type t =
    | Divider
    | Section(string)
    | SectionWithAccessory(string, string, string)
    | Context(string, string, string)
    | Header(string)
    | Image(string, string)

  let buildText = text =>
    [("type", Js.Json.string("mrkdwn")), ("text", Js.Json.string(text))]
    |> Js.Dict.fromArray
    |> Js.Json.object_

  let buildPlainText = text =>
    [
      ("type", Js.Json.string("plain_text")),
      ("text", Js.Json.string(text)),
      ("emoji", Js.Json.boolean(true)),
    ]
    |> Js.Dict.fromArray
    |> Js.Json.object_

  let buildImage = (url, alt_text) =>
    [
      ("type", Js.Json.string("image")),
      ("image_url", Js.Json.string(url)),
      ("alt_text", Js.Json.string(alt_text)),
    ]
    |> Js.Dict.fromArray
    |> Js.Json.object_

  let buildContext = (textContent, image_url, alt_text) => {
    let text = buildText(textContent)
    let image = buildImage(image_url, alt_text)
    [("type", Js.Json.string("context")), ("elements", Js.Json.array([image, text]))]
    |> Js.Dict.fromArray
    |> Js.Json.object_
  }

  let buildSession = text => {
    let textJson = Js.Json.object_(
      Js.Dict.fromArray([("type", Js.Json.string("mrkdwn")), ("text", Js.Json.string(text))]),
    )
    Js.Json.object_(Js.Dict.fromArray([("type", Js.Json.string("section")), ("text", textJson)]))
  }

  let buildSessionWithAccessory = (textContent, image_url, alt_text) => {
    let text = buildText(textContent)
    let accessory = buildImage(image_url, alt_text)
    Js.Json.object_(
      Js.Dict.fromArray([
        ("type", Js.Json.string("section")),
        ("text", text),
        ("accessory", accessory),
      ]),
    )
  }

  let buildHeader = textContent => {
    let text = buildPlainText(textContent)
    [("type", Js.Json.string("header")), ("text", text)] |> Js.Dict.fromArray |> Js.Json.object_
  }

  let build = block => {
    let attributes = switch block {
    | Divider => [("type", Js.Json.string("divider"))] |> Js.Dict.fromArray |> Js.Json.object_
    | Section(text) => buildSession(text)
    | SectionWithAccessory(text, image_url, alt_text) =>
      buildSessionWithAccessory(text, image_url, alt_text)
    | Context(text, image_url, alt_text) => buildContext(text, image_url, alt_text)
    | Header(text) => buildHeader(text)
    | Image(image_url, alt_text) => buildImage(image_url, alt_text)
    }
    attributes
  }

  let stringify = blocks => {
    Array.map(block => block |> build, blocks) |> Js.Json.array |> Js.Json.stringify
  }
}

let sendMessage = (client, args) => {
  let chat = SlackJS.Chat.chat(client)
  SlackJS.Chat.postMessage(chat, args)
}

let getMembers = (client, channel) => {
  let conversations = SlackJS.Conversations.conversations(client)
  let params = list{("token", token), ("channel", channel)} |> Js.Dict.fromList
  SlackJS.Conversations.members(conversations, params)
  |> Js.Promise.then_(response => Ok(response) |> Js.Promise.resolve)
  |> Js.Promise.catch(error => Error(error) |> Js.Promise.resolve)
}
