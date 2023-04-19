fmt = import('fmt')
strings = import('strings')

function cat_command(args, session)
    raw_path = args:Get('raw')
    version = args:Get('version')

    args:ForEach(function(k, v)
        fmt.Println(k, "=", v)
    end)

    if version ~= nil then
        out = 'cat (GNU coreutils) 8.32\n'
        out = out .. 'Copyright (C) 2020 Free Software Foundation, Inc.\n'
        out = out .. 'License GPLv3+: GNU GPL version 3 or later <https://gnu.org/licenses/gpl.html>.\n'
        out = out .. 'This is free software: you are free to change and redistribute it.\n'
        out = out .. 'There is NO WARRANTY, to the extent permitted by law.\n\n'
        out = out .. 'Written by Torbjorn Granlund and Richard M. Stallman.\n'
        session:TermWrite(out)
        return
    end

    if raw_path == nil then
        session:TermWrite('')
        return
    end

    if strings.HasPrefix(raw_path, '/home/') then
        raw_path = strings.Replace(raw_path, session.Username, '{}', 1)
    end

    pa, file = session.VFS:FindFile(raw_path)

    if file == nil then
        out = fmt.Sprintf('cat: %s: No such file or directory\n', args:Get('raw'))
        session:TermWrite(out)
        return
    elseif file.Type ~= 2 then
        out = fmt.Sprintf('cat: %s: Is a directory\n', args:Get('raw'))
        session:TermWrite(out)
        return
    end

    session:TermWrite(file.Contents)
end
