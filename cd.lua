fmt = import('fmt')
strings = import('strings')
getopt = require('getopt')

function help()
    out = 'cd: cd [-L|[-P [-e]] [-@]] [dir]\n'
    out = out .. 'Change the shell working directory.\n'
    out = out .. '\n'
    out = out .. 'Change the current directory to DIR.  The default DIR is the value of the\n'
    out = out .. 'HOME shell variable. If DIR is "-", it is converted to $OLDPWD.\n'
    out = out .. '\n'
    out = out .. 'The variable CDPATH defines the search path for the directory containing\n'
    out = out .. 'DIR.  Alternative directory names in CDPATH are separated by a colon (:).\n'
    out = out .. 'A null directory name is the same as the current directory.  If DIR begins\n'
    out = out .. 'with a slash (/), then CDPATH is not used.\n'
    out = out .. '\n'
    out = out .. 'If the directory is not found, and the shell option `cdable_vars\' is set,\n'
    out = out .. 'the word is assumed to be  a variable name.  If that variable has a value,\n'
    out = out .. 'its value is used for DIR.\n'
    out = out .. '\n'
    out = out .. 'Options:\n'
    out = out .. '  -L	force symbolic links to be followed: resolve symbolic\n'
    out = out .. '		links in DIR after processing instances of `..\'\n'
    out = out .. '  -P	use the physical directory structure without following\n'
    out = out .. '		symbolic links: resolve symbolic links in DIR before\n'
    out = out .. '		processing instances of `..\'\n'
    out = out .. '  -e	if the -P option is supplied, and the current working\n'
    out = out .. '		directory cannot be determined successfully, exit with\n'
    out = out .. '		a non-zero status\n'
    out = out .. '  -@	on systems that support it, present a file with extended\n'
    out = out .. '		attributes as a directory containing the file attributes\n'
    out = out .. '\n'
    out = out .. 'The default is to follow symbolic links, as if `-L\' were specified.\n'
    out = out .. '`..\' is processed by removing the immediately previous pathname component\n'
    out = out .. 'back to a slash or the beginning of DIR.\n'
    out = out .. '\n'
    out = out .. 'Exit Status:\n'
    out = out .. 'Returns 0 if the directory is changed, and if $PWD is set successfully when\n'
    out = out .. '-P is used; non-zero otherwise.\n'

    return out
end

function cd_command(args, session)
    raw_path = args:Get('raw')
    pwd = session:GetPWD()

    nonoptions = {}
    argv = args:ArrayWithCommand('cd')
    no_symlinks = false
    xattrflag = false
    eflag = false

    if args:Get('help') == true then
        session:TermWrite(help())
        return
    end

    for opt, arg in getopt(argv, 'eLP@', nonoptions) do
        fmt.Println(opt, arg, nonoptions)
        if opt == 'P' then
            no_symlinks = true
        elseif opt == 'L' then
            no_symlinks = false
        elseif opt == 'e' then
            eflag = true
        elseif opt == '@' then
            xattrflag = true
        else
            out = fmt.Sprintf('bash: cd: -%s: invalid option\n', arg)
            out = out .. 'cd: usage: cd [-L|[-P [-e]] [-@]] [dir]\n'
            session:TermWrite(out)
            return
        end
    end

    if raw_path == nil then
        raw_path = '~'
    end
    
    if strings.HasPrefix(raw_path, '/home/' .. session.User.Username) then
        raw_path = strings.ReplaceAll(raw_path, '/home/' .. session.User.Username, '/home/{}')
    end

    target_path, file = session.VFS:FindFile(raw_path)

    if file == nil then
        out = fmt.Sprintf('bash: cd: %s: No such file or directory\n', args:Get('raw'))
        session:TermWrite(out)
        return
    elseif file.Type == 2 then
        out = fmt.Sprintf('bash: cd: %s: Not a directory\n', args:Get('raw'))
        session:TermWrite(out)
        return
    end

    session:Chdir(target_path)
    session:TermWrite('')
end
