
/*
query GetQueues {
  queues (
    sortBy: "name"
    sortOrder: "ASC"
  ) {
    id
    name
    current_version
  }
}
*/

const {
    createCharactersResolver,
    createCharacterResolver,
    createCreateCharacterMutation,
} = require('./resolvers/characters.resolver')

const {
    fetchqQueuesResolver,
    createQueueResolver,
} = require('./resolvers/fetchq.queues.resolver')

const createResolver = () => ({
    hello: () => 'Hello world!',
    foo: () => 123,
    faa: () => [ 'hello', 'world' ],
    characters: createCharactersResolver(),
    character: createCharacterResolver(),
    createCharacter: createCreateCharacterMutation(),

    queues: fetchqQueuesResolver(),
    createQueue: createQueueResolver(),
})

module.exports = {
    createResolver,
}
