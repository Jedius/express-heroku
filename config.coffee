if process.env.NODE_ENV is 'production'
    config = 
        app: 
            name: 'auth'
            protocol: 'https://'
            domain: '.herokuapp.com'
            port: process.env.PORT or 4600
            maxAge: 3*60*60*1000, #sec
            secretString: 'someSecretString'
            authPerHour: 3
            authPerDay: 9
            host: 'websell.herokuapp.com'
        deployEnv: process.env.DEPLOY_ENV or 'dev'
        redisURL: glob.modules.url.parse(process.env.REDISTOGO_URL)
        mongoURL: process.env.MONGOHQ_URL
        twitter: 
            key: 'JLCGyLzuOK1BjnKPKGyQ'
            secret: 'GNqKfPqtzOcsCtFbGTMqinoATHvBcy1nzCTimeA9M0'
        facebook: 
            key: '350981571633435'
            secret: '57a4f5b5e1e230d9d4cbfb41526ee6c7'
        linkedin:
            key: 'gkto4dor0gbh'
            secret: 't3Dpo7ynhUK4ZzPL'
else
    config = 
        app: 
            name: 'auth'
            protocol: 'http://'
            domain: ''
            port: 4600
            secretString: 'someSecretString'
            maxAge: 3*60*60*1000, #sec
            host: 'localhost'
        redisURL: glob.modules.url.parse 'redis://localhost:6379'
        mongoURL: 'mongodb://localhost/authBabycarrot'
        twitter: 
            key: 'JLCGyLzuOK1BjnKPKGyQ'
            secret: 'GNqKfPqtzOcsCtFbGTMqinoATHvBcy1nzCTimeA9M0'
        facebook: 
            key: '221166708001552'
            secret: '81d1e201a27a00e993ac9aa131f239ec'
        linkedin:
            key: 'gkto4dor0gbh'
            secret: 't3Dpo7ynhUK4ZzPL'

module.exports = config
