import { app, errorHandler, uuid } from 'mu'
import { fetchNextSequenceNumber } from './sequence-number'

app.post '/sequence-numbers', (req, res, next) ->
  if req.body.data?.attributes?['resource-type']
    { 'resource-type': type, scope } = req.body.data.attributes
    number = await fetchNextSequenceNumber type, scope

    res.status(201).send(
      data:
        type: 'sequence-numbers'
        id: uuid()
        attributes:
          number: number
    )
  else
    next(new Error('Resource type is missing'))

app.use errorHandler
