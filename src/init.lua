local SHOW_REMINDER = true

if SHOW_REMINDER then
	warn("PhysicsMerger will warn you if any objects are Grounded.\n This severely impacts performance and should be turned off when confident in usage.")
end

local RunService = game:GetService("RunService")

local data = {}

local m = {}

function m.Init(object)
	local event = Instance.new"BindableEvent"

	local _data = {
		Object = object,

		Pivot = object:GetPivot(),
		Changed = event.Event, -- Fires the "Delta" of the CFrame

		_event = event
	}

	table.insert(data, _data)

	return _data
end

function m.Deinit(_data)
	local i = table.find(data, _data)

	if i then
		data[i], data[#data] = data[#data], nil
	end

	_data._event:Destroy()

	table.clear(_data)
end

function m.Pause(_data)
	local i = table.find(data, _data)

	if i then
		data[i], data[#data] = data[#data], nil
	end
end

-- Opted for this approach to enforce correct usage of Stepped Update cycle.
function m.SetOnStepped(_data, f : (instance : BasePart | Model, lastPivot : CFrame, dt) -> newCframe)
	_data._onStepped = f
end

RunService.Stepped:Connect(function(_, deltaTime)
	for _, _data in data do
		if _data._onStepped then
			local nextCF = _data._onStepped(_data.Object, _data.Pivot, deltaTime)
			
			if not nextCF then warn(_data.Object.Name .. "'s Stepped-callback did not return a CFrame to PivotTo") continue end
			
			_data.Pivot = nextCF
			_data.Object:PivotTo(nextCF)

			if SHOW_REMINDER then
				local _isGrounded = false

				if _data.Object.ClassName == "Model" then
					_isGrounded = _data.Object:FindFirstChildWhichIsA("BasePart", true):IsGrounded()
				else
					_isGrounded = _data.Object:IsGrounded()
				end

				if _isGrounded then
					warn(_data.Object.Name .. " was Grounded. PhysicsMerger has paused simulation for this object.")

					m.Pause(_data)
				end
			end
		end
	end
end)

RunService.Heartbeat:Connect(function(deltaTime)
	for _, _data in data do
		local setPiv = _data.Pivot
		local updatedPivot = _data.Object:GetPivot()

		if updatedPivot ~= setPiv then
			_data.Pivot = updatedPivot
			_data._event:Fire(setPiv:ToObjectSpace(updatedPivot))
		end
	end
end)

return m