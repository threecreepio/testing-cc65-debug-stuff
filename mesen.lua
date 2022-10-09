TYPE_DEBUG = 0
TYPE_TRACE = 1

function add_callback(data, fn)
  local ofs_lo = string.byte(data, 1)
  local ofs_hi = string.byte(data, 2)
  local ofs_fr = string.byte(data, 3)
  local ofs = ofs_fr << 16 | ofs_hi << 8 | ofs_lo
  
  local cpu_lo = string.byte(data, 4)
  local cpu_hi = string.byte(data, 5)
  local cpu = cpu_hi << 8 | cpu_lo
  
  local bank = ofs / 0x4000
  local bank_ofs = ofs % 0x4000
  
  function callback_hit()
    local state = emu.getState()
    local pageSize = state.cart.prgPageSize
    local currentPage = math.floor((cpu - 0x8000) / pageSize)
    local expectedPrg = math.floor(ofs / pageSize)
    local selectedPrg = state.cart.selectedPrgPages[currentPage]
    if expectedPrg ~= selectedPrg then return end
    fn(state)
  end
  emu.addMemoryCallback(callback_hit, emu.memCallbackType.cpuExec, cpu - 1, cpu)
end

function handle_debug(data)
  add_callback(data, function ()
    emu.breakExecution()
  end)
end

function handle_trace(data)
  local msg = string.sub(data, 6)
  add_callback(data, function (state)
    emu.log(string.format("A:%02X Y:%02X X:%02X : %s", state.cpu.a, state.cpu.x, state.cpu.y, msg))
  end)
end

function startup()
  local romInfo = emu.getRomInfo()
  local romPath = romInfo.path
  local directory = romPath:match("(.*)\\")
    
  local debugFile = io.open(directory .. "\\debug.bin", "rb")
  if debugFile == nil then
    emu.log("no debug file found")
    return
  end
  
  while true do
    local len = debugFile:read(1)
    if len == nil then break end
    local type = string.byte(debugFile:read(1))
    local data = debugFile:read(string.byte(len) - 1)
    if type == TYPE_DEBUG then
      handle_debug(data)
    elseif type == TYPE_TRACE then
      handle_trace(data)
    else
      emu.log("unhandled type " .. type)
    end
  end
  
  assert(debugFile:close())
end

startup()
