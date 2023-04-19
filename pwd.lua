fmt = import('fmt')
strings = import('strings')

function pwd_command(args, session)
    pwd = session:GetPWD()
    
    if strings.HasPrefix(pwd, '/home/{}') then
        pwd = strings.ReplaceAll(pwd, '/home/{}', '/home/' .. session.User.Username)
    end

    if pwd == "" then
        pwd = "/"
    end

    out = fmt.Sprintf('%s\n', pwd)
    session:TermWrite(out)
end
