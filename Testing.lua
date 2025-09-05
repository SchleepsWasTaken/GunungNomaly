-- Rayfield GUI Flying Mode Script for [BARU] Gunung Nomaly
-- Compatible with Delta Mobile Executor and PC Executors (e.g., Xeno)
-- Provides toggleable flying with adjustable speed

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Create the main GUI window
local Window = Rayfield:CreateWindow({
   Name = "Gunung Nomaly Fly GUI",
   LoadingTitle = "Flying Mode",
   LoadingSubtitle = "by Grok",
   ConfigurationSaving = {
      Enabled = false, -- Set to true to save GUI settings
      FolderName = nil,
      FileName = "GunungNomalyFly"
   }
})

-- Create a tab for flying controls
local Tab = Window:CreateTab("Flight Controls", nil)

-- Flying variables
local player = game.Players.LocalPlayer
local character = player.Character
local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
local humanoid = character and character:FindFirstChild("Humanoid")
local bodyVelocity, bodyGyro
local isFlying = false
local flySpeed = 50 -- Default speed
local maxSpeed = 200 -- Maximum speed for slider

-- Function to start flying
local function startFlying()
   if not character or not humanoidRootPart or not humanoid then return end
   isFlying = true
   humanoid.PlatformStand = true -- Disable walking

   -- Create BodyVelocity for movement
   bodyVelocity = Instance.new("BodyVelocity")
   bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
   bodyVelocity.Velocity = Vector3.new(0, 0, 0)
   bodyVelocity.Parent = humanoidRootPart

   -- Create BodyGyro for orientation
   bodyGyro = Instance.new("BodyGyro")
   bodyGyro.MaxTorque = Vector3.new(400000, 400000, 400000)
   bodyGyro.P = 3000
   bodyGyro.D = 500
   bodyGyro.Parent = humanoidRootPart

   -- Flying loop
   spawn(function()
      local camera = game.Workspace.CurrentCamera
      while isFlying and humanoidRootPart and humanoid.Health > 0 do
         local moveDirection = Vector3.new(0, 0, 0)
         local inputState = game:GetService("UserInputService")
         local cameraCFrame = camera.CFrame

         -- Get movement input (WASD or mobile thumbstick)
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

         -- Normalize and apply speed
         if moveDirection.Magnitude > 0 then
            moveDirection = moveDirection.Unit * flySpeed
         end
         bodyVelocity.Velocity = moveDirection

         -- Orient character to face camera direction
         bodyGyro.CFrame = CFrame.new(Vector3.new(0, 0, 0), cameraCFrame.LookVector)

         game:GetService("RunService").Heartbeat:Wait()
      end
   end)

   Rayfield:Notify({
      Title = "Flying Enabled",
      Content = "You are now flying! Use WASD, Space, and Shift to move.",
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

-- Ensure flying stops when character resets
player.CharacterAdded:Connect(function(newChar)
   character = newChar
   humanoidRootPart = newChar:WaitForChild("HumanoidRootPart")
   humanoid = newChar:WaitForChild("Humanoid")
   stopFlying() -- Disable flying on respawn
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
