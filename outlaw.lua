local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

local startZ = 30000
local endZ = -49032.99
local stepZ = -2000
local duration = 0.5
local teleportCount = 10 -- TP 10 times
local teleportDelay = 0.1 -- 0.1-second delay between TPs
local outlawCampFound = false
local outlawCampPosition = nil
local closestGun = nil
local closestChair = nil
local closestGunDistance = math.huge
local closestChairDistance = math.huge

-- Notification loop
spawn(function()
    while true do
        StarterGui:SetCore("SendNotification", {
            Title = "RINGTA MADE THIS!",
            Text = "discord.gg/ringta",
            Icon = "rbxassetid://99581962287910",
            Duration = 5
        })
        task.wait(20)
    end
end)

-- Find the closest MaximGun in the workspace
for _, item in ipairs(workspace:GetDescendants()) do
    if item:IsA("Model") and item.Name == "MaximGun" and item.PrimaryPart then
        local distance = (humanoidRootPart.Position - item.PrimaryPart.Position).Magnitude
        if distance < closestGunDistance then
            closestGun = item
            closestGunDistance = distance
        end
    end
end

-- Find the closest Chair in the workspace (as fallback)
for _, chair in ipairs(workspace:GetDescendants()) do
    if chair.Name == "Chair" then
        local seat = chair:FindFirstChild("Seat")
        if seat then
            local distance = (humanoidRootPart.Position - seat.Position).Magnitude
            if distance < closestChairDistance then
                closestChair = seat
                closestChairDistance = distance
            end
        end
    end
end

-- Tween search for OutlawCamp
for z = startZ, endZ, stepZ do
    if outlawCampFound then break end

    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
    local goal = {CFrame = CFrame.new(Vector3.new(57, 3, z))}
    local tween = TweenService:Create(humanoidRootPart, tweenInfo, goal)
    tween:Play()
    tween.Completed:Wait()

    local randomBuildings = workspace:FindFirstChild("RandomBuildings")
    if randomBuildings then
        local outlawCamp = randomBuildings:FindFirstChild("OutlawCamp")
        if outlawCamp and outlawCamp.PrimaryPart then
            outlawCampFound = true
            outlawCampPosition = outlawCamp.PrimaryPart.Position
            print("OutlawCamp found at:", outlawCampPosition)

            -- Teleport and attempt to sit
            for i = 1, teleportCount do
                humanoidRootPart.CFrame = CFrame.new(outlawCampPosition)
                task.wait(teleportDelay) -- Wait before sitting

                if closestGun then
                    local seat = closestGun:FindFirstChild("VehicleSeat")
                    if seat and seat.Parent then
                        humanoidRootPart.CFrame = seat.CFrame * CFrame.new(0, 1, 0) -- Align with seat
                        seat:Sit(humanoid)
                        print("Seated on the closest MaximGun.")
                        task.wait(1) -- Allow sit action to complete
                        if humanoid.SeatPart == seat then break end -- Stop teleporting if seated successfully
                    end
                elseif closestChair then
                    humanoidRootPart.CFrame = closestChair.CFrame * CFrame.new(0, 1, 0) -- Align with seat
                    closestChair:Sit(humanoid)
                    print("No MaximGun found, seated on the closest Chair instead.")
                    task.wait(1) -- Allow sit action to complete
                    if humanoid.SeatPart == closestChair then break end -- Stop teleporting if seated successfully
                end
            end
        end
    end
end
