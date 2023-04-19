fmt = import('fmt')

function touch_command(args, session)
    raw_path = args:Get('raw')

    if raw_path == nil or raw_path == '' then
        out = fmt.Sprintf("touch: missing file operand\nTry 'touch --help' for more information.\n")
        session:TermWrite(out)
        return
    end

    err = session.VFS:WriteFile(raw_path, '')

    if err ~= nil and err:Error() ~= 'file is a directory' then
        out = fmt.Sprintf("touch: cannot touch '%s': %s\n", raw_path, err:Error())
        session:TermWrite(out)
        return
    end
end
