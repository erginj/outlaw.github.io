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
local closestDistanceGun = math.huge
local closestDistanceChair = math.huge

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

            -- Find the closest MaximGun
            for _, item in ipairs(outlawCamp:GetDescendants()) do
                if item.Name == "MaximGun" and item.PrimaryPart then
                    local distance = (humanoidRootPart.Position - item.PrimaryPart.Position).Magnitude
                    if distance < closestDistanceGun then
                        closestGun = item
                        closestDistanceGun = distance
                    end
                end
            end

            -- Chair is fallback
            for _, item in ipairs(outlawCamp:GetDescendants()) do
                if item.Name == "Chair" then
                    local seat = item:FindFirstChild("Seat")
                    if seat then
                        local distance = (humanoidRootPart.Position - seat.Position).Magnitude
                        if distance < closestDistanceChair then
                            closestChair = seat
                            closestDistanceChair = distance
                        end
                    end
                end
            end

            -- Teleport 10 times while trying to sit
            for i = 1, teleportCount do
                humanoidRootPart.CFrame = CFrame.new(outlawCampPosition)

                if closestGun then
                    local seat = closestGun:FindFirstChild("VehicleSeat")
                    if seat then
                        character:PivotTo(seat.CFrame)
                        seat:Sit(humanoid)
                        print("Seated on MaximGun.")
                        break -- Stops teleport loop if seated successfully
                    end
                elseif closestChair then
                    character:PivotTo(closestChair.CFrame)
                    closestChair:Sit(humanoid)
                    print("No MaximGun found, seated on Chair instead.")
                    break -- Stops teleport loop if seated successfully
                end

                task.wait(teleportDelay)
            end
        end
    end
end
