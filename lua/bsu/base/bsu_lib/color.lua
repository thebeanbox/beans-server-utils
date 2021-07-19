function BSU:HexToColor(hex, alpha)
  local hex = hex:gsub("#","")
  return Color(tonumber("0x" .. hex:sub(1,2)), tonumber("0x" .. hex:sub(3,4)), tonumber("0x" .. hex:sub(5,6)), alpha or 255)
end

function BSU:ColorToHex(color)
  return string.format("%.2x%.2x%.2x", color.r, color.g, color.b)
end