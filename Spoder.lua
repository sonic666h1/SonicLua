-- Module for common functions
local functionUtil = {}

function functionUtil.createPart(size, position, color, transparency, parent)
  local part = Instance.new("Part")
  part.Size = size
  part.Anchored = true
  part.Position = position
  part.Color = color
  part.Transparency = transparency or 0 -- Optional transparency
  part.Parent = parent
  return part
end

-- Module for spider model creation
local spiderModelUtil = {}

function spiderModelUtil.createSpiderModel(position)
  local spiderModel = Instance.new("Model")
  spiderModel.Name = "Spider"

  -- Create spider body
  local body = functionUtil.createPart(Vector3.new(4, 2, 6), position, Color3.fromRGB(0, 0, 0), 0, spiderModel)
  body.Name = "Body"

  -- Create spider legs
  local legOffsets = {
    Vector3.new(3, 0, 3), Vector3.new(3, 0, 0),
    Vector3.new(3, 0, -3), Vector3.new(0, 0, -3),
    Vector3.new(-3, 0, -3), Vector3.new(-3, 0, 0),
    Vector3.new(-3, 0, 3), Vector3.new(0, 0, 3)
  }

  for i, offset in ipairs(legOffsets) do
    local leg = functionUtil.createPart(Vector3.new(1, 6, 1), position + offset, Color3.fromRGB(0, 0, 0), 0, spiderModel)
    leg.Name = "Leg" .. i
  end

  -- Create spider eyes
  for i = 1, 2 do
    local eye = functionUtil.createPart(Vector3.new(0.5, 0.5, 0.5), position + Vector3.new(1.5 - (i-1)*3, 1.5, -2.5), Color3.fromRGB(255, 0, 0), 0, spiderModel)
    eye.Name = "Eye" .. i
  end

  return spiderModel
end

-- Module for character transformation
local characterUtil = {}

function characterUtil.removeOriginalCharacterModel(character)
  for _, part in ipairs(character:GetChildren()) do
    if part:IsA("BasePart") or part:IsA("Humanoid") then
      part:Destroy()
    end
  end
end

function characterUtil.setSpiderModelAsCharacter(player, spiderModel)
  spiderModel.Parent = workspace
  local newHumanoid = Instance.new("Humanoid")
  newHumanoid.Parent = spiderModel
  spiderModel.PrimaryPart = spiderModel:FindFirstChild("Body")
  player.Character = spiderModel
end

function characterUtil.revertTransformation(player, originalCharacter, spiderModel)
  if originalCharacter then
    player.Character = originalCharacter
    originalCharacter:MoveTo(spiderModel.PrimaryPart.Position)
    originalCharacter.Parent = workspace
  end
  if spiderModel then
    spiderModel:Destroy()
  end
end

-- Main Script
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- Create GUI Menu
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SpiderTransformationMenu"
screenGui.Parent = game.CoreGui

local menuFrame = Instance.new("Frame")
menuFrame.Size = UDim2.new(0, 250, 0, 200)
menuFrame.Position = UDim2.new(0.5, -125, 0.5, -100)
menuFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
menuFrame.Parent = screenGui

local menuVisible = true -- Flag to track menu visibility
menuFrame.Visible = menuVisible

-- Menu Title
local menuTitle = Instance.new("TextLabel")
menuTitle.Size = UDim2.new(1, 0, 0, 30)
menuTitle.Position = UDim2.new(0, 0, 0, 0)
menuTitle.Font = Enum.Font.SourceSansBold
menuTitle.Text = "Spider Transformation"
menuTitle.TextScaled = true
menuTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
menuTitle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
menuTitle.Parent = menuFrame

-- Transform Button
local transformButton = Instance.new("TextButton")
transformButton.Size = UDim2.new(1, -20, 0, 40)
transformButton.Position = UDim2.new(0.5, -90, 0.4, -20)
transformButton.Font = Enum.Font.SourceSans
transformButton.Text = "Transform into Spider"
transformButton.TextScaled = true
transformButton.TextColor3 = Color3.fromRGB(255, 255, 255)
transformButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
transformButton.Parent = menuFrame

-- Revert Button
local revertButton = Instance.new("TextButton")
revertButton.Size = UDim2.new(1, -20, 0, 40)
revertButton.Position = UDim2.new(0.5, -90, 0.7, -20)
revertButton.Font = Enum.Font.SourceSans
revertButton.Text = "Revert to Human"
revertButton.TextScaled = true
revertButton.TextColor3 = Color3.fromRGB(255, 255, 255)
revertButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
revertButton.Parent = menuFrame

-- Toggle Menu Visibility Button
local toggleMenuButton = Instance.new("TextButton")
toggleMenuButton.Size = UDim2.new(1, -20, 0, 30)
toggleMenuButton.Position = UDim2.new(0.5, -90, 0.9, -15)
toggleMenuButton.Font = Enum.Font.SourceSans
toggleMenuButton.Text = "Toggle Menu"
toggleMenuButton.TextScaled = true
toggleMenuButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleMenuButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
toggleMenuButton.Parent = menuFrame

-- Original character reference
local originalCharacter = character:Clone()

-- Check if the player owns the game pass
local gamePassId = YOUR_GAMEPASS_ID -- Replace with your actual game pass ID
local hasGamePass = false

local success, result = pcall(function()
  return game:GetService("MarketplaceService"):UserOwnsGamePassAsync(player.UserId, gamePassId)
end)

if success then
  hasGamePass = result
else
  warn("Error checking game pass ownership: " .. tostring(result))
end

if hasGamePass then
  -- Button functionality
  transformButton.MouseButton1Click:Connect(function()
    characterUtil.removeOriginalCharacterModel(character)
    local spiderModel = spiderModelUtil.createSpiderModel(character.PrimaryPart.Position)
    characterUtil.setSpiderModelAsCharacter(player, spiderModel)
  end)

  revertButton.MouseButton1Click:Connect(function()
    local spiderModel = player.Character
    characterUtil.revertTransformation(player, originalCharacter, spiderModel)
  end)

  toggleMenuButton.MouseButton1Click:Connect(function()
    menuVisible = not menuVisible
    menuFrame.Visible = menuVisible
  end)
else
  -- Notify the player that they do not own the required game pass
  local noPassMessage = Instance.new("TextLabel")
  noPassMessage.Size = UDim2.new(1, 0, 1, 0)
  noPassMessage.Position = UDim2.new(0, 0, 0, 0)
  noPassMessage.Font = Enum.Font.SourceSansBold
  noPassMessage.Text = "You do not own the required game pass."
  noPassMessage.TextScaled = true
  noPassMessage.TextColor3 = Color3.fromRGB(255, 0, 0)
  noPassMessage.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
  noPassMessage.Parent = menuFrame
end
