def filter(tag, time, record)
  record['message'].gsub!(/GET/, "PUT")
  record
end
