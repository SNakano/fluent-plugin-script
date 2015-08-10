def filter(tag, time, record)
  case tag
  when /.+\.code$/
    code(record)
  when /.+\.msg$/
    message(record)
  end
end

def code(record)
  if record.has_key?("key1")
    record["code"] = record["key1"].to_i
    record.delete("key1")
  end
  record
end

def message(record)
  case record["key2"].to_i
  when 100..200
    level = "INFO"
  when 201..300
    level = "WARN"
  else
    level = "ERROR"
  end
  record.delete("key2")

  record["message"] = level + ":" + record["key3"]
  record.delete("key3")
  record
end
