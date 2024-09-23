local repo = 'https://raw.githubusercontent.com/mstudio45/LinoriaLib/main/'

local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

-- Create the main window
local Window = Library:CreateWindow({
	Title = 'X Hub - 3008',
	Center = true,
	AutoShow = true,
	Resizable = true,
	ShowCustomCursor = true,
	TabPadding = 8,
	MenuFadeTime = 0.2
})

-- Add watermark for LocalPlayer's FPS and Ping
Library:SetWatermarkVisibility(true)
local function updateWatermark()
	local fps = math.floor(1 / task.wait())
	local ping = math.floor(game:GetService('Stats').Network.ServerStatsItem['Data Ping']:GetValue())
	Library:SetWatermark(('X Hub - 3008 | FPS: %s | Ping: %s ms'):format(fps, ping))
end
local WatermarkConnection = game:GetService('RunService').RenderStepped:Connect(updateWatermark)

-- Create Tabs
local Tabs = {
	Main = Window:AddTab('Main'),
	['UI Settings'] = Window:AddTab('UI Settings'),
}

-- Services
local PS = game:GetService("Players")
local WS = game:GetService("Workspace")
local RS = game:GetService("RunService")
local Camera = WS.CurrentCamera
local Player = PS.LocalPlayer
local LocalizationService = game:GetService("LocalizationService")
local PlayerCountryCode = LocalizationService:GetCountryRegionForPlayerAsync(Player)
local PlayerGui = Player:WaitForChild("PlayerGui")
local Character = Player.Character or Player.CharacterAdded:Wait()
local Backpack = Player:WaitForChild("Backpack")
local HumanoidRoot = Character:WaitForChild("HumanoidRootPart")
local ItemsFolder = WS:WaitForChild("GameObjects").Physical.Items
local Storage = PlayerGui:WaitForChild("MainGui").Menus.Inventory
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

-- Main Groupboxes
local ItemGroupBox = Tabs.Main:AddLeftGroupbox('Item Collection')
local MusicGroupBox = Tabs.Main:AddRightGroupbox('Music')
local StatsGroupBox = Tabs.Main:AddLeftGroupbox('Player Stats')

-- Variables
local OldCFrame = HumanoidRoot.CFrame
local TimesToTeleport = 50
local Radius = 100
local Noclipping = nil
-- ESP and Tracer Variables
local espEnabled = false
local espConnections = {}
local tracers = {}
-- fb
local oldAmbient = Lighting.Ambient
local oldBrightness = Lighting.Brightness
local oldClockTime = Lighting.ClockTime
local oldFogEnd = Lighting.FogEnd
local oldGlobalShadows = Lighting.GlobalShadows

-- Functions
local function AutoCollect()
    	--Created by Qcalnik (Edited)
    
    --[[ Settings ]]
    local TimesToTeleport = 50
    local Radius = 100
    
    --[[ Variables ]]
    local PS = game:GetService("Players")
    local WS = game:GetService("Workspace")
    local Player = PS.LocalPlayer
    local PlayerGui = Player:WaitForChild("PlayerGui")
    local Character = PS.LocalPlayer.Character or PS.LocalPlayer.CharacterAdded:Wait()
    local Backpack = Player:WaitForChild("Backpack")
    local HumanoidRoot = Character:WaitForChild("HumanoidRootPart")
    local ItemsFolder = WS:WaitForChild("GameObjects").Physical.Items
    local Storage = PlayerGui:WaitForChild("MainGui").Menus.Inventory
    
    --[[ Remotes ]]
    local Pickup  = Character.System.Action
    
    
    local OldCFrame = HumanoidRoot.CFrame 
    local OldPosition = HumanoidRoot.Position 
    
    function Check(Object)
    	if Object.Name == "Crowbar" then
    		return false
    	end
    	if Object:FindFirstChildOfClass("Part") or Object:FindFirstChildOfClass("MeshPart") then
    		local Part = Object:FindFirstChildOfClass("Part") or Object:FindFirstChildOfClass("MeshPart")
    		local Distance = (OldPosition - Part.Position).magnitude
    		if Distance < Radius then
    			return false
    		end
    		return true, Part
    	end
    	return false
    end
    
    function InvetoryCheck()
    	local StorageAmount = Storage.UpperLine.Storage
    	if StorageAmount.Text == "16/16 items" or StorageAmount.Text == "17/16 items" then
    		HumanoidRoot.CFrame = OldCFrame
    		wait()
    		for i,v in pairs(Backpack:GetChildren()) do
    			
    			local A_1 = "Inventory_DropAll"
    			local A_2 = 
    				{
    					["Tool"] = v.Name
    				}
    			Pickup:InvokeServer(A_1, A_2)
    
    		end
    		repeat task.wait() until StorageAmount.Text == "0/16 items"
    	end
    	return "Done"
    end
    
    local Amount = 0
    for i,v in pairs(WS:GetDescendants()) do
    	if v.Name == "Apple" or v.Name == "Banana" or v.Name == "Bloxy Soda" or v.Name == "Burger" or v.Name == "Cookie" or v.Name == "Dr. Bob Soda" or v.Name == "Hotdog" or v.Name == "Ice Cream" or v.Name == "Lemon" or v.Name == "Lemon Slice" or v.Name == "Medkit" or v.Name == "Pizza" or v.Name == "Water" or v.Name == "2 Litre Dr. Bob" then         --trollll
    		if v:FindFirstChild(v.Name) or v:FindFirstChild("Root") then
    			local Bool, Part = Check(v)
    			if Bool then
    				Amount = Amount + 1
    				if Amount >= TimesToTeleport then
    					HumanoidRoot.CFrame = OldCFrame
    					return;
    				else
    					repeat task.wait()
    						repeat task.wait() until InvetoryCheck() == "Done"
    						Bool, Part = Check(v)
    						if Part ~= nil then
    							HumanoidRoot.CFrame = Part.CFrame 
    							
    							local A_1 = "Store"
    							local A_2 = 
    								{
    									["Model"] = v
    								}
    					
    							Pickup:InvokeServer(A_1, A_2)
    						end
    					until Part == nil
    				end
    			end
    		end	
    	end
    end
end

-- Function to stop all playing sounds
local function stopAllSounds()
    -- Iterate through all descendants in the Workspace
    for _, obj in pairs(WS:GetDescendants()) do
        -- Check if the object is a sound and is currently playing
        if obj:IsA("Sound") and obj.IsPlaying then
            -- Stop the sound
            obj:Stop()
        end
    end
end

local function createESP(player)
    if player == Player then return end
    
    -- Highlight
    local highlight = Instance.new("Highlight")
    highlight.FillColor = Color3.new(1, 0, 0)
    highlight.OutlineColor = Color3.new(1, 1, 1)
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.Adornee = player.Character
    highlight.Parent = player.Character
    
    -- Tracer
    local tracer = Drawing.new("Line")
    tracer.Visible = false
    tracer.Color = Color3.new(1, 0, 0)
    tracer.Thickness = 1
    tracer.Transparency = 1
    tracers[player] = tracer
    
    -- Update ESP
    local function updateESP()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local vector, onScreen = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
            if onScreen then
                tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                tracer.To = Vector2.new(vector.X, vector.Y)
                tracer.Visible = true
            else
                tracer.Visible = false
            end
        else
            tracer.Visible = false
        end
    end
    
    -- Connections
    local connection = game:GetService("RunService").RenderStepped:Connect(updateESP)
    table.insert(espConnections, connection)
    
    local charAddedConnection = player.CharacterAdded:Connect(function(char)
        highlight.Adornee = char
        highlight.Parent = char
    end)
    table.insert(espConnections, charAddedConnection)
end

local function removeESP(player)
    if player.Character then
        local highlight = player.Character:FindFirstChild("Highlight")
        if highlight then
            highlight:Destroy()
        end
    end
    
    local tracer = tracers[player]
    if tracer then
        tracer:Remove()
        tracers[player] = nil
    end
end

-- Server Hop Function
local function serverHop()
    local TeleportService = game:GetService("TeleportService")
    local HttpService = game:GetService("HttpService")
    local servers = {}
    local req = HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. game.PlaceId .. '/servers/Public?sortOrder=Asc&limit=100'))
    for i,v in pairs(req.data) do
        if v.playing ~= v.maxPlayers then
            table.insert(servers, v.id)
        end
    end
    if #servers > 0 then
        TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)])
    else
        print("Couldn't find a server.")
    end
end

-- Rejoin Function
local function rejoin()
    local TeleportService = game:GetService("TeleportService")
    TeleportService:Teleport(game.PlaceId, Player)
end

-- ui content
local autocollectBtn = ItemGroupBox:AddButton({
	Text = 'Auto Collect items',
	Tooltip = 'Starts collecting items for you until max.',
	Func = function()
		AutoCollect()
	end
})

-- Music Control
local function AddMusicButtons()
	for _, sound in pairs(WS.GameObjects.SoundFolder.GameSoundtrack.StateThemes.DayThemes:GetChildren()) do
		if sound:IsA("Sound") then
			MusicGroupBox:AddButton({
				Text = 'Play ' .. sound.Name,
				Func = function()
					for _, s in pairs(WS.GameObjects.SoundFolder.GameSoundtrack.StateThemes.DayThemes:GetChildren()) do
						if s:IsA("Sound") then s:Stop() end
					end
					sound.Volume = sound.Volume * 2
					sound:Play()
				end
			})
		end
	end
end
AddMusicButtons()

local stopSoundButton = MusicGroupBox:AddButton({
    Text = 'Stop all Sounds',
    Func = function()
        stopAllSounds()
    end
})

-- Player Stats Control
StatsGroupBox:AddSlider('PlayerSpeed', {
	Text = 'Player Speed',
	Default = Character.Humanoid.WalkSpeed,
	Min = 16,
	Max = 100,
	Rounding = 0,
	Callback = function(Value)
		Character.Humanoid.WalkSpeed = Value
	end
})

StatsGroupBox:AddSlider('JumpPower', {
	Text = 'Jump Power',
	Default = Character.Humanoid.JumpPower,
	Min = 50,
	Max = 200,
	Rounding = 0,
	Callback = function(Value)
		Character.Humanoid.JumpPower = Value
	end
})

StatsGroupBox:AddToggle('Fullbright', {
    Text = 'Fullbright',
    Default = false,
    Tooltip = 'Removes all darkness',
    Callback = function(Value)
        if Value then
            Lighting.Ambient = Color3.new(1, 1, 1)
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.FogEnd = 100000
            Lighting.GlobalShadows = false
        else
            Lighting.Ambient = oldAmbient
            Lighting.Brightness = oldBrightness
            Lighting.ClockTime = oldClockTime
            Lighting.FogEnd = oldFogEnd
            Lighting.GlobalShadows = oldGlobalShadows
        end
    end
})

StatsGroupBox:AddToggle('PlayerESP', {
    Text = 'Player ESP',
    Default = false,
    Tooltip = 'Highlight other players and show tracers',
    Callback = function(Value)
        espEnabled = Value
        if espEnabled then
            for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
                createESP(player)
            end
            table.insert(espConnections, game:GetService("Players").PlayerAdded:Connect(createESP))
            table.insert(espConnections, game:GetService("Players").PlayerRemoving:Connect(removeESP))
        else
            for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
                removeESP(player)
            end
            for _, connection in ipairs(espConnections) do
                connection:Disconnect()
            end
            espConnections = {}
        end
    end
})

StatsGroupBox:AddToggle('Noclip', {
    Text = 'Noclip',
    Default = false,
    Tooltip = 'Walk through walls',
    Callback = function(Value)
        if Value then
            Noclipping = game:GetService('RunService').Stepped:Connect(function()
                if Player.Character ~= nil then
                    for _, child in pairs(Player.Character:GetDescendants()) do
                        if child:IsA("BasePart") and child.CanCollide == true then
                            child.CanCollide = false
                        end
                    end
                end
            end)
        else
            if Noclipping then
                Noclipping:Disconnect()
            end
        end
    end
})

-- server Hop

local servHop = StatsGroupBox:AddButton({
    Text = 'Server Hop',
    Func = function()
        serverHop()
    end
})
-- Rejoin Function
local rejoinbutton = StatsGroupBox:AddButton({
    Text = 'Rejoin',
    Tooltip = 'Rejoin server',
    Func = function()
        rejoin()
    end
})
    
-- UI Settings Tab
local MenuGroup = Tabs['UI Settings']:AddLeftGroupbox('Menu')
MenuGroup:AddButton('Unload', function() Library:Unload() end)
MenuGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', { Default = 'End', NoUI = true, Text = 'Menu keybind' })

Library.ToggleKeybind = Options.MenuKeybind -- Allows you to have a custom keybind for the menu
Library.KeybindFrame.Visible = false -- Show the keybind frame

-- Hand the library over to our managers
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

-- Ignore keys that are used by ThemeManager.
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ 'MenuKeybind' })

-- Set folders for ThemeManager and SaveManager
ThemeManager:SetFolder('XHub')
SaveManager:SetFolder('XHub/3008')

-- Builds config and theme menus
SaveManager:BuildConfigSection(Tabs['UI Settings'])
ThemeManager:ApplyToTab(Tabs['UI Settings'])
SaveManager:LoadAutoloadConfig()

-- Unload function
Library:OnUnload(function()
	WatermarkConnection:Disconnect()
	print('Unloaded!')
	Library.Unloaded = true
	for _, connection in ipairs(espConnections) do
        connection:Disconnect()
    end
    for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
        removeESP(player)
    end
    for _, tracer in pairs(tracers) do
        tracer:Remove()
    end
end)
