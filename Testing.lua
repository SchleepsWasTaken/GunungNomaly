-- Rayfield GUI Teleport Script for [BARU] Gunung Nomaly
-- Compatible with Delta Mobile Executor and PC Executors (e.g., Xeno)
-- Includes teleport through checkpoints in Workspace.Checkpoints and flying mode

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Create the main GUI window
local Window = Rayfield:CreateWindow({
   Name = "Gunung Nomaly TP & Fly GUI",
   LoadingTitle = "Teleport & Flight Script",
   LoadingSubtitle = "by Grok",
   ConfigurationSaving = {
      Enabled = false,
      FolderName = nil,
      FileName = "GunungNomalyTP"
   }
})

-- Create a tab for teleport and flight controls
local Tab = Window:CreateTab("Checkpoints & Flight", nil)

-- Function to find and sort checkpoints
local function findCheckpoints()
   local checkpoints = {}
   local checkpointFolder = game.Workspace:FindFirstChild("Checkpoints")
   if checkpointFolder then
      for _, child in ipairs(checkpointFolder:GetChildren()) do
         if child:IsA("BasePart") and string.match(child.Name, "Checkpoint%d+") then
            table.insert(checkpoints, child)
         end
      end
      -- Sort by checkpoint number (e.g., Checkpoint1, Checkpoint2)
      table.sort(checkpoints, function(a, b)
         return tonumber(string.match(a.Name, "%d+")) < tonumber(string.match(b.Name, "%d+"))
      end)
   else
      Rayfield:Notify({
         Title = "Error",
         Content = "Checkpoints folder not found in Workspace.",
         Duration = 5,
         Image = nil,
         Actions = {}
      })
   end
   return checkpoints
end

-- Get checkpoints
local checkpoints = findCheckpoints()

-- Create a button for each checkpoint
if #checkpoints > 0 then
   for i, cp in ipairs(checkpoints) do
      Tab:CreateButton({
         Name = "Teleport to " .. cp.Name,
         Callback = function()
            local player = game.Players.LocalPlayer
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
               player.Character.HumanoidRootPart.CFrame = cp.CFrame * CFrame.new(0, 5, 0) -- TP above the checkpoint
               Rayfield:Notify({
                  Title = "Teleported",
                  Content = "To " .. cp.Name,
                  Duration = 3,
                  Image = nil,
                  Actions = {}
               })
            else
               Rayfield:Notify({
                  Title = "Error",
                  Content = "Player character not found.",
                  Duration = 3,
                  Image = nil,
                  Actions = {}
               })
            end
         end
      })
   end
else
   Tab:CreateLabel("No checkpoints found matching 'CheckpointX' pattern.")
end

-- Auto-Teleport through all checkpoints
Tab:CreateButton({
   Name = "Auto TP Through All Checkpoints",
   Callback = function()
      local player = game.Players.LocalPlayer
      if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
         for i, cp in ipairs(checkpoints) do
            player.Character.HumanoidRootPart.CFrame = cp.CFrame * CFrame.new(0, 5, 0)
            wait(1) -- Delay between TPs, adjust as needed
         end
         Rayfield:Notify({
            Title = "Auto TP Complete",
            Content = "Teleported through all checkpoints.",
            Duration = 5,
            Image = nil,
            Actions = {}
         })
      else
         Rayfield:Notify({
            Title = "Error",
            Content = "Player character not found.",
            Duration = 3,
            Image = nil,
            Actions = {}
         })
      end
   end
})

-- Flying variables
local player = game.Players.LocalPlayer
local character = player.Character
local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
local humanoid = character and character:FindFirstChild("Humanoid")
local bodyVelocity, bodyGyro
local isFlying = false
local flySpeed = 50
local maxSpeed = 200

-- Function to start flying
local function startFlying()
   if not character or not humanoidRootPart or not humanoid then return end
   isFlying = true
   humanoid.PlatformStand = true

   bodyVelocity = Instance.new("BodyVelocity")
   bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
   bodyVelocity.Velocity = Vector3.new(0, 0, 0)
   bodyVelocity.Parent = humanoidRootPart

   bodyGyro = Instance.new("BodyGyro")
   bodyGyro.MaxTorque = Vector3.new(400000, 400000, 400000)
   bodyGyro.P = 3000
   bodyGyro.D = 500
   bodyGyro.Parent = humanoidRootPart

   spawn(function()
      local camera = game.Workspace.CurrentCamera
      while isFlying and humanoidRootPart and humanoid.Health > 0 do
         local moveDirection = Vector3.new(0, 0, 0)
         local inputState = game:GetService("UserInputService")
         local cameraCFrame = camera.CFrame

         if inputState:IsKeyDown(Enum.KeyCode.W) then
            moveDirection = moveDirection + cameraCFrame.LookVector
         end
         if inputState:IsKeyDown(Enum.KeyCode.S) then
            moveDirection = moveDirection - cameraCFrame.LookVector
         end
         if inputState:IsKeyDown(Enum.KeyCode.A) then
            moveDirection = moveDirection - cameraCFrame.RightVector
         end
         if inputState:IsKeyDown(Enum.KeyCode.D) then
            moveDirection = moveDirection + cameraCFrame.RightVector
         end
         if inputState:IsKeyDown(Enum.KeyCode.Space) then
            moveDirection = moveDirection + Vector3.new(0, 1, 0)
         end
         if inputState:IsKeyDown(Enum.KeyCode.LeftShift) then
            moveDirection = moveDirection - Vector3.new(0, 1, 0)
         end

         if moveDirection.Magnitude > 0 then
            moveDirection = moveDirection.Unit * flySpeed
         end
         bodyVelocity.Velocity = moveDirection
         bodyGyro.CFrame = CFrame.new(Vector3.new(0, 0, 0), cameraCFrame.LookVector)

         game:GetService("RunService").Heartbeat:Wait()
      end
   end)

   Rayfield:Notify({
      Title = "Flying Enabled",
      Content = "Use WASD, Space, and Shift to move.",
      Duration = 3,
      Image = nil,
      Actions = {}
   })
end

-- Function to stop flying
local function stopFlying()
   if isFlying then
      isFlying = false
      if bodyVelocity then bodyVelocity:Destroy() end
      if bodyGyro then bodyGyro:Destroy() end
      if humanoid then humanoid.PlatformStand = false end
      Rayfield:Notify({
         Title = "Flying Disabled",
         Content = "Flying mode turned off.",
         Duration = 3,
         Image = nil,
         Actions = {}
      })
   end
end

-- Ensure flying stops on character reset
player.CharacterAdded:Connect(function(newChar)
   character = newChar
   humanoidRootPart = newChar:WaitForChild("HumanoidRootPart")
   humanoid = newChar:WaitForChild("Humanoid")
   stopFlying()
end)

-- Toggle flying button
Tab:CreateToggle({
   Name = "Toggle Fly",
   CurrentValue = false,
   Callback = function(Value)
      if Value then
         if character and humanoidRootPart and humanoid and humanoid.Health > 0 then
            startFlying()
         else
            Rayfield:Notify({
               Title = "Error",
               Content = "Player character not loaded. Try again.",
               Duration = 3,
               Image = nil,
               Actions = {}
            })
         end
      else
         stopFlying()
      end
   end
})

-- Fly speed slider
Tab:CreateSlider({
   Name = "Fly Speed",
   Range = {10, maxSpeed},
   Increment = 10,
   Suffix = "Speed",
   CurrentValue = flySpeed,
   Callback = function(Value)
      flySpeed = Value
      Rayfield:Notify({
         Title = "Speed Updated",
         Content = "Fly speed set to " .. Value,
         Duration = 2,
         Image = nil,
         Actions = {}
      })
   end
})

-- Optional: Toggle GUI visibility
Tab:CreateToggle({
   Name = "Toggle GUI Visibility",
   CurrentValue = true,
   Callback = function(Value)
      Rayfield:ToggleWindow(Value)
   end
})
