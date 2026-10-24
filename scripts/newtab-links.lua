-- Leave slide navigation in place; open linked resources in a separate tab.
function Link(link)
  if not link.target:match("^#") then
    link.attributes.target = "_blank"
    link.attributes.rel = "noopener noreferrer"
  end
  return link
end
