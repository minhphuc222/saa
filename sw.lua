-- Chống kick
hookfunction(game.Players.LocalPlayer.Kick, newcclosure(function(...) return nil end))

-- Cho phép luôn được đánh
local mt = getrawmetatable(game)
setreadonly(mt, false)
local oldIndex = mt.__index
mt.__index = newcclosure(function(t, k)
    if tostring(t) == "CombatUtil" and k == "CanAttack" then
        return function() return true end
    end
    return oldIndex(t, k)
end)

-- RemoteEvent cần dùng
local RegisterAttack = game.ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Net")["RE/RegisterAttack"]
local RegisterHit = game.ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Net")["RE/RegisterHit"]

-- Cờ kiểm soát đánh
local canHit = true

-- Vòng lặp đánh
game:GetService("RunService").Heartbeat:Connect(function()
    if not canHit then return end

    local player = game.Players.LocalPlayer
    local char = player.Character
    if not char then return end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    local tool = char:FindFirstChildOfClass("Tool")
    if not (hrp and tool) then return end

    local weaponType = tool:GetAttribute("WeaponType")
    if weaponType ~= "Melee" and weaponType ~= "Sword" then return end

    for _, group in ipairs({workspace.Enemies, workspace.Characters}) do
        for _, enemy in ipairs(group:GetChildren()) do
            if enemy ~= char then
                local eHrp = enemy:FindFirstChild("HumanoidRootPart")
                local eHum = enemy:FindFirstChild("Humanoid")
                if eHrp and eHum and eHum.Health > 0 and (hrp.Position - eHrp.Position).Magnitude <= 50 then
                    local hitPart = enemy:FindFirstChild("Head") or eHrp

                    -- Đánh
                    RegisterAttack:FireServer()
                    RegisterHit:FireServer(
                        hitPart,
                        {
                            {enemy, hitPart},
                            eHrp
                        },
                        {},
                        tostring(player.UserId):sub(2, 4)..tostring(tick()):sub(11, 15)
                    )

                    -- Delay ngắn tránh spam
                    canHit = false
                    task.delay(.00001, function()
                        canHit = true
                    end)
                    return -- đánh xong 1 enemy thì thoát vòng
                end
            end
        end
    end
end)
