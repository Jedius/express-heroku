mong = glob.modules.mongoose
schema = mong.Schema

user = new schema
    email: String
    password: String
    name: String
    twitterName: String
    twitterId: Number
    twitterToken: String
    twitterSecret: String
    facebookName: String
    facebookId: String
    facebookToken: String
    linkedinName: String
    linkedinId: String
    linkedinToken: String
    linkedinSecret: String
    date:
        type: Date
        default: Date.now

module.exports =
  user: mong.model 'user', user
