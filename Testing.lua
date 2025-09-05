-- Rayfield GUI with Separate Tabs for Flight and Checkpoints in [BARU] Gunung Nomaly
-- Compatible with Delta Mobile Executor and PC Executors (e.g., Xeno)
-- Updated Rayfield URL for reliability; includes flying mode, teleport to checkpoints, summit detection, and enhanced checkpoint handling

local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Rayfield/main/source'))()

-- Create the main GUI window
local Window = Rayfield:CreateWindow({
   Name = "Gunung Nomaly Utility GUI",
   LoadingTitle = "Flight & TP Script",
   LoadingSubtitle = "by Grok",
   ConfigurationSaving = {
      Enabled = false,
      FolderName = nil,
      FileName = "GunungNomalyUtility"
   }
})

-- Create separate tabs
local FlightTab = Window:CreateTab("Flight Controls", nil)
local CheckpointTab = Window:CreateTab("Checkpoint Teleports", nil)

-- Function to find and sort checkpoints with enhanced debugging and delay
local function findCheckpoints()
   local checkpoints = {}
   local checkpointFolder = game.Workspace:FindFirstChild("Checkpoints")
   if checkpointFolder then
      -- Wait briefly to allow dynamic loading
      wait(2) -- Adjustable delay to let checkpoints load
      for _, child in ipairs(checkpointFolder:GetChildren()) do
         if child:IsA("BasePart") then
            local isCheckpoint = string.match(child.Name, "Checkpoint%d+") or string.match(child.Name, "CP%d+") or string.match(child.Name, "CheckPoint%d+") -- Try multiple patterns
            if isCheckpoint then
               table.insert(checkpoints, child)
               print("Detected Checkpoint: " .. child.Name .. " at Position: " .. tostring(child.Position))
            else
               print("Skipped: " .. child.Name .. " (Not a recognized checkpoint pattern)")
            end
         end
      end
      -- Sort by checkpoint number
      table.sort(checkpoints, function(a, b)
         local numA = tonumber(string.match(a.Name, "%d+")) or 0
         local numB = tonumber(string.match(b.Name, "%d+")) or 0
         return numA < numB
      end)
      if #checkpoints == 0 then
         Rayfield:Notify({
            Title = "Warning",
            Content = "No checkpoints found. Check console for details or use flying to progress.",
            Duration = 5,
            Image = nil,
            Actions = {}
         })
      else
         Rayfield:Notify({
            Title = "Notice",
            Content = #checkpoints .. " checkpoints detected. If 5-6 are missing, they may load later.",
            Duration = 5,
            Image = nil,
            Actions = {}
         })
      end
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

-- Initial checkpoints load
local checkpoints = findCheckpoints()

-- Function to create teleport buttons based on current checkpoints
local function createTeleportButtons()
   -- Clear existing buttons (except fixed ones)
   -- Note: Rayfield doesn't support dynamic clearing easily, so buttons may duplicate on refresh; use with caution
   for i, cp in ipairs(checkpoints) do
      CheckpointTab:CreateButton({
         Name = "Teleport to " .. cp.Name,
         Callback = function()
            local player = game.Players.LocalPlayer
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
               player.Character.HumanoidRootPart.CFrame = cp.CFrame * CFrame.new(0, 5, 0)
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
end

-- Initial creation of teleport buttons
if #checkpoints > 0 then
   createTeleportButtons()
else
   CheckpointTab:CreateLabel("No checkpoints found. Use flying to explore or check console.")
end

-- Refresh Checkpoints button
CheckpointTab:CreateButton({
   Name = "Refresh Checkpoints",
   Callback = function()
      checkpoints = findCheckpoints()
      Rayfield:Notify({
         Title = "Refreshed",
         Content = "Checkpoints reloaded. New buttons may appear below.",
         Duration = 3,
         Image = nil,
         Actions = {}
      })
      if #checkpoints > 0 then
         createTeleportButtons()
      end
   end
})

-- Auto-Teleport through all checkpoints
CheckpointTab:CreateButton({
   Name = "Auto TP Through All Checkpoints",
   Callback = function()
      local player = game.Players.LocalPlayer
      if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
         for i, cp in ipairs(checkpoints) do
            player.Character.HumanoidRootPart.CFrame = cp.CFrame * CFrame.new(0, 5, 0)
            wait(1)
         end
         Rayfield:Notify({
            Title = "Auto TP Complete",
            Content = "Teleported through all checkpoints. Fly or walk to summit if needed.",
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

-- Detect and add button for Summit
local summitPart = game.Workspace:FindFirstChild("Summit", true) or game.Workspace.Checkpoints:FindFirstChild("Summit")
if summitPart and summitPart:IsA("BasePart") then
   CheckpointTab:CreateButton({
      Name = "Teleport to Summit",
      Callback = function()
         local player = game.Players.LocalPlayer
         if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = summitPart.CFrame * CFrame.new(0, 5, 0)
            Rayfield:Notify({
               Title = "Teleported",
               Content = "To Summit. Press E or tap to interact.",
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
else
   CheckpointTab:CreateLabel("Summit not found. Use flying to reach the top and interact (E/tap).")
end

-- Allow manual addition of missing checkpoints (any number)
CheckpointTab:CreateButton({
   Name = "Add Missing Checkpoint (e.g., 5-6)",
   Callback = function()
      local input = CheckpointTab:CreateInput({
         Name = "Enter Checkpoint Number (e.g., 5)",
         PlaceholderText = "Number only",
         RemoveTextAfterFocusLost = false,
         Callback = function(text)
            local num = tonumber(text)
            if num then
               local cpName = "Checkpoint" .. num
               local cp = game.Workspace.Checkpoints:FindFirstChild(cpName)
               if cp and cp:IsA("BasePart") then
                  table.insert(checkpoints, cp)
                  CheckpointTab:CreateButton({
                     Name = "Teleport to " .. cpName,
                     Callback = function()
                        local player = game.Players.LocalPlayer
                        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                           player.Character.HumanoidRootPart.CFrame = cp.CFrame * CFrame.new(0, 5, 0)
                           Rayfield:Notify({
                              Title = "Teleported",
                              Content = "To " .. cpName,
                              Duration = 3,
                              Image = nil,
                              Actions = {}
                           })
                        end
                     end
                  })
                  Rayfield:Notify({
                     Title = "Success",
                     Content = cpName .. " added and button created.",
                     Duration = 3,
                     Image = nil,
                     Actions = {}
                  })
               else
                  Rayfield:Notify({
                     Title = "Error",
                     Content = cpName .. " not found in Workspace.Checkpoints.",
                     Duration = 3,
                     Image = nil,
                     Actions = {}
                  })
               end
            else
               Rayfield:Notify({
                  Title = "Error",
                  Content = "Invalid input. Enter a number like 5 or 6.",
                  Duration = 3,
                  Image = nil,
                  Actions = {}
               })
            end
         end
      })
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
      Content = "Use WASD, Space, and Shift to move. Fly to find missing checkpoints or summit.",
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
FlightTab:CreateToggle({
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
FlightTab:CreateSlider({
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

-- Toggle GUI visibility for both tabs
local function createVisibilityToggle(tab)
   tab:CreateToggle({
      Name = "Toggle GUI Visibility",
      CurrentValue = true,
      Callback = function(Value)
         Rayfield:ToggleWindow(Value)
      end
   })
end
createVisibilityToggle(FlightTab)
createVisibilityToggle(CheckpointTab)

can you fix my code and fix the flight mode, and leave everything as is
