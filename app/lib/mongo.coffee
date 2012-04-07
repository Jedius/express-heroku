mong = glob.modules.mongoose
schema = mong.Schema

user = new schema
  email: String
  password: String
  twitterName: String
  twitterId: Number
  facebookName: String
  facebookId: Number
  date:
    type: Date
    default: Date.now

module.exports =
  user: mong.model 'user', user
