let greetingExpressions = list{
  "bonjour",
  "salut",
  "salutation",
  "salutations",
  "hi",
  "hello",
  "hey",
}

let greetingRegexes = List.map(expression => Utils.buildRegex(expression), greetingExpressions)

let responses = [
  `Hi <@{{user}}> !`,
  `Oh <@{{user}}> ! Ravi de te revoir !`,
  `Oh <@{{user}}> ! Ravi de te revoir ! J'espère que tout va pour le mieux ?`,
  `Bonjour <@{{user}}> !`,
  `Salut <@{{user}}> ! Je te souhaite une agréable journée ?`,
  `Coucou <@{{user}}> !`,
]

let isGreeting = (botId, threadId, text) => {
  switch (botId, threadId) {
  | (None, None) => Utils.testRegexes(text, greetingRegexes)
  | _ => false
  }
}

let greet = user => Template.render(Utils.random(responses), {"user": user})
