-- Rayfield GUI with Separate Tabs for Flight and Checkpoints in [BARU] Gunung Nomaly
-- Compatible with Delta Mobile Executor and PC Executors (e.g., Xeno)
-- Includes enhanced debugging to identify Rayfield-related issues

-- Attempt to load Rayfield with primary URL
local success, Rayfield = pcall(function()
   return loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Rayfield/main/source'))()
end)
if not success or not Rayfield then
   warn("Failed to load Rayfield from primary URL. Check network or executor compatibility.")
   return
else
   print("Rayfield loaded successfully from primary URL.")
end

-- Create the main GUI window with error checking
local Window
pcall(function()
   Window = Rayfield:CreateWindow({
      Name = "Gunung Nomaly Utility GUI",
      LoadingTitle = "Flight & TP Script",
      LoadingSubtitle = "by Grok",
      ConfigurationSaving = {
         Enabled = false,
         FolderName = nil,
         FileName = "GunungNomalyUtility"
      }
   })
end)
if not Window then
   warn("Failed to create GUI window. Rayfield initialization may have failed.")
   return
else
   print("GUI window created successfully.")
end

-- Create separate tabs with error checking
local FlightTab, CheckpointTab
pcall(function()
   FlightTab = Window:CreateTab("Flight Controls", nil)
   CheckpointTab = Window:CreateTab("Checkpoint Teleports", nil)
end)
if not FlightTab or not CheckpointTab then
   warn("Failed to create one or both tabs. Check Rayfield or script context.")
   return
else
   print("Tabs created successfully.")
end

-- Function to find and sort checkpoints
local function findCheckpoints()
   local checkpoints = {}
   local checkpointFolder = game.Workspace:FindFirstChild("Checkpoints")
   if checkpointFolder then
      wait(2) -- Delay to allow loading
      for _, child in ipairs(checkpointFolder:GetChildren()) do
         if child:IsA("BasePart") and string.match(child.Name, "Checkpoint%d+") then
            table.insert(checkpoints, child)
            print("Detected Checkpoint: " .. child.Name .. " at Position: " .. tostring(child.Position))
         end
      end
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
      pcall(function()
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
      end)
   else
      pcall(function()
         CheckpointTab:CreateLabel("No checkpoints found. Use flying to explore or check console.")
      end)
   end
end

-- Auto-Teleport through all checkpoints
pcall(function()
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
end)

-- Detect and add button for Summit
local summitPart = game.Workspace:FindFirstChild("Summit", true) or game.Workspace.Checkpoints:FindFirstChild("Summit")
if summitPart and summitPart:IsA("BasePart") then
   pcall(function()
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
   end)
else
   pcall(function()
      CheckpointTab:CreateLabel("Summit not found. Use flying to reach the top and interact (E/tap).")
   end)
end

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
pcall(function()
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
end)

-- Fly speed slider
pcall(function()
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
end)

-- Toggle GUI visibility for both tabs
pcall(function()
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
end)
