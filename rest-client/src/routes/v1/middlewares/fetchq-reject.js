
const winston = require('winston')

const fetchqReject = () => async (req, res, next) => {
    try {
        const info = await req.fetchq.reject(req.body.queue, req.body.documentId, req.body.message, req.body.details, req.body.refId)
        res.send(info)
    } catch (err) {
        winston.verbose(`post://api/v1/reject - ${err.message}`)
        winston.debug(err)
        next(err)
    }
}

module.exports = {
    fetchqReject,
}