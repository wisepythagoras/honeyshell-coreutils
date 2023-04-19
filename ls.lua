fmt = import('fmt')
io = import('io')
strings = import('strings')
filepath = import('filepath')
tabwriter = import('tabwriter')

function clean_path(arg, res, pwd, home)
    if strings.HasPrefix(arg, './') then
        return strings.Replace(res, pwd, '.', 1)
    elseif arg == '.' or arg == pwd then
        return strings.Replace(res, pwd .. '/', '', 1)
    elseif strings.HasPrefix(arg, '/') == true then
    elseif strings.HasPrefix(arg, '~') then
        return strings.Replace(res, home .. '/', '', 1)
    end

    return res
end

function display_directory(session, file)
    bytesWriter = io.CreateWriter()
    w = tabwriter.NewWriter(bytesWriter, 1, 0, 1, toBytes(' ')[1], tabwriter.AlignRight)

    file:ForEach(function(f, i)
        if p == '/' then
            p = ''
        end

        name = clean_path(raw_path, p .. '/' .. f.Name, session:GetPWD(), session.VFS.Home)
        name = strings.Replace(name, '{}', session.User.Username, 1)
        owner = strings.Replace(f.Owner, '{}', session.User.Username, 1)
        size = 4096

        if f.Type == 2 then
            size = string.len(f.Contents)
        end

        if f.Type == 3 then
            size = string.len(f.LinkTo)
            fmt.Fprintf(w, "\b%s\t%.0f\t%s\t%s\t%.0f\t %s -> %s\n", f:StrMode(), f.NLink, owner, owner, size, name, f.LinkTo)
        else
            fmt.Fprintf(w, "\b%s\t%.0f\t%s\t%s\t%.0f\t %s\n", f:StrMode(), f.NLink, owner, owner, size, name)
        end
    end)

    w:Flush()
    session:TermWrite(bytesWriter:String())
end

function ls_command(args, session)
    raw_path = args:Get('raw')

    if raw_path == nil then
        new_path = session:GetPWD()
        raw_path = new_path == '' and '/' or new_path
    end

    if strings.HasPrefix(raw_path, '/home/') then
        raw_path = strings.Replace(raw_path, session.User.Username, '{}', 1)
    end

    p, file = session.VFS:FindFile(raw_path)

    if file ~= nil then
        permissions = file:CanAccess(session.User)

        if file.Type == 1 then
            if permissions.Read == false then
                out = fmt.Sprintf("ls: cannot open directory '%s': Permission denied\n", raw_path)
                session:TermWrite(out)
                return
            end

            bytesWriter = io.CreateWriter()
            w = tabwriter.NewWriter(bytesWriter, 1, 0, 1, toBytes(' ')[1], tabwriter.AlignRight)

            display_directory(session, file)
        elseif file.Type == 2 then
            name = clean_path(raw_path, p, session:GetPWD(), session.VFS.Home)
            name = strings.Replace(name, '{}', session.User.Username, 1)
            owner = strings.Replace(file.Owner, '{}', session.User.Username, 1)
            c_len = string.len(file.Contents)

            out = fmt.Sprintf('%s 1 %s %s %.0f %s\n', file:StrMode(), owner, owner, c_len, name)
            session:TermWrite(out)
        elseif file.Type == 3 then
            linkTo = file.LinkTo

            if strings.HasPrefix(linkTo, '.') then
                linkTo = filepath.Join(session:GetPWD(), linkTo)
            else
                linkTo = filepath.Join('/', linkTo)
            end

            _, file, err = session.VFS:FindFile(linkTo)
            
            if err == nil then
                display_directory(session, file)
            end
        end
    else
        out = fmt.Sprintf("ls: cannot access '%s': No such file or directory\n", raw_path)
        session:TermWrite(out)
    end
end
