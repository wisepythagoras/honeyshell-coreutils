fmt = import('fmt')
filepath = import('filepath')

function mkdir_command(args, session)
    raw_path = args:Get('raw')

    if raw_path == nil then
        out = fmt.Sprintf("mkdir: missing operand\nTry 'mkdir --help' for more information\n")
        session:TermWrite(out)
        return
    end

    _, err = session.VFS:Mkdir(raw_path, 0)

    if err ~= nil then
        session:TermWrite('mkdir: ' .. err:Error() .. '\n')
        return
    end
end
