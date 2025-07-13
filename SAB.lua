loadstring(game:HttpGet("https://raw.githubusercontent.com/ug32-C9/Velonix-UI-Library/refs/heads/main/Main3.lua"))()

createWindow("Velonix Hub", 28)
createLogo(121332021347640)
createOpen(121332021347640)

-- Home
createTab("Home", 1)
createLabel("Made By Velonix Studio" 1)
createDivider(1)
createToggle("Anti-Kick", 1, true, function(s)
    loadstring(game:HttpGet("https://pastebin.com/raw/5yC1KgYG"))()
end)

-- Main
createTab("Main", 2)
createLabel("Label" 2)
createButton("Button", 2, function()
    print("Button Clicked!")
    Console("Button Clicked!")
end)
createDivider(2)
createToggle("Toggle", 2, false, function(s)
    print("Toggled: "..tostring(s))
    Console("Toggled: "..tostring(s))
end)

-- Settings
createSettingButton("Rejoin", function()
    print("Setting Button clicked!") 
    Console("Setting Button clicked!") 
end)

createNotify("Steal a Brainrot:", "Velonix Hub Loaded Successfully!")