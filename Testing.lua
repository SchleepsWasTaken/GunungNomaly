-- Rayfield GUI Teleport Script for [BARU] Gunung Nomaly
-- Compatible with Delta Mobile Executor and PC Executors (e.g., Xeno)
-- Teleports through checkpoints in Workspace.Checkpoints (e.g., Checkpoint1, Checkpoint2, etc.)

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Create the main GUI window
local Window = Rayfield:CreateWindow({
   Name = "Gunung Nomaly TP GUI",
   LoadingTitle = "Teleport Script",
   LoadingSubtitle = "by Grok",
   ConfigurationSaving = {
      Enabled = false,
      FolderName = nil,
      FileName = "GunungNomalyTP"
   }
})

-- Create a tab for teleport controls
local Tab = Window:CreateTab("Checkpoints", nil)

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

-- Optional: Toggle GUI visibility
Tab:CreateToggle({
   Name = "Toggle GUI Visibility",
   CurrentValue = true,
   Callback = function(Value)
      Rayfield:ToggleWindow(Value)
   end
})
