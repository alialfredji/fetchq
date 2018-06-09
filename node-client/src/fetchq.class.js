const winston = require('winston')
const { Pool } = require('pg')

class Fetchq {
    constructor (config = {}) {
        this.pool = new Pool()
        this.logger = new winston.Logger({
            level: config.logLevel || 'verbose',
            transports: [
                new (winston.transports.Console)(),
            ]
        })
    }

    async connect () {
        try {
            const res = await this.pool.query('SELECT NOW()')
            this.logger.verbose(`[fetchq] now is: ${res.rows[0].now}`)
        } catch (err) {
            this.logger.error(`[fetchq] ${err.message}`)
            this.logger.debug(err)
            throw new Error('[fetchq] Could not connect to Postgres')
        }
    }

    async init () {
        try {
            await this.pool.query('CREATE EXTENSION IF NOT EXISTS fetchq;')
            const res = await this.pool.query('SELECT * FROM fetchq_init()')
            return res.rows[0]
        } catch (err) {
            this.logger.debug(err)
            throw new Error(`[fetchq] info() - ${err.message}`)
        }
    }

    async info () {
        try {
            const q = 'SELECT * FROM fetchq_info()'
            const res = await this.pool.query(q)
            return res.rows[0]
        } catch (err) {
            this.logger.debug(err)
            throw new Error(`[fetchq] info() - ${err.message}`)
        }
    }

    // @TODO: validate queue name
    async createQueue (name) {
        try {
            const q = `SELECT * FROM fetchq_create_queue('${name}')`
            const res = await this.pool.query(q)
            return res.rows[0]
        } catch (err) {
            this.logger.debug(err)
            throw new Error(`[fetchq] createQueue() - ${err.message}`)
        }
    }
    
    // @TODO: validate queue name
    async dropQueue (name) {
        try {
            const q = `SELECT * FROM fetchq_drop_queue('${name}')`
            const res = await this.pool.query(q)
            return res.rows[0]
        } catch (err) {
            this.logger.debug(err)
            throw new Error(`[fetchq] dropQueue() - ${err.message}`)
        }
    }

    // @TODO: validate queue name
    // @TODO: validate queue subject
    // @TODO: validate queue version
    // @TODO: validate queue priority
    // @TODO: validate queue nextIteration
    // @TODO: validate queue payload
    async push(queue, doc = {}) {
        try {
            const q = [
                'SELECT * FROM fetchq_push(',
                `'${queue}',`,
                `'${doc.subject}',`,
                `${doc.version || 0},`,
                `${doc.priority || 0},`,
                doc.nextIteration ? `'${doc.nextIteration}',` : 'NOW(),',
                `'${JSON.stringify(doc.payload || {}).replace(/'/g, '\'\'\'\'')}'`,
                ')'
            ].join(' ')
            console.log(q)
            const res = await this.pool.query(q)
            return res.rows[0]
        } catch (err) {
            this.logger.debug(err)
            throw new Error(`[fetchq] push() - ${err.message}`)
        }
    }
}

module.exports = {
    Fetchq
}
