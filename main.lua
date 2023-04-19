fmt = import('fmt')
time = import('time')

require('ls')
require('cat')
require('cd')
require('pwd')
require('mkdir')
require('touch')
require('clear')

function password_auth(username, password, ip)
    fmt.Println('From Lua:', username, password, ip)
    res = db.query('select * from password_connections where ip_address = ?', ip:String())

    if username == 'test' and password == 'test' then
        return true
    end

    return false
end

function install(config)
    str = fmt.Sprintf('testing here %q everything', 'something')
    fmt.Println('Hello', str, time.Now():Unix(), str)
    config:RegisterCommand('ls', '/bin', ls_command)
    config:RegisterCommand('cat', '/bin', cat_command)
    config:RegisterCommand('cd', '/bin', cd_command)
    config:RegisterCommand('pwd', '/bin', pwd_command)
    config:RegisterCommand('mkdir', '/bin', mkdir_command)
    config:RegisterCommand('touch', '/bin', touch_command)
    config:RegisterCommand('clear', '/bin', clear_command)
    config:RegisterPasswordIntercept(password_auth)
end
