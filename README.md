# Physics Merger

## Note

- Use the 'SetOnStepped' to set the updater function.
- The Stepped callback is expected to return a CFrame that will be used to pivot the object.

## Sample
```lua
local PhysicsMerge = require(PhysicsMerge)

local NewPhysicsMerger = PhysicsMerge.InitObject(BasePartOrModel)

PhysicsMerge.SetOnStepped(NewPhysicsMerger, function(o, cf, dt)
	return cf * CFrame.Angles(0, .1, 0)
end)

-- The display part shows where the object would be if it was ignoring physics.
NewPhysicsMerger.Changed:Connect(function(deltaCF)
	local DisplayPart = workspace.p1:Clone()
	DisplayPart.Transparency = .5
	DisplayPart.Color = Color3.new(1,0,0)
	DisplayPart.CFrame = d.Pivot * deltaCF:Inverse()
	DisplayPart.CanCollide = false
	DisplayPart.Anchored = true
	DisplayPart.Parent = workspace
	
	task.delay(nil, function()
		DisplayPart:Destroy()
	end)
end)
```