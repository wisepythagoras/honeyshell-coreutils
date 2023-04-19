function clear_command(_, session)
    session:TermWrite("\27c")
end
