Config = {}

Config.RestrictedChannels = 4 -- channels that are encrypted (EMS, Fire and police can be included there) if we give eg 10, channels from 1 - 10 will be encrypted
Config.enableCmd = false --  /radio command should be active or not (if not you have to carry the item "radio") true / false

Config.messages = {
  
  ['not_on_radio'] = 'Et ole radiossa',
  ['on_radio'] = 'Olet jo radiossa: <b>',
  ['joined_to_radio'] = 'Liityit taajuudelle: <b>',
  ['restricted_channel_error'] = 'Tämä taajuus on lukittu!',
  ['you_on_radio'] = 'Olet jo kanavalla: <b>',
  ['you_leave'] = 'Poistuit kanavalta <b>'

}
