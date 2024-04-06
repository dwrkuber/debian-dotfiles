hs.hotkey.bind({"ctrl", "option"}, "t", function()
    if not hs.application.find('Kitty') then
        hs.alert('Launching Terminal')
    end
    hs.application.launchOrFocus('Kitty')
end)


hs.hotkey.bind({ "cmd", "shift" }, "l", function()
    output, status, termType = hs.execute("lpass show onelogin.com --password", true)
    hs.pasteboard.setContents(output)
    hs.alert('Onelogin password copied. Paste the same now')
end)