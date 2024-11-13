local muteMenu = hs.menubar.new()

local function setMuteDisplay(mute)
    local micOff = hs.image.imageFromPath("/Users/jeremie/.hammerspoon/microphone-off-32.png")
    local micOn = hs.image.imageFromPath("/Users/jeremie/.hammerspoon/microphone-on-32.png")
    local sizePix = 20
    if mute then
        muteMenu:autosaveName("mic"):setIcon(micOff:setSize({
            w = sizePix,
            h = sizePix
        }))
    else
        muteMenu:autosaveName("mic"):setIcon(micOn:setSize({
            w = sizePix,
            h = sizePix
        }))
    end
end

local function clearMuteAlert()
    if muteAlertId then
        hs.alert.closeSpecific(muteAlertId)
    end
end

local function setMute(mute)
    local audios = hs.audiodevice.allInputDevices()
    for key, value in pairs(audios) do
        print("Key:", key, "Value:", value)
        value:setInputMuted(mute)
    end
    setMuteDisplay(mute)
end

local function getMuteState()
    local audio = hs.audiodevice.defaultInputDevice()
    return audio:inputMuted()
end

local holdingToTalk = false
local function pushToTalk()
    holdingToTalk = true
    local audio = hs.audiodevice.defaultInputDevice()
    local muted = audio:inputMuted()
    if muted then
        clearMuteAlert()
        muteAlertId = hs.alert.show("🎤 Microphone on", true)
        setMute(false)
    end
end

local function toggleMute()
    setMute(not getMuteState())
end

local function toggleMuteOrPTT()
    local muted = getMuteState()
    local muting = not muted
    if holdingToTalk then
        holdingToTalk = false
        setMute(true)
        muting = true
    else
        setMute(muting)
    end
    clearMuteAlert()
    if muting then
        muteAlertId = hs.alert.show("🙊 Microphone muted")
    else
        muteAlertId = hs.alert.show("🎤 Microphone on")
    end
end

hs.hotkey.bind({"cmd", "shift"}, "e", nil, toggleMuteOrPTT, pushToTalk)

if muteMenu then
    muteMenu:setClickCallback(toggleMute)
    local muted = getMuteState()
    setMuteDisplay(muted)
end
